import sqlite3
import folium
import pandas as pd

# データベースに接続
conn = sqlite3.connect('../data/20241127_2121.db')

df = pd.read_sql_query("SELECT * FROM users;", conn)

print(df)

# データベース接続を閉じる
conn.close()

# 地図の中心を計算（データの平均位置）
center_lat = df['location_latitude'].mean()
center_lon = df['location_longitude'].mean()

# 地図を作成
m = folium.Map(location=[center_lat, center_lon], zoom_start=18)

# データポイントを地図にプロット
for idx, row in df.iterrows():
    folium.Marker(
        location=[row['location_latitude'], row['location_longitude']],
        popup=f"Value: {row['useraccelerometerData_Z']}",
        tooltip=f"Value: {row['useraccelerometerData_Z']}"
    ).add_to(m)

# # 地図をHTMLファイルとして保存
m.save("20241127_2121map.html")

print("地図が生成され、map.htmlとして保存されました。")