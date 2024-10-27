# File name: scraper.py
# Author: [your name]
# Date created: [current date]
# Last modified: [current date]
# Python Version: 3.12

import requests
from bs4 import BeautifulSoup
import time
import logging

BASE_URL = "https://etherscan.io/contractsVerified"
HEADERS = {"User-Agent": "Mozilla/5.0"}

def get_contracts(page_number):
    """Fetch contract links from Etherscan's verified contracts page."""
    url = f"{BASE_URL}?ps=100&p={page_number}"
    response = requests.get(url, headers=HEADERS)
    contracts = []
    
    if response.status_code == 200:
        soup = BeautifulSoup(response.content, 'html.parser')
        contracts = ["https://etherscan.io" + link['href'] for link in soup.find_all('a', href=True) if '/address/' in link['href']]
    else:
        logging.warning(f"Failed to retrieve page {page_number}: HTTP {response.status_code}")
    return contracts

def scrape_contracts(num_pages):
    """Scrape multiple pages of contracts."""
    all_contracts = []
    for page in range(1, num_pages + 1):
        contracts = get_contracts(page)
        all_contracts.extend(contracts)
        logging.info(f"Scraped {len(contracts)} contracts from page {page}")
        time.sleep(1)  # Rate limit
    return all_contracts

