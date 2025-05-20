
//Este codigo fue desarrollado por Josue Betancourt
//con la finalidad de capturar los valores de los sensores
//flexibles y el modulo MPU6050, los valores se muestran en 
//la consola, para poder automatizar la carga de los datos
//y su etiquetado correspondiente a cada letra y frase.

//Los valores de la consola son adquiridos por medio del
//codigo desarrollado en Python (captura.py), el cual se 
//encargará de recolectar y ordenar en un dataset. 



#include <MPU6050_tockn.h>
#include <Wire.h>

const int Pulgar = 32;
const int Indice = 34;
const int Medio = 33;
const int Anular = 35;
const int Menique = 39;

MPU6050 mpu6050(Wire);

void setup() {
  Serial.begin(115200);
  
  Wire.begin();
  mpu6050.begin();
  mpu6050.calcGyroOffsets(true);
}

void loop() {


  mpu6050.update();
  
  int flex1 = analogRead(Pulgar);
  int flex2 = analogRead(Indice);
  int flex3 = analogRead(Medio);
  int flex4 = analogRead(Anular);
  int flex5 = analogRead(Menique);
  
  float ax = mpu6050.getAccX() * 9.81; // Convertir a m/s^2
  float ay = mpu6050.getAccY() * 9.81;
  float az = mpu6050.getAccZ() * 9.81;
  float gx = mpu6050.getGyroX(); // Ya está en grados/s
  float gy = mpu6050.getGyroY();
  float gz = mpu6050.getGyroZ();

  // Enviar datos por el puerto serial
  Serial.print(flex1);
  Serial.print(",");
  Serial.print(flex2);
  Serial.print(",");
  Serial.print(flex3);
  Serial.print(",");
  Serial.print(flex4);
  Serial.print(",");
  Serial.print(flex5);
  Serial.print(",");
  Serial.print(ax);
  Serial.print(",");
  Serial.print(ay);
  Serial.print(",");
  Serial.print(az);
  Serial.print(",");
  Serial.print(gx);
  Serial.print(",");
  Serial.print(gy);
  Serial.print(",");
  Serial.println(gz);

  delay(500); // Ajusta este valor según la frecuencia de muestreo que necesites
}
