import sqlite3
import pandas as pd
import matplotlib.pyplot as plt

# # データベースに接続
conn = sqlite3.connect('2025-05-27-20-18-57.db')

# # SQLで1分単位に丸めてカウント（SQLiteの書き方）
query = """
SELECT strftime('%Y-%m-%d %H:%M', timestamp) AS minute, COUNT(*) as count
FROM users
GROUP BY minute
ORDER BY minute
"""

# # データを取得
df = pd.read_sql_query(query, conn)
conn.close()

# グラフを作成
plt.figure(figsize=(12, 6))
plt.plot(df['minute'], df['count'], marker='o')
plt.xticks(rotation=45)
plt.xlabel('Time (1-min intervals)')
plt.ylabel('Number of Records')
plt.title('Data Records per Minute')
plt.tight_layout()
plt.grid(True)
plt.show()
