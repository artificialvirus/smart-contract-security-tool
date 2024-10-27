# backend/routes/analysis.py

from flask import Blueprint, request, jsonify
import subprocess
import joblib
import os

analysis_bp = Blueprint('analysis', __name__)

# Load pre-trained ML model for prediction
model_path = "outputs/model.pkl"
model = joblib.load(model_path) if os.path.exists(model_path) else None

@analysis_bp.route('/', methods=['POST'])
def analyze_contract():
    contract_data = request.json.get("contractData")
    
    # Run static analysis with Mythril and Slither (example with Mythril)
    with open("temp_contract.sol", "w") as temp_file:
        temp_file.write(contract_data)
    
    mythril_result = subprocess.run(["myth", "analyze", "temp_contract.sol"], capture_output=True, text=True)
    
    # ML Model Prediction (assuming features are extracted)
    # features = extract_features(contract_data) # Implement feature extraction function
    # model_prediction = model.predict(features) if model else None

    # Compile results
    analysis_result = {
        "mythril_result": mythril_result.stdout,
        # "model_prediction": model_prediction, # Uncomment once feature extraction is implemented
        "status": "Analysis complete"
    }
    
    # Cleanup
    os.remove("temp_contract.sol")
    return jsonify(analysis_result)

