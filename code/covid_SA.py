import pandas as pd
import numpy as np
import urllib.request
import json

url1 = 'https://raw.githubusercontent.com/alex1770/Covid-19/master/VOCgrowth/EarlyOmicronEstimate/extracthospdata/SouthAfricaHospData.json'
with urllib.request.urlopen(url1) as api1:
    data1 = json.loads(api1.read().decode())
date = list(data1.keys())
region = list(data1[date[0]].keys())
field = list(data1[date[0]][region[0]].keys())
column = [[],[],[],[],[],[],[],[],[],[],[]]
for dd in date:
    for rr in region:
        column[0].append(dd)
        column[1].append(rr)
        for ii, ff in enumerate(field):
            column[2 + ii].append(np.nan)
            if rr in data1[dd].keys():
                if ff in data1[dd][rr].keys():
                    column[2+ii][-1] = data1[dd][rr][ff]

df = pd.DataFrame(column)
dft = df.transpose()
dft.columns = ['Date', 'Region']+field
dft.to_csv('SA.csv', index=False)
