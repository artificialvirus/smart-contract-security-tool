# src/model_training.py

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, cross_val_score
from imblearn.over_sampling import SMOTE
import joblib

def train_model(X, y):
    """Train Random Forest model as baseline."""
    X_resampled, y_resampled = SMOTE().fit_resample(X, y)
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    scores = cross_val_score(model, X_resampled, y_resampled, cv=5)
    print("Cross-validated accuracy:", scores.mean())
    return model

def save_model(model, model_path="outputs/model.pkl"):
    joblib.dump(model, model_path)
    print("Model saved to:", model_path)

