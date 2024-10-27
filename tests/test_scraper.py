# tests/test_scraper.py

import pytest
from src.scraper import get_contracts, scrape_contracts

def test_get_contracts():
    """Test that get_contracts retrieves links."""
    contracts = get_contracts(1)
    assert len(contracts) > 0, "Expected to retrieve some contract links"

def test_scrape_contracts():
    """Test that scrape_contracts fetches multiple pages."""
    contracts = scrape_contracts(2)
    assert len(contracts) > 0, "Expected to retrieve contract links from multiple pages"

