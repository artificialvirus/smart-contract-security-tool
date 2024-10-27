# src/feature_extraction.py

import re
import networkx as nx
from sklearn.feature_extraction.text import CountVectorizer

def extract_opcode_features(contract_code):
    """Extract opcode sequences from contract code."""
    opcodes = re.findall(r'PUSH\d+|DUP\d+|SWAP\d+|ADD|MUL|SUB|DIV|EQ|GT|LT|AND|OR|XOR|NOT', contract_code)
    vectorizer = CountVectorizer()
    return vectorizer.fit_transform([" ".join(opcodes)]).toarray()

def build_ast(contract_code):
    """Parse Abstract Syntax Tree (AST) representation."""
    # Simplified example; ideally, use a parser for ASTs in Solidity
    # e.g., Slither's CFGs can serve as inputs here
    pass

def build_cfg(contract_code):
    """Construct Control Flow Graph (CFG) from contract code."""
    G = nx.DiGraph()
    # Custom logic here to construct CFG
    return G

