// frontend/src/components/AnalysisForm.jsx

import { useState } from 'react';

function AnalysisForm({ onAnalyze }) {
  const [contractData, setContractData] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    const response = await fetch("http://localhost:5000/api/analysis", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ contractData })
    });
    const result = await response.json();
    onAnalyze(result);
  };

  return (
    <form onSubmit={handleSubmit} className="p-4 max-w-md mx-auto bg-white rounded-lg shadow-md">
      <textarea
        className="w-full p-2 border rounded"
        placeholder="Paste smart contract code..."
        value={contractData}
        onChange={(e) => setContractData(e.target.value)}
      />
      <button type="submit" className="mt-4 w-full bg-blue-500 text-white py-2 rounded">
        Analyze Contract
      </button>
    </form>
  );
}

export default AnalysisForm;

