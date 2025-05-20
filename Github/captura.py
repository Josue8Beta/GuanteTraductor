import serial
import csv

ser = serial.Serial('COM3', 115200, timeout=1) 


csv_file = 'guante1_df.csv'

with open(csv_file, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Flex1', 'Flex2', 'Flex3', 'Flex4', 'Flex5', 'Ax', 'Ay', 'Az', 'Gx', 'Gy', 'Gz', 'Letra'])
    
    while True:
        try:
            
            letter = input("Ingrese la letra correspondiente: ")
            count = 0
            
            while count < 50:
                # Leer datos del puerto serial
                data = ser.readline().decode('utf-8').strip()
                if data and not ("lk_drv" in data or "q_drv" in data):
                    print(data)
                    
                    sensor_values = data.split(',')
                    
                    writer.writerow(sensor_values + [letter])
                    count += 1

        except KeyboardInterrupt:
            # Salir del bucle si se presiona Ctrl+C
            print("Programa terminado....")
            break

ser.close()
