# File name: feature_extraction.py
# This script extracts features from smart contracts
# Author: [name]
# Date created: [date]
# Date last modified: [date]
# Python Version: 3.12
from solidity_parser import parser
import json

def parse_contract_to_ast(contract_code):
    try:
        ast = parser.parse(contract_code)
        return ast
    except Exception as e:
        print(f"Failed to parse contract: {e}")
        return None

if __name__ == "__main__":
    # Example: Load a contract from a file and parse it
    with open('sample_contract.sol', 'r') as file:
        contract_code = file.read()
        ast = parse_contract_to_ast(contract_code)
        if ast:
            print(json.dumps(ast, indent=2))
        else:
            print("Failed to parse contract")
