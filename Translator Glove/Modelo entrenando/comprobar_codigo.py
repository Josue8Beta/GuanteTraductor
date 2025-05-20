import serial
import numpy as np
import tensorflow as tf

# Configuración del puerto serie
PORT = 'COM3'  # Cambia esto según tu configuración
BAUD_RATE = 115200
ser = serial.Serial(PORT, BAUD_RATE)

# Carga del modelo de entrenamiento
model = tf.keras.models.load_model('Modelo_sin_error.h5')

def leer_datos():
    datos = []
    while len(datos) < 16:  # 11 sensores + 5 sensores flex
        if ser.in_waiting > 0:
            linea = ser.readline().decode('utf-8').strip()
            valores = list(map(float, linea.split(',')))  # Asumiendo que los datos están separados por comas
            datos.extend(valores)
    return np.array(datos)

def predecir_gesto(datos):
    # Preprocesamiento de datos si es necesario
    datos = datos.reshape(1, -1)  # Cambiar la forma según el modelo
    prediccion = model.predict(datos)
    return np.argmax(prediccion)  # Devuelve la clase con mayor probabilidad

def main():
    try:
        while True:
            datos_sensor = leer_datos()
            gesto_predicho = predecir_gesto(datos_sensor)
            print(f"Gesto predicho: {gesto_predicho}")
    except KeyboardInterrupt:
        print("Finalizando el programa.")
    finally:
        ser.close()

if __name__ == "__main__":
    main()