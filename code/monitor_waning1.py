import pandas as pd
import json
import urllib.request
import plotly.express as px
import plotly.graph_objects as go
import numpy as np
url1 = 'https://data.gov.il/api/3/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd&limit=10000'
with urllib.request.urlopen(url1) as api1:
    data1 = json.loads(api1.read().decode())
win =21
def movmean(vec, win, nanTail=True):
    #  smooth a vector with a moving average. win should be an odd number of samples.
    #  vec is np.ndarray size (N,) or (N,0)
    #  to get smoothing of 3 samples back and 3 samples forward use win=7

    # if len(data.shape) == 2:
    #     vec = data[:, 0]
    padded = np.concatenate(
        (np.ones((win,)) * vec[0], vec, np.ones((win,)) * vec[-1]))
    smooth = np.convolve(padded, np.ones((win,)) / win, mode='valid')
    smooth = smooth[int(win / 2) + 1:]
    smooth = smooth[0:vec.shape[0]]
    if nanTail:
        smooth[-int(win / 2):-1] = np.nan
        smooth[-1] = np.nan
        smooth[0:int(win / 2)+1] = np.nan
    return smooth

# vec = np.zeros((30))
# vec[20] = 7
# vecsm = movmean(vec, 7)
# figts = px.line(y=[vec, vecsm])
# figts.show()

df1 = pd.DataFrame(data1['result']['records'])
date1 = pd.to_datetime(df1['תאריך'])

url2 = 'https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily'
df2 = pd.read_json(url2)

# dfY = df2.loc[df2["age_group"] == 'מתחת לגיל 60']
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
    cases[np.where(date == date2[ii])[0][0]] = np.round(100*df2['verified_amount_not_vaccinated'][ii]/total, 1)
df = pd.DataFrame(date,columns=['date'])
df['% unvaccinated of 60+ cases'] = cases
df['% unvaccinated of mild hospitalizations'] = mild
df['cases'] = casesAll

##
# dfVax = df2[['verified_amount_vaccinated','verified_amount_expired','verified_not_vaccinated_normalized']]
# dfVax['NvaxCases'] = dfVax['verified_amount_vaccinated']+dfVax['verified_amount_expired']
Nvax = np.asarray(df2['verified_amount_vaccinated']/df2['verified_vaccinated_normalized']*10**5)
Nexp = np.asarray(df2['verified_amount_expired']/df2['verified_expired_normalized']*10**5)
# dfVax['date'] = date2
sm = Nvax.copy()
sm[65:160+5] = np.linspace(sm[65],sm[159+5],95+5)
sm = movmean(sm, win)
sm[-3] = sm[-4]
sm[-2] = sm[-4]
sm[-1] = sm[-4]

smExp = Nexp.copy()
smExp[0:185] = 0
smExp[300] = smExp[301]
smExp = movmean(smExp, win)
smExp[-3] = smExp[-4]
smExp[-2] = smExp[-4]
smExp[-1] = smExp[-4]
ratioVax =  ((np.asarray(df2['verified_amount_vaccinated']) + \
            np.asarray(df2['verified_amount_expired'])) / \
            (sm + smExp))
# ratioVax = movmean(ratioVax, 7)
# dfVax = dfVax.rolling(7, min_periods=7).mean()
unvax = np.asarray(df2['verified_not_vaccinated_normalized'])
VE = 100*(1-ratioVax/(movmean(unvax, win, nanTail=False)/10**5))  # FIXME - too many nans

idx = [np.where(date == date2[0])[0][0], np.where(date == date2.loc[len(date2)-1])[0][0]+1]
ve[idx[0]:idx[1]] = movmean(VE, win, nanTail=False)


# df['VE'] = ve
##
df7 = df.rolling(win, min_periods=3).mean().round(1)
df7['VE for 60+ cases (2 doses or more)'] = ve
# df7['cases (normalized)'] = np.round(100*df7['cases (normalized)']/np.max(df7['cases (normalized)']))
xl = [str(np.datetime_as_string(date[288]))[0:10], str(np.datetime_as_string(date[-1]))[0:10]]
df7['date'] = date
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', xaxis_range=xl)
##
fig = px.line(df7, x='date', y=['VE for 60+ cases (2 doses or more)',  '% unvaccinated of mild hospitalizations', '% unvaccinated of 60+ cases'])
fig.layout = layout
fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 100],
                 tickfont=dict(color="#cc3333"), titlefont=dict(color="#cc3333"), title='% unvaccinated')
fig.add_trace(go.Scatter(x=df7['date'], y=df7['cases'], yaxis='y2', name='Cases', line_color='black'))
fig.update_layout(
    title_text="Looking for signs of waning immunity, Israel", font_size=15,
    yaxis2=dict(
        title="Cases",
        anchor="free",
        overlaying="y",
        side="right",
        position=1,
        zerolinecolor='lightgray',
        gridcolor='lightgray',
        range=[0, 10000]
    ),)
fig['data'][0]['line']['color'] = '#cc3333'
fig['data'][1]['line']['color'] = '#cc3333'
fig['data'][1]['line']['dash'] = 'dashdot'
fig['data'][2]['line']['color'] = '#cc3333'
fig['data'][2]['line']['dash'] = 'dot'
fig.layout['yaxis']['titlefont']['color'] = "#cc3333"
# fig.layout['xaxis']['range'] = xl
# fig.update_layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%m\n%Y", range=xl)
fig.layout['xaxis']['title'] = 'Month'
fig.layout['yaxis']['dtick'] = 10
fig.show()


