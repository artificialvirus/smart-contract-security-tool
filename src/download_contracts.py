# File name: download_contracts.py
# Author: [your name]
# Date created: [current date]
# Last modified: [current date]
# Python Version: 3.12

import requests
from bs4 import BeautifulSoup
import os
import logging

def download_contract(address, output_dir):
    """Download Solidity code for a specific contract address."""
    url = f"https://etherscan.io/address/{address}#code"
    headers = {"User-Agent": "Mozilla/5.0"}
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        soup = BeautifulSoup(response.content, 'html.parser')
        code_div = soup.find('pre', {'class': 'js-sourcecopyarea'})
        
        if code_div:
            contract_code = code_div.get_text()
            file_path = os.path.join(output_dir, f"{address}.sol")
            with open(file_path, 'w') as file:
                file.write(contract_code)
            logging.info(f"Downloaded contract {address}")
        else:
            logging.warning(f"Solidity code not found for contract {address}")
    else:
        logging.error(f"Failed to download contract {address}: HTTP {response.status_code}")

