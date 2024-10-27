# src/reporting.py

from fpdf import FPDF

class PDFReport(FPDF):
    def header(self):
        self.set_font("Arial", "B", 12)
        self.cell(0, 10, "Smart Contract Vulnerability Report", ln=True, align="C")

    def add_vulnerability(self, description, severity, code_snippet):
        self.set_font("Arial", size=12)
        self.cell(0, 10, f"Vulnerability: {description}", ln=True)
        self.cell(0, 10, f"Severity: {severity}", ln=True)
        self.multi_cell(0, 10, f"Code Snippet: {code_snippet}", ln=True)

    def save(self, filename):
        self.output(filename)

# Usage
report = PDFReport()
report.add_vulnerability("Reentrancy", "High", "function withdraw() {...}")
report.save("outputs/vulnerability_report.pdf")

