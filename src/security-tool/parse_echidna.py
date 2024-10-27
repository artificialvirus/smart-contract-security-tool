def parse_echidna_output(file_path):
    with open(file_path, 'r') as file:
        data = file.readlines()
        issues = [line.strip() for line in data if "FAIL" in line]
        return issues

if __name__ == "__main__":
    echidna_issues = parse_echidna_output('echidna_output.txt')
    print("Echidna Issues:", echidna_issues)