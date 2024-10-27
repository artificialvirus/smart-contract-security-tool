// frontend/src/App.jsx

import { useState } from "react";
import AnalysisForm from "./components/AnalysisForm";
import ReportDisplay from "./components/ReportDisplay";

function App() {
  const [report, setReport] = useState(null);

  const handleAnalyze = (result) => {
    setReport(result);
  };

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <h1 className="text-2xl font-bold text-center mb-8">Smart Contract Security Tool</h1>
      <AnalysisForm onAnalyze={handleAnalyze} />
      {report && <ReportDisplay report={report} />}
    </div>
  );
}

export default App;

