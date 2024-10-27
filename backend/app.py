# backend/app.py

from flask import Flask, jsonify, request
from flask_cors import CORS
from routes.analysis import analysis_bp
from routes.report import report_bp

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend communication

# Register blueprints for modular routes
app.register_blueprint(analysis_bp, url_prefix='/api/analysis')
app.register_blueprint(report_bp, url_prefix='/api/report')

@app.route('/api/status', methods=['GET'])
def status():
    """Endpoint for checking server status."""
    return jsonify({"status": "Backend server is running"}), 200

if __name__ == "__main__":
    app.run(port=5000, debug=True)

