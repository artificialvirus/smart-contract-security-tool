def parse_slither_output(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
        vulnerabilities = data.get('results', {}).get('detectors', [])
        return [vuln['check'] for vuln in vulnerabilities]

if __name__ == "__main__":
    slither_vulnerabilities = parse_slither_output('slither_output.json')
    print("Slither Vulnerabilities:", slither_vulnerabilities)