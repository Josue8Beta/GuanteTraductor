#include <MPU6050_tockn.h>
#include <FirebaseESP32.h>
#include <WiFi.h>
#include <Wire.h>

const char* ssid = "JosuNet"; //SSID de la red a la que se vincula el ESP32
const char* password = "152000Josu"; //Clave de la red local
//#define FIREBASE_HOST "appmovil-default-rtdb.firebaseio.com"
#define FIREBASE_HOST "----------------------------------"
//#define FIREBASE_AUTH "Fl2aTehE72BGUs4mm1e5QGbjOII9ac1xDo"
#define FIREBASE_AUTH "--------------------------------"
const int LED_BUILTIN = 2;
FirebaseData firebaseData;
FirebaseConfig firebaseConfig;
FirebaseAuth firebaseAuth;


const int Pulgar = 32;
const int Indice = 34;
const int Medio = 33;
const int Anular = 35;
const int Menique = 39;

MPU6050 mpu6050(Wire);

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  // Iniciar WiFi
  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi......");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
  }
  Serial.println("\nConectado a WiFi");
  digitalWrite(LED_BUILTIN,HIGH);
  
  
  // Configurar Firebase
  firebaseConfig.host = FIREBASE_HOST;
  firebaseConfig.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&firebaseConfig, &firebaseAuth);

  Wire.begin();
  mpu6050.begin();
  mpu6050.calcGyroOffsets(true);
}

void loop() {
  delay(100);
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

  // Imprimir valores en el monitor serial
  Serial.println("Valores de los sensores flex:");
  Serial.println("Pulgar: " + String(flex1));
  Serial.println("Indice: " + String(flex2));
  Serial.println("Medio: " + String(flex3));
  Serial.println("Anular: " + String(flex4));
  Serial.println("Meñique: " + String(flex5));

  Serial.println("Valores del MPU6050:");
  Serial.println("Aceleración X: " + String(ax) + " m/s^2");
  Serial.println("Aceleración Y: " + String(ay) + " m/s^2");
  Serial.println("Aceleración Z: " + String(az) + " m/s^2");
  Serial.println("Giroscopio X: " + String(gx) + " grados/s");
  Serial.println("Giroscopio Y: " + String(gy) + " grados/s");
  Serial.println("Giroscopio Z: " + String(gz) + " grados/s");

  if (Firebase.ready()) {   // Actualizar datos en Firebase
    Firebase.setInt(firebaseData, "/sensores/Flex1", flex1);
    Firebase.setInt(firebaseData, "/sensores/Flex2", flex2);
    Firebase.setInt(firebaseData, "/sensores/Flex3", flex3);
    Firebase.setInt(firebaseData, "/sensores/Flex4", flex4);
    Firebase.setInt(firebaseData, "/sensores/Flex5", flex5);
    Firebase.setFloat(firebaseData, "/sensores/AX", ax);
    Firebase.setFloat(firebaseData, "/sensores/AY", ay);
    Firebase.setFloat(firebaseData, "/sensores/AZ", az);
    Firebase.setFloat(firebaseData, "/sensores/GX", gx);
    Firebase.setFloat(firebaseData, "/sensores/GY", gy);
    Firebase.setFloat(firebaseData, "/sensores/GZ", gz);
    Serial.println("Datos actualizados en Firebase");
  }
  delay(500);
}