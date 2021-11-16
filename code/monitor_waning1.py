import pandas as pd
import json
import urllib.request
import plotly.express as px
import numpy as np
url1 = 'https://data.gov.il/api/3/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd&limit=10000'
with urllib.request.urlopen(url1) as api1:
    data1 = json.loads(api1.read().decode())
df1 = pd.DataFrame(data1['result']['records'])
date1 = pd.to_datetime(df1['תאריך'])

url2 = 'https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily'
df2 = pd.read_json(url2)
df2 = df2.loc[df2["age_group"] == 'מעל גיל 60']
df2 = df2.reset_index()
date2 = pd.to_datetime(df2['day_date'].str.slice(0,10))
date = pd.concat([date1, date2])
date = np.unique(date)
date = np.sort(date)

url3 = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate'
df3 = pd.read_json(url3)
# df3['date'] = pd.to_datetime(df3['date'].dt.strftime('%Y-%m-%d'))
date3 = list(pd.to_datetime(df3['date'].dt.strftime('%Y-%m-%d')))
# date3 = list(date3.dt.strftime('%Y-%m-%d'))
# datee3 = np.datetime64(date3)
casesAll = np.zeros((len(date)))
casesAll[:] = np.nan
for ii, _ in enumerate(date3):
    if date3[ii] in date:
        casesAll[np.where(date == date3[ii])[0][0]] = df3['amount'][ii]
cases = np.zeros((len(date)))
cases[:] = np.nan
mild = np.zeros((len(date)))
mild[:] = np.nan
for ii, d in enumerate(date1):
    mild[np.where(date == date1[ii])[0][0]] = df1['אחוז חולים קל לא מחוסנים'][ii]
for ii, d in enumerate(date2):
    total = df2['verified_amount_vaccinated'][ii]+df2['verified_amount_expired'][ii]+df2['verified_amount_not_vaccinated'][ii]
    cases[np.where(date == date2[ii])[0][0]] = np.round(100*df2['verified_amount_not_vaccinated'][ii]/total,1)
df = pd.DataFrame(date,columns=['date'])
df['% unvaccinated 60+ cases'] = cases
df['% unvaccinated mild hospitalizations'] = mild
df['cases (normalized)'] = np.round(100*casesAll/np.max(casesAll))
df7 = df.rolling(7, min_periods=3).mean().round(1)
xl = [date[288], date[-1]]
fig = px.line(df7, x=date, y=['% unvaccinated 60+ cases', '% unvaccinated mild hospitalizations',
                              'cases (normalized)'])
fig.update_layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', xaxis_range=xl)
fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 100])
fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%m\n%Y", range=xl)
fig.show()
