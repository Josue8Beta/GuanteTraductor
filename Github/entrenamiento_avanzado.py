import os
import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.model_selection import KFold
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.metrics import classification_report
import joblib

# Leer el archivo CSV
data = pd.read_csv('tu_archivo_ordenado.csv')

# Separar características (X) y etiquetas (y)
X = data[['Flex1', 'Flex2', 'Flex3', 'Flex4', 'Flex5', 'Ax', 'Ay', 'Az', 'Gx', 'Gy', 'Gz']]
y = data['Letra']

# Codificar las etiquetas (letras) como valores numéricos
label_encoder = LabelEncoder()
y_encoded = label_encoder.fit_transform(y)

# Normalizar las características
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Configurar la validación cruzada
n_splits = 5
kfold = KFold(n_splits=n_splits, shuffle=True, random_state=42)

# Listas para almacenar los resultados
cv_scores = []
histories = []

for fold, (train_index, val_index) in enumerate(kfold.split(X_scaled)):
    print(f'Fold {fold + 1}/{n_splits}')
    
    X_train, X_val = X_scaled[train_index], X_scaled[val_index]
    y_train, y_val = y_encoded[train_index], y_encoded[val_index]
    
    # Definir la red neuronal
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(128, activation='relu', input_shape=(X_train.shape[1],)),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(32, activation='relu'),
        tf.keras.layers.Dense(len(label_encoder.classes_), activation='softmax')
    ])
    
    # Compilar el modelo
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    
    # Callbacks
    early_stopping = tf.keras.callbacks.EarlyStopping(patience=10, restore_best_weights=True)
    reduce_lr = tf.keras.callbacks.ReduceLROnPlateau(factor=0.2, patience=5, min_lr=0.0001)
    
    # Entrenar el modelo
    history = model.fit(
        X_train, y_train,
        epochs=100,
        batch_size=32,
        validation_data=(X_val, y_val),
        callbacks=[early_stopping, reduce_lr]
    )
    
    # Evaluar el modelo
    scores = model.evaluate(X_val, y_val, verbose=0)
    cv_scores.append(scores[1])
    histories.append(history)
    
    print(f'Fold {fold + 1} - Accuracy: {scores[1]*100:.2f}%')

# Imprimir resultados de la validación cruzada
print(f'Mean CV Accuracy: {np.mean(cv_scores)*100:.2f}% (+/- {np.std(cv_scores)*100:.2f}%)')

# Entrenar el modelo final con todos los datos
final_model = tf.keras.Sequential([
        tf.keras.layers.Dense(128, activation='relu', input_shape=(X_train.shape[1],)),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(32, activation='relu'),
        tf.keras.layers.Dense(len(label_encoder.classes_), activation='softmax')
])

final_model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

final_history = final_model.fit(
    X_scaled, y_encoded,
    epochs=100,
    batch_size=32,
    validation_split=0.2,
    callbacks=[early_stopping, reduce_lr]
)

# Guardar el modelo final
final_model.save('Modelo_final_3.keras')

# Convertir el modelo a TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(final_model)
tflite_model = converter.convert()

# Guardar el modelo TensorFlow Lite en un archivo .tflite
with open('Modelo_final_3.tflite', 'wb') as f:
    f.write(tflite_model)

# Guardar el encoder y el scaler para uso futuro
joblib.dump(label_encoder, 'label_encoder_3.joblib')
joblib.dump(scaler, 'scaler_3.joblib')

print("Modelo final, encoder y scaler guardados exitosamente.")

# Verificar la precisión del modelo TFLite
interpreter = tf.lite.Interpreter(model_content=tflite_model)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Hacer predicciones con el modelo TFLite
# Convert X_scaled to float32
X_scaled = X_scaled.astype(np.float32)

# Then proceed with the TFLite predictions
y_pred_tflite = []
for sample in X_scaled:
    interpreter.set_tensor(input_details[0]['index'], [sample])
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    y_pred_tflite.append(np.argmax(output[0]))

# Comparar con las predicciones del modelo original
y_pred_original = np.argmax(final_model.predict(X_scaled), axis=1)

accuracy_tflite = np.mean(y_pred_tflite == y_encoded)
accuracy_original = np.mean(y_pred_original == y_encoded)

print(f"Precisión del modelo original: {accuracy_original*100:.2f}%")
print(f"Precisión del modelo TFLite: {accuracy_tflite*100:.2f}%")

# Imprimir reporte de clasificación
print("\nReporte de clasificación del modelo TFLite:")
print(classification_report(y_encoded, y_pred_tflite, target_names=label_encoder.classes_))