import pandas as pd
from sklearn.preprocessing import MinMaxScaler

# Asumiendo que tus datos están en un DataFrame llamado 'df'
df = pd.DataFrame({
    'Flex1': [4095, 4095, 4095],
    'Flex2': [2480, 2482, 2487],
    'Flex3': [2608, 2624, 2622],
    'Flex4': [3698, 3665, 3706],
    'Flex5': [2913, 2913, 2922],
    'Ax': [9.61, 9.54, 9.48],
    'Ay': [0.20, 0.08, 0.06],
    'Az': [2.73, 2.51, 2.48],
    'Gx': [-3.28, -1.48, 1.77],
    'Gy': [-1.98, -2.29, -2.41],
    'Gz': [-0.30, -2.44, -1.31],
    'Letra': ['a', 'a', 'a']
})

# Normalizar solo los datos de los sensores flex
flex_columns = ['Flex1', 'Flex2', 'Flex3', 'Flex4', 'Flex5']
scaler = MinMaxScaler()
df[flex_columns] = scaler.fit_transform(df[flex_columns])

print(df)