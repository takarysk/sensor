import sqlite3
import pandas as pd
import matplotlib.pyplot as plt

# # データベースに接続
conn = sqlite3.connect('2025-05-27-20-18-57.db')

# # SQLで1分単位に丸めてカウント（SQLiteの書き方）
query = """
SELECT timestamp, filtered_x, filtered_y, filtered_z from filtered
"""

# # データを取得
df = pd.read_sql_query(query, conn)
conn.close()

# グラフを作成
plt.figure(figsize=(12, 6))

plt.plot(df['timestamp'], df['filtered_x'], label='X-axis', alpha=0.7)
plt.plot(df['timestamp'], df['filtered_y'], label='Y-axis', alpha=0.7)
plt.plot(df['timestamp'], df['filtered_z'], label='Z-axis', alpha=0.7)

plt.xlabel('Time')
plt.ylabel('Acceleration (m/s²)')
plt.title('Acceleration over Time')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

