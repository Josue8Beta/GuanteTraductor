import joblib

scaler = joblib.load('scaler_3.joblib')
means = scaler.mean_.tolist()
scales = scaler.scale_.tolist()

print("Means:", means)
print("Scales:", scales)
label_encoder = joblib.load('label_encoder_3.joblib')
classes = label_encoder.classes_.tolist()
print("Classes:", classes)