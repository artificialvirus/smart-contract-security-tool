import json

def parse_mythril_output(file_path):
    with open(file_path, 'r') as file:
        data = file.readlines()
        vulnerabilities = [line.strip() for line in data if "vuln" in line.lower()]
        return vulnerabilities

if __name__ == "__main__":
    mythril_vulnerabilities = parse_mythril_output('mythril_output.txt')
    print("Mythril Vulnerabilities:", mythril_vulnerabilities)