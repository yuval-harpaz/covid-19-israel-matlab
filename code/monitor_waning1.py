import pandas as pd
import json
import urllib.request
import plotly.express as px
import plotly.graph_objects as go
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
ve = np.zeros((len(date)))
ve[:] = np.nan
for ii, d in enumerate(date1):
    mild[np.where(date == date1[ii])[0][0]] = df1['אחוז חולים קל לא מחוסנים'][ii]
for ii, d in enumerate(date2):
    total = df2['verified_amount_vaccinated'][ii]+df2['verified_amount_expired'][ii]+df2['verified_amount_not_vaccinated'][ii]
    cases[np.where(date == date2[ii])[0][0]] = np.round(100*df2['verified_amount_not_vaccinated'][ii]/total,1)
df = pd.DataFrame(date,columns=['date'])
df['% unvaccinated 60+ cases'] = cases
df['% unvaccinated mild hospitalizations'] = mild
df['cases'] = casesAll

##
dfVax = df2[['verified_amount_vaccinated','verified_amount_expired','verified_not_vaccinated_normalized']]
dfVax['NvaxCases'] = dfVax['verified_amount_vaccinated']+dfVax['verified_amount_expired']
dfVax['Nvax'] = df2['verified_amount_vaccinated']/df2['verified_vaccinated_normalized']*10**5
dfVax['Nexp'] = df2['verified_amount_expired']/df2['verified_expired_normalized']*10**5
dfVax['date'] = date2
sm = np.asarray(dfVax['Nvax'])
sm[65:160+5] = np.linspace(sm[65],sm[159+5],95+5)
for ii in range(269,len(sm)-1):
    sm[ii] = np.mean(sm[ii-6:ii+1])
sm[ii+1] = np.mean(sm[ii-6:ii])
dfVax['Nvax'] = sm
# fig1 = px.line(dfVax, x=date2, y=['Nvax', 'Nexp'])
# fig1.show()
smExp = np.asarray(dfVax['Nexp'])
smExp[0:185] = 0
smExp[300] = smExp[301]
ratioVax =  ((np.asarray(dfVax['verified_amount_vaccinated']) + \
            np.asarray(dfVax['verified_amount_expired'])) / \
            (sm + smExp))
dfVax['ratioVax'] = ratioVax
dfVax = dfVax.rolling(7, min_periods=7).mean()
VE = 100*(1-dfVax['ratioVax']/(dfVax['verified_not_vaccinated_normalized']/10**5))
num = len(VE)+8
ve[num:len(ve)+8] = VE
df['VE'] = ve
##
df7 = df.rolling(7, min_periods=3).mean().round(1)
# df7['cases (normalized)'] = np.round(100*df7['cases (normalized)']/np.max(df7['cases (normalized)']))
xl = [str(np.datetime_as_string(date[288]))[0:10], str(np.datetime_as_string(date[-1]))[0:10]]
df7['date'] = date
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', xaxis_range=xl)
fig = px.line(df7, x='date', y=['% unvaccinated 60+ cases', '% unvaccinated mild hospitalizations', 'VE'])
fig.layout = layout
fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 100],
                 tickfont=dict(color="#cc3333"), titlefont=dict(color="#cc3333"), title='% unvaccinated')
fig.add_trace(go.Scatter(x=df7['date'], y=df7['cases'], yaxis='y2', name='Cases', line_color='black'))
fig.update_layout(
    title_text="Looking for signs of waning immunity, Israel", font_size=15,
    yaxis2=dict(
        title="Cases",
        # titlefont=dict(color="#000000"),
        # tickfont=dict(color="#000000"),
        anchor="free",
        overlaying="y",
        side="right",
        position=1,
        gridcolor='lightgray',
        range=[0, 10000]
    ),)
fig['data'][0]['line']['color'] = '#cc3333'
fig['data'][0]['line']['dash'] = 'dot'
fig['data'][1]['line']['color'] = '#cc3333'
fig.layout['yaxis']['titlefont']['color']="#cc3333"
# fig.layout['xaxis']['range'] = xl
# fig.update_layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%m\n%Y", range=xl)
fig.layout['xaxis']['title'] = 'Month'
fig.show()

##
# dfVax = df2[['verified_amount_vaccinated','verified_amount_expired','verified_not_vaccinated_normalized']]
# dfVax['NvaxCases'] = dfVax['verified_amount_vaccinated']+dfVax['verified_amount_expired']
# dfVax['Nvax'] = df2['verified_amount_vaccinated']/df2['verified_vaccinated_normalized']*10**5
# dfVax['Nexp'] = df2['verified_amount_expired']/df2['verified_expired_normalized']*10**5
# dfVax['date'] = date2
# sm = np.asarray(dfVax['Nvax'])
# sm[65:160+5] = np.linspace(sm[65],sm[159+5],95+5)
# for ii in range(269,len(sm)-1):
#     sm[ii] = np.mean(sm[ii-6:ii+1])
# sm[ii+1] = np.mean(sm[ii-6:ii])
# dfVax['Nvax'] = sm
# # fig1 = px.line(dfVax, x=date2, y=['Nvax', 'Nexp'])
# # fig1.show()
# smExp = np.asarray(dfVax['Nexp'])
# smExp[0:185] = 0
# smExp[300] = smExp[301]
# ratioVax =  ((np.asarray(dfVax['verified_amount_vaccinated']) + \
#             np.asarray(dfVax['verified_amount_expired'])) / \
#             (sm + smExp))
# dfVax['ratioVax'] = ratioVax
# dfVax = dfVax.rolling(7, min_periods=7).mean()
# VE = 100*(1-dfVax['ratioVax']/(dfVax['verified_not_vaccinated_normalized']/10**5))
# dfVax['VE'] = VE
# dfVax = dfVax.rolling(7, min_periods=7).mean()
# fig1 = px.line(dfVax, x=date2, y=['VE'])
# fig1.show()
