import pandas as pd
import numpy as np
from scipy.signal import butter, filtfilt
import sqlite3

#データベースからデータを読み込む
conn = sqlite3.connect('2025-05-27-20-18-57.db')  
query = "SELECT timestamp, useraccelerometerData_X, useraccelerometerData_Y, useraccelerometerData_Z FROM users"
df = pd.read_sql_query(query, conn)

#サンプリング周波数を指定
fs = 100.0  # Hz

#Butterworthローパスフィルタの設計
cutoff = 10.0  # Hz
order = 4
b, a = butter(order, cutoff / (0.5 * fs), btype='low')

#各軸にローパスフィルタを適用
df['filtered_x'] = filtfilt(b, a, df['useraccelerometerData_X'])
df['filtered_y'] = filtfilt(b, a, df['useraccelerometerData_Y'])
df['filtered_z'] = filtfilt(b, a, df['useraccelerometerData_Z'])

#新しいテーブルとしてSQLiteに保存
filtered_table_name = "filtered"  # 新しいテーブル名を定義
df_to_save = df[['timestamp', 'filtered_x', 'filtered_y', 'filtered_z']]
df_to_save.insert(0, 'id', range(1, len(df_to_save) + 1)) 

#SQLiteに保存
df_to_save.to_sql(filtered_table_name, conn, if_exists='replace', index=False)

conn.close()

