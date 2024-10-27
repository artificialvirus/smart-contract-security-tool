// frontend/src/components/ReportDisplay.jsx

function ReportDisplay({ report }) {
    return (
      <div className="p-4">
        <h2 className="text-xl font-bold mb-4">Analysis Report</h2>
        {report.mythril_result && (
          <div>
            <h3 className="font-semibold">Mythril Analysis</h3>
            <pre className="bg-gray-100 p-2 rounded mb-4">
              {report.mythril_result}
            </pre>
          </div>
        )}
        {/* Add more sections as needed */}
      </div>
    );
  }
  
  export default ReportDisplay;
  
  