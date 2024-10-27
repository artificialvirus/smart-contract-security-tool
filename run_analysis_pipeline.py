# run_analysis_pipeline.py
# Main script to run the entire process
import os
import logging
import yaml
from src.scraper import scrape_contracts
from src.download_contracts import download_contract
from src.automated_version_switching import analyze_contracts

# Load config
with open("config.yml", "r") as file:
    config = yaml.safe_load(file)

# Set up constants
NUM_PAGES_TO_SCRAPE = config["num_pages_to_scrape"]
CONTRACTS_DIR = config["contracts_dir"]
OUTPUTS_DIR = config["outputs_dir"]

# Logging setup
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def setup_directories():
    """Ensure directories exist for storing contract files and analysis outputs."""
    os.makedirs(CONTRACTS_DIR, exist_ok=True)
    os.makedirs(OUTPUTS_DIR, exist_ok=True)

def main():
    setup_directories()

    # Step 1: Scrape contract links
    logging.info("Starting contract scraping...")
    contract_links = scrape_contracts(NUM_PAGES_TO_SCRAPE)
    
    # Save contract links to CSV
    links_csv = os.path.join(CONTRACTS_DIR, "contracts.csv")
    with open(links_csv, 'w') as csvfile:
        for link in contract_links:
            csvfile.write(f"{link}\n")
    logging.info(f"Scraped {len(contract_links)} contract links.")

    # Step 2: Download contract files
    logging.info("Starting contract download...")
    for link in contract_links:
        address = link.split('/')[-1]
        download_contract(address, CONTRACTS_DIR)
    logging.info("Completed downloading contract files.")

    # Step 3: Run vulnerability analysis
    logging.info("Starting vulnerability analysis...")
    analyze_contracts()
    logging.info("Vulnerability analysis completed.")

if __name__ == "__main__":
    main()

