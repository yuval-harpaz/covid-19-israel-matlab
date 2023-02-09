
from matplotlib import cm
import folium
import pandas as pd
# df = pd.read_csv('/home/innereye/Documents/earthquake2000.csv')
df = pd.read_csv('/home/innereye/Documents/rslt_7570.csv')
center = [df['Lat'].mean(), df['Long'].mean()]
map = folium.Map(location=center, zoom_start=7)
for ii in range(len(df)):
    sz = df['Md'][ii]
    lat = df['Lat'][ii]
    lon = df['Long'][ii]
    dt = df['DateTime'][ii]
    if int(dt[:4]) == 2023:
        color = 'red'
    elif int(dt[:4]) == 2022:
        color = 'blue'
    else:
        color = 'green'
    folium.CircleMarker(location=[lat, lon], color=color, radius=3, fill=True).add_to(map)
map.save("israel_map1.html")

map = folium.Map(location=center, zoom_start=7)
for ii in range(len(df)):
    sz = df['Md'][ii]
    lat = df['Lat'][ii]
    lon = df['Long'][ii]
    dt = df['DateTime'][ii]
    folium.CircleMarker(location=[lat, lon], color='red', radius=1, fill=True).add_to(map)
map.save("israel_map2.html")