import asyncio
from playwright.async_api import async_playwright
import pandas as pd
from datetime import datetime
import time

async def scrape_year(page, year):
    start_date = f"01/01/{year}"
    end_date = f"12/31/{year}"
    
    print(f"Scraping year {year}...")
    
    await page.goto("http://crashinformationky.org/AdvancedSearch", timeout=60000)
    await page.wait_for_selector("input[name='StartDate']")

    # Fill in dates
    await page.fill("input[name='StartDate']", start_date)
    await page.fill("input[name='EndDate']", end_date)

    # Click "Add Property" to add City filter
    # Based on R script: s(css = "div.eqjs-addrow.eqjs-qp-addrow a")
    try:
        await page.click("div.eqjs-addrow.eqjs-qp-addrow a")
        await asyncio.sleep(1)
        
        # Click "City" property
        await page.click("//div[contains(text(), 'City')]")
        await asyncio.sleep(1)
        
        # Click "[select value]"
        await page.click("a[title='[select value]']")
        
        # Type "Newport" in search box
        await page.fill("#searchBox", "Newport")
        await asyncio.sleep(1)
        
        # Select first search result
        await page.click("//div[contains(@class, 'eqjs-suggestion-item')]")
        await asyncio.sleep(1)
    except Exception as e:
        print(f"Error setting city filter: {e}")
        # Continue anyway, might just get too much data

    # Click search
    await page.click("button#btnSearch")
    await asyncio.sleep(5)
    await page.screenshot(path=f"screenshot_{year}.png")

    # Wait for table to appear or "No results found"
    try:
        # The table might take a while to load
        await page.wait_for_selector("table.dataTable", timeout=30000)
        table = await page.query_selector("table.dataTable")
        html = await table.inner_html()
        df = pd.read_html(f"<table>{html}</table>")[0]
        # Rename columns to lowercase and remove dots
        df.columns = [c.lower().replace('.', '') for c in df.columns]
        return df
    except Exception as e:
        print(f"No data or timeout for year {year}: {e}")
        return None

async def main():
    all_data = []
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()

        for yr in range(2010, 2027):
            df = await scrape_year(page, yr)
            if df is not None and not df.empty:
                print(f"Collected {len(df)} rows for {yr}")
                df["year_group"] = yr
                all_data.append(df)
            await asyncio.sleep(2)

        await context.close()
        await browser.close()

    if all_data:
        final_df = pd.concat(all_data, ignore_index=True)
        print(f"Total rows collected: {len(final_df)}")
        
        # Save to all_crashes.csv
        final_df.to_csv("all_crashes.csv", index=False)
        print("Saved to all_crashes.csv")
    else:
        print("No data collected.")

if __name__ == "__main__":
    asyncio.run(main())
