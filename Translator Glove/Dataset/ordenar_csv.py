import pandas as pd

# Leer el archivo CSV
data = pd.read_csv('guante_c.csv')

# Ordenar el DataFrame por la columna de etiquetas
data = data.sort_values('Letra')

# Escribir el DataFrame ordenado en un nuevo archivo CSV
data.to_csv('tu_archivo_ordenado.csv', index=False)