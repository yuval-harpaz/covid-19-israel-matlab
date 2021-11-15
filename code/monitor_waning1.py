import pandas as pd
import json
import urllib.request
import plotly.express as px

url1 = 'https://data.gov.il/api/3/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd&limit=10000'
with urllib.request.urlopen(url1) as api1:
    data1 = json.loads(api1.read().decode())
df1 = pd.DataFrame(data1['result']['records'])
date1 = pd.to_datetime(df1['תאריך'])

url2 = 'https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily'
df2 = pd.read_json(url2)
df2 = df2.loc[df2["age_group"] == 'מעל גיל 60']
date2 = pd.to_datetime(df2['day_date'])
date = pd.concat([date1.strftime(),date2])
pd.io.formats.style.format.strftime('%Y-%m')  (date1)
date = pd.so
date.unique()
fig = px.line(x=date1,y=df1['אחוז חולים קל לא מחוסנים'])

fig.show()