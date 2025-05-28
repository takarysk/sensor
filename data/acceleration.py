import sqlite3
import pandas as pd
import matplotlib.pyplot as plt

# # データベースに接続
conn = sqlite3.connect('2025-05-27-20-18-57.db')

# # SQLで1分単位に丸めてカウント（SQLiteの書き方）
query = """
SELECT timestamp, useraccelerometerData_X, useraccelerometerData_Y, useraccelerometerData_Z from users
"""

# # データを取得
df = pd.read_sql_query(query, conn)
conn.close()

# グラフを作成
plt.figure(figsize=(12, 6))

plt.plot(df['timestamp'], df['useraccelerometerData_X'], label='X-axis', alpha=0.7)
plt.plot(df['timestamp'], df['useraccelerometerData_Y'], label='Y-axis', alpha=0.7)
plt.plot(df['timestamp'], df['useraccelerometerData_Z'], label='Z-axis', alpha=0.7)

plt.xlabel('Time')
plt.ylabel('Acceleration (m/s²)')
plt.title('Acceleration over Time')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

