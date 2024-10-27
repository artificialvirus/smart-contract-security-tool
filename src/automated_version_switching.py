# File name: automated_version_switching.py
# Author: [your name]
# Date created: [current date]
# Last modified: [current date]
# Python Version: 3.12

import os
import subprocess
import re
import logging

CONTRACTS_DIR = "contracts"
OUTPUTS_DIR = "outputs"
os.makedirs(OUTPUTS_DIR, exist_ok=True)

def get_solidity_version(contract_path):
    """Identify Solidity version specified in the contract."""
    with open(contract_path, 'r') as file:
        content = file.read()
        match = re.search(r'pragma solidity (\^?\d+\.\d+\.\d+);', content)
        if match:
            return match.group(1).lstrip("^")
    return None

def analyze_contracts():
    """Run Mythril and Slither analysis on downloaded contracts."""
    for contract_file in os.listdir(CONTRACTS_DIR):
        if contract_file.endswith(".sol"):
            contract_path = os.path.join(CONTRACTS_DIR, contract_file)
            solidity_version = get_solidity_version(contract_path)

            if solidity_version:
                subprocess.run(["solc-select", "install", solidity_version])
                subprocess.run(["solc-select", "use", solidity_version])

            mythril_output = os.path.join(OUTPUTS_DIR, f"mythril_{contract_file}.txt")
            slither_output = os.path.join(OUTPUTS_DIR, f"slither_{contract_file}.json")

            # Run Mythril
            mythril_command = ["myth", "analyze", contract_path, "--solv", solidity_version, "-o", "json"]
            with open(mythril_output, "w") as mythril_out:
                try:
                    subprocess.run(mythril_command, stdout=mythril_out, timeout=100, check=True)
                except subprocess.TimeoutExpired:
                    logging.warning(f"Timeout: Mythril analysis for {contract_file} took too long.")
                except subprocess.CalledProcessError as e:
                    logging.error(f"Mythril error for {contract_file}: {e}")

            # Run Slither
            slither_command = ["slither", contract_path, "--json", slither_output]
            try:
                subprocess.run(slither_command, check=True)
                logging.info(f"Analyzed {contract_file} with Mythril and Slither.")
            except subprocess.CalledProcessError as e:
                logging.error(f"Slither error for {contract_file}: {e}")

