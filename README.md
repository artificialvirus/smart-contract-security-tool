# Smart Contract Security Tool (ChainSecure)

ChainSecure is an AI-powered tool designed to analyze and detect vulnerabilities in Solidity and Cairo smart contracts. By combining static and dynamic analysis, machine learning, and automated reporting, ChainSecure provides comprehensive insights into the security of smart contracts.

## Features

- **Static and Dynamic Analysis**: Integrates with Mythril and Slither for robust vulnerability detection.
- **Machine Learning Model**: Uses ML predictions (planned integration) to identify both known and novel vulnerabilities.
- **Automated Reporting**: Generates detailed, actionable reports with vulnerability descriptions, severity levels, and remediation suggestions.

## Project Structure
```
smart-contract-security-tool/
├── config.yaml                       # Configuration file
├── run_analysis_pipeline.py          # Main entry point for the analysis pipeline
├── contracts/                        # Stores downloaded contracts
├── outputs/                          # Directory for analysis results
├── src/                              # Source directory
│   ├── scraper.py                    # Scrapes contract links from Etherscan
│   ├── download_contracts.py         # Downloads contracts by address
│   ├── automated_version_switching.py# Manages Solidity version switching for analysis
│   ├── feature_extraction.py         # Extracts features for ML model
│   ├── model_training.py             # Model training and validation for ML models
│   ├── reporting.py                  # Generates reports in PDF format
│   └── utils/                        # Utility functions for various tasks
├── tests/                            # Unit tests for backend and core functionalities
├── Dockerfile                        # Docker setup for deployment
├── .github/
│   └── workflows/
│       └── ci-cd.yml                 # GitHub Actions CI/CD pipeline configuration
├── backend/                          # Flask backend for API
│   ├── app.py                        # Main Flask app
│   ├── requirements.txt              # Backend dependencies
│   └── routes/                       # API routes for analysis and reporting
│       ├── __init__.py
│       ├── analysis.py               # Route for triggering analysis
│       └── report.py                 # Route for fetching/generating reports
└── frontend/                         # React frontend
    ├── public/                       
    ├── src/
    │   ├── App.jsx                   # Main App component
    │   ├── index.css                 # TailwindCSS main file
    │   ├── main.jsx                  # Entry file
    │   └── components/               # Custom React components
    │       ├── AnalysisForm.jsx      # Form for contract analysis input
    │       └── ReportDisplay.jsx     # Display generated reports
    ├── index.html
    ├── package.json                  # Frontend dependencies
    └── tailwind.config.js            # TailwindCSS configuration

```

## Getting Started
### Prerequisites
Python 3.12 or higher
Docker (for containerized deployment)
Node.js and npm (for the frontend setup)
GitHub Account (for CI/CD with GitHub Actions)
### Backend Setup
Navigate to the backend folder:
```
cd backend
```
Install the backend dependencies:
```
pip install -r requirements.txt
```
### Frontend Setup
Navigate to the frontend folder:
```
cd ../frontend
```
Install the frontend dependencies:
```
npm install
```
### Running the Application
Start the Backend Server
From the backend directory, run:

```
python app.py
```
Start the Frontend Server
From the frontend directory, run:
```
npm run dev
```
Visit http://localhost:5173 to access the frontend interface.
Ensure the backend is running on http://localhost:5000 for the frontend to communicate with the API.
### Docker Usage
Build the Docker Image
From the root directory:

```
docker build -t chainsecure .
```
Run the Docker Container
```
docker run -p 5000:5000 chainsecure
```
### Running Tests
Run unit tests with pytest for the backend and core functionalities.

```
pytest tests/
```

### CI/CD Pipeline
A CI/CD pipeline is set up using GitHub Actions, which automatically:

Runs tests on pull requests and merges to the main branch.
Builds Docker images for deployment.
The pipeline configuration can be found in .github/workflows/ci-cd.yml.

### Configuration
You can adjust the application settings in config.yaml, such as:

Number of pages to scrape for contracts
Output directories
Analysis timeouts
### Usage
Submit a Contract: Use the frontend interface to submit Solidity or Cairo smart contract code for analysis.
Receive Analysis Results: View detected vulnerabilities, severity levels, and remediation suggestions in the report.
Download Reports: Export analysis results as PDF or JSON for further review.

### Contributing
Contributions are welcome! Please submit issues or pull requests as needed.

### Summary
CI/CD with GitHub Actions: Automates testing, building, and Docker deployment.
Enhanced Frontend Interface: React components with TailwindCSS styling for a modern, user-friendly design.
Backend and ML Integration: Backend prepared for future ML model predictions for vulnerability detection.
