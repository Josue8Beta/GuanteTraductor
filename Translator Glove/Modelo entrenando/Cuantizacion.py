from typing import Counter
import joblib
import tensorflow as tf
import numpy as np

# Carga del modelo Keras
model = tf.keras.models.load_model('Mi_modelo.keras',compile=False)

# Configuracion del conversor con opciones de cuantización
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8

# Generación de datos representativos para la calibración del modelo
def representative_dataset_gen():

    for _ in range(100):
        yield [np.random.randn(1, 11).astype(np.float32)]

converter.representative_dataset = representative_dataset_gen

# Convierte el modelo
tflite_model = converter.convert()

# Guarda el modelo cuantizado
with open('ModelFlutter.tflite', 'wb') as f:
    f.write(tflite_model)
