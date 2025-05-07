import sqlite3
import folium
import pandas as pd

# データベースに接続
conn = sqlite3.connect('/Users/takahashiryosuke/Documents/and_inv/data/20241127_2507.db')
cursor = conn.cursor()

query = "SELECT location_latitude, location_longitude, userAccelerometerData_Z FROM users WHERE  userAccelerometerData_Z >= 0.3 || userAccelerometerData_Z <= -0.3"

# データをpandasのDataFrameとして読み込む
df = pd.read_sql_query(query, conn)

# データベース接続を閉じる
conn.close()

# 地図の中心を計算（データの平均位置）
center_lat = df['latitude'].mean()
center_lon = df['longitude'].mean()

# 地図を作成
m = folium.Map(location=[center_lat, center_lon], zoom_start=10)

# データポイントを地図にプロット
for idx, row in df.iterrows():
    folium.Marker(
        location=[row['latitude'], row['longitude']],
        popup=f"Value: {row['value']}",
        tooltip=f"Value: {row['value']}"
    ).add_to(m)

# 地図をHTMLファイルとして保存
m.save("map.html")

print("地図が生成され、map.htmlとして保存されました。")