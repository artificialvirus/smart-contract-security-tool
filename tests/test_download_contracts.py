# tests/test_download_contracts.py

import os
from src.download_contracts import download_contract

def test_download_contract(tmp_path):
    """Test that download_contract retrieves Solidity code."""
    address = "0x...sample_address"
    output_dir = tmp_path / "contracts"
    output_dir.mkdir()
    
    download_contract(address, str(output_dir))
    assert any(output_dir.iterdir()), "Expected contract file to be downloaded"

