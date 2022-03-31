import pandas as pd
import numpy as np
from dash import dcc, callback_context, html, Dash
from dash.dependencies import Input, Output, State
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
import urllib.request
import json


def movmean(vec, win, nanTail=False):
    #  smooth a vector with a moving average. win should be an odd number of samples.
    #  vec is np.ndarray size (N,) or (N,0)
    #  to get smoothing of 3 samples back and 3 samples forward use win=7
    vec = vec.astype('float')
    smooth = vec.copy()
    if win > 1:
        if nanTail:
            smooth[:] = np.nan
        for ii in range(int(win/2), len(vec)-int(win/2)):
            smooth[ii] = np.nanmean(vec[ii-int(win/2):ii+int(win/2)+1])
    return smooth

# if os.path.isfile('/home/innereye/Downloads/VerfiiedVaccinationStatusDaily'):
#     api = '/home/innereye/Downloads/'
#     dfAge = pd.read_csv(
#         '/home/innereye/covid-19-israel-matlab/data/Israel/cases_by_age.csv')
# else:
api = 'https://datadashboardapi.health.gov.il/api/queries/'
dfAge = pd.read_csv('https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/cases_by_age.csv')
dfTS = pd.read_json(api+'hospitalizationStatus')
cn = list(dfTS.columns)
cn[0] = 'date'
dfTS.columns = cn
# dfTS = dfTS[dfTS.duplicated(['date'], keep=False)]
dfTS = dfTS.drop_duplicates(subset=['date'], keep='first')
dfTS.sort_values('date')
dfTS['date'] = dfTS['date'].str.slice(start=None, stop=10)
hospitalizationStatus = dfTS.to_csv(index=False)

url = [api+'VerfiiedVaccinationStatusDaily',
       api+'SeriousVaccinationStatusDaily',
       api+'deathVaccinationStatusDaily']
measure = ['Cases', 'New Severe', 'Deaths']
varsNorm = [['verified_vaccinated_normalized', 'verified_expired_normalized', 'verified_not_vaccinated_normalized'],
            ['new_serious_vaccinated_normalized', 'new_serious_expired_normalized', 'new_serious_not_vaccinated_normalized'],
            ['death_vaccinated_normalized', 'death_expired_normalized', 'death_not_vaccinated_normalized']]
varsAbs = [['verified_amount_vaccinated', 'verified_amount_expired', 'verified_amount_not_vaccinated'],
           ['new_serious_amount_vaccinated', 'new_serious_amount_expired', 'new_serious_amount_not_vaccinated'],
           ['death_amount_vaccinated', 'death_amount_expired', 'death_amount_not_vaccinated']]

dfsNorm = [[], [], []]
dfsAbs = [[], [], []]
downloads = []
for ii in [0, 1, 2]:
    dfs = pd.read_json(url[ii])
    downloads.append(dfs.copy())
    downloads[-1]['day_date'] = downloads[-1]['day_date'].str.slice(0, 10)
    downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('מעל גיל 60', 'over 60')
    downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('מתחת לגיל 60', 'under 60')
    downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('כלל האוכלוסיה', 'all')
    dfs['date'] = pd.to_datetime(dfs['day_date'])
    dfsNorm[ii] = dfs.rename(columns={varsNorm[ii][0]: 'vaccinated', varsNorm[ii][1]: 'expired', varsNorm[ii][2]: 'unvaccinated'})
    dfsNorm[ii] = dfsNorm[ii][['date', 'day_date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
    dfsAbs[ii] = dfs.rename(columns={varsAbs[ii][0]: 'vaccinated', varsAbs[ii][1]: 'expired', varsAbs[ii][2]: 'unvaccinated'})
    dfsAbs[ii] = dfsAbs[ii][['date', 'day_date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
# writer = pd.ExcelWriter(engine='xlsxwriter')

shifts = [0, 11, 21]
ages2 = ['מתחת לגיל 60', 'מעל גיל 60']
yy = np.zeros((3, 2, 2, 2))
dd = [[], [], []]
for im in [0, 1, 2]:  # cases, severe, deaths
    for ia in [0, 1]:  # young, old
        df_age1 = dfsAbs[im].loc[dfsAbs[im]['age_group'] == ages2[ia]]
        df_age1.reset_index()
        for iv, vax in enumerate(['vaccinated','unvaccinated']):
            meas = np.asarray(df_age1[vax])
            day_date = np.asarray(df_age1['day_date'])
            d0 = np.where(day_date == '2021-06-20T00:00:00.000Z')[0][0]
            d1 = np.where(day_date == '2021-10-21T00:00:00.000Z')[0][0]
            d2 = np.where(day_date == '2021-12-11T00:00:00.000Z')[0][0]
            yy[im, ia, 0, iv] = np.sum(meas[d0+shifts[im]:d1+shifts[im]])
            yy[im, ia, 1, iv] = np.sum(meas[d2+shifts[im]:-shifts[-im-1]-1])
    dd[im] = [str(day_date[d0+shifts[im]])[:10],
              str(day_date[d1+shifts[im]])[:10],
              str(day_date[d2+shifts[im]])[:10],
              str(day_date[-shifts[-im-1]-1])[:10]]

hs = dfTS.to_numpy()
deathTot = hs[:, np.where(dfTS.columns == 'countDeath')[0][0]]
severeTot = hs[:, np.where(dfTS.columns == 'countSeriousCriticalCum')[0][0]]
severeTot[1:] = np.diff(severeTot)
dd0 = np.where(hs[:, 0] == '2021-06-20')[0][0]
dd1 = np.where(hs[:, 0] == '2021-10-21')[0][0]
dd2 = np.where(hs[:, 0] == '2021-12-11')[0][0]
# yy[im, ia, 0, iv] = np.sum(meas[d0+shifts[im]:d1+shifts[im]])
# yy[im, ia, 1, iv] = np.sum(meas[d2+shifts[im]:-shifts[-im-1]-1])
dfWaveTot = pd.DataFrame([['Delta', 'deaths', np.sum(deathTot[dd0+shifts[2]:dd1+shifts[2]])],
                          ['Omi', 'deaths', np.sum(deathTot[dd2+shifts[2]:])],
                          ['Delta', 'severe', np.sum(severeTot[dd0+shifts[1]:dd1+shifts[1]])],
                          ['Omi', 'severe', np.sum(severeTot[dd2+shifts[1]:])]],
                         columns=['wave', 'measure', 'patients'])

figWaves = px.histogram(dfWaveTot, x="measure", y="patients", color='wave', barmode='group')
figWaves.data[0].text = np.round(figWaves.data[0]['y'], 2)
figWaves.data[1].text = np.round(figWaves.data[1]['y'], 2)
figWaves.layout['yaxis']['title']['text'] = 'patients'
figWaves.layout['xaxis']['title']['text'] = ''
figWaves['data'][0]['marker']['color'] = 'green'
figWaves['data'][1]['marker']['color'] = 'purple'
figWaves['layout']['title'] = 'Deaths and severe patients (all ages)'
figWaves['layout']['title']['x'] = 0.45
figWaves['layout']['title']['font_color'] = "black"
figWaves['layout']['title']['xanchor'] = 'center'

# dfWaveTot = pd.DataFrame([['Delta', 'deaths', yy[2, 0, 0, 0]+yy[2, 1, 0, 0]+],
#                           ['Omi', 'vaccinated', yy[2, age, 1, 0]/yy[1, age, 1, 0]],
#                           ['Delta', 'unvaccinated', yy[2, age, 0, 1]/yy[1, age, 0, 1]],
#                           ['Omi', 'unvaccinated', yy[2, age, 1, 1]/yy[1, age, 1, 1]]],
def make_ratios(age=1):
    dfRat = pd.DataFrame([['Delta', 'vaccinated', yy[2, age, 0, 0]/yy[1, age, 0, 0]],
                          ['Omi', 'vaccinated', yy[2, age, 1, 0]/yy[1, age, 1, 0]],
                          ['Delta', 'unvaccinated', yy[2, age, 0, 1]/yy[1, age, 0, 1]],
                          ['Omi', 'unvaccinated', yy[2, age, 1, 1]/yy[1, age, 1, 1]]],
                         columns=['wave', 'vaccination', 'death ratio'])
    dfSD = pd.DataFrame([['Delta', 'vaccinated', 'deaths', yy[2, age, 0, 0]],
                         ['Delta', 'vaccinated', 'severe', yy[1, age, 0, 0]],
                         ['Omi', 'vaccinated', 'deaths', yy[2, age, 1, 0]],
                         ['Omi', 'vaccinated', 'severe', yy[1, age, 1, 0]],
                         ['Delta', 'unvaccinated', 'deaths', yy[2, age, 0, 1]],
                         ['Delta', 'unvaccinated', 'severe', yy[1, age, 0, 1]],
                         ['Omi', 'unvaccinated', 'deaths', yy[2, age, 1, 1]],
                         ['Omi', 'unvaccinated', 'severe', yy[1, age, 1, 1], ]],
                         columns=['wave', 'vaccination', 'measure', 'value'])
    if age == 1:
        ag = ' 60+'
    else:
        ag = ' <60'
    # figDelta = go.Figure()
    # figDelta.add_trace(go.Histogram(dfSD[dfSD['wave'] == 'Delta'], x="vaccination", y="value", color='measure',
    #                         barmode='group'))
    figDelta = px.histogram(dfSD[dfSD['wave'] == 'Delta'], x="vaccination", y="value", color='measure', barmode='group')
    figDelta.data[0].text = figDelta.data[0]['y']
    figDelta.data[1].text = figDelta.data[1]['y']
    figOmi = px.histogram(dfSD[dfSD['wave'] == 'Omi'], x="vaccination", y="value", color='measure', barmode='group')
    figOmi.data[0].text = figOmi.data[0]['y']
    figOmi.data[1].text = figOmi.data[1]['y']
    figR = px.histogram(dfRat, x="vaccination", y="death ratio", color='wave', barmode='group')
    figR.data[0].text = np.round(figR.data[0]['y'], 2)
    figR.data[1].text = np.round(figR.data[1]['y'], 2)

    figOmi.layout['yaxis']['title']['text'] = 'patients'+ag
    figOmi.layout['xaxis']['title']['text'] = ''
    figOmi['data'][0]['marker']['color'] = 'black'
    figOmi['layout']['title'] = 'Wave V'
    figOmi['layout']['title']['x'] = 0.45
    figOmi['layout']['title']['font_color'] = "purple"
    figOmi['layout']['title']['xanchor'] = 'center'

    figDelta.layout['yaxis']['title']['text'] = 'patients'+ag
    figDelta.layout['xaxis']['title']['text'] = ''
    figDelta['data'][0]['marker']['color'] = 'black'
    figDelta['layout']['title'] = 'Wave IV'
    figDelta['layout']['title']['x'] = 0.45
    figDelta['layout']['title']['font_color'] = "green"
    figDelta['layout']['title']['xanchor'] = 'center'

    figR.layout['yaxis']['title']['text'] = 'death to severe ratio'
    figR.layout['xaxis']['title']['text'] = ''
    figR['data'][0]['marker']['color'] = 'green'
    figR['data'][1]['marker']['color'] = 'purple'
    figR['layout']['title'] = 'Death ratio'+ag
    figR['layout']['title']['x'] = 0.45
    figR['layout']['title']['font_color'] = "black"
    figR['layout']['title']['xanchor'] = 'center'
    return figDelta, figOmi, figR

updatemenus = [
    dict(
        type="buttons",
        direction="down",
        buttons=list([
            dict(
                args=[{'yaxis.type': 'linear'}],
                label="Linear",
                method="relayout"
            ),
            dict(
                args=[{'yaxis.type': 'log'}],
                label="Log",
                method="relayout"
            )
        ])
    ),
]
x = dfAge['date']
x = pd.to_datetime(x)
yyAge = np.asarray(dfAge.iloc[:, 1:11])
label = ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80-89', '90+']
color = ['#E617E6', '#6A17E6', '#1741E6', '#17BEE6', '#17E6BE', '#17E641', '#6AE617', '#E6E617', '#E69417', '#E61717']
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', legend={'traceorder': 'reversed'})
layout1 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
fig1 = go.Figure(layout=layout1)
for ii, line in enumerate(yyAge.T):
    fig1.add_trace(go.Scatter(x=x, y=line, mode='lines', line_color=color[ii], name=label[ii]))

fig1.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
fig1.update_yaxes(range=(20, int(10000*np.ceil(np.nanmax(yyAge)/10000))))
fig1.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%b\n%Y")
fig1.update_layout(title_text="Weekly cases by age", font_size=15, updatemenus=updatemenus)


def make_figs3(df_in, meas, age_gr='מעל גיל 60', smoo='sm', nrm=', per 100k ', start_date=[], end_date=[], loglin='linear'):
    df_age = df_in.loc[df_in["age_group"] == age_gr]
    # date = df_age['date']
    mx = np.max(df_age.max()[3:6])*1.05
    if loglin == 'log':
        mx = np.ceil(np.log(mx)/np.log(10))
    # xl = [df_age.iloc[0,0], df_age.iloc[-1,0]]
    xl = [start_date, end_date]
    if smoo == 'sm':
        for yts in ['vaccinated', 'expired', 'unvaccinated']:
            yybef = np.asarray(df_age[yts])
            yyaft = np.round(movmean(yybef, 7, nanTail=True), 1)
            yyaft[-4] = np.nan
            df_age[yts] = yyaft
        # df_age = df_age.rolling(7, min_periods=7).mean().round(1)
        # df_age['date'] = date - pd.to_timedelta(df_age.shape[0] * [3], 'd')
    fig = px.line(df_age, x="date", y=['vaccinated', 'expired', 'unvaccinated'])
    fig.update_traces(hovertemplate="%{y}")
    fig['data'][0]['line']['color'] = '#0e7d7d'
    fig['data'][1]['line']['color'] = '#b9c95b'
    fig['data'][2]['line']['color'] = '#2fcdfb'
    fig.layout = layout
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, mx], type=loglin)
    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=xl, dtick="M1", tickformat="%d/%m\n%Y")
    if age_gr == 'מעל גיל 60':
        txt60 = '(60+)'
    else:
        txt60 = '(<60)'
    fig.update_layout(title_text=meas+' by vaccination status'+nrm+txt60, font_size=15, hovermode="x unified",
                      legend=dict(
                          yanchor="top",
                          y=1.1,
                          xanchor="left",
                          x=0.05
                      ),
                      )
    return fig

## waning
url1 = 'https://data.gov.il/api/3/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd&limit=10000'
with urllib.request.urlopen(url1) as api1:
    data1 = json.loads(api1.read().decode())
win = 7


df1 = pd.DataFrame(data1['result']['records'])
date1 = np.asarray(pd.to_datetime(df1['תאריך']))
url2 = 'https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily'
df2 = pd.read_json(url2)
df2 = df2.loc[df2["age_group"] == 'מעל גיל 60']
df2 = df2.reset_index()
date2 = np.asarray(pd.to_datetime(df2['day_date'].str.slice(0,10)))
date = np.concatenate([date1, date2])
date = np.unique(date)
date = np.sort(date)
url3 = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate'
df3 = pd.read_json(url3)
date3 = list(pd.to_datetime(df3['date'].dt.strftime('%Y-%m-%d')))
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
dfAge = pd.DataFrame(date, columns=['date'])
dfAge['% unvaccinated of 60+ cases'] = cases
dfAge['% unvaccinated of mild hospitalizations'] = mild
dfAge['cases'] = movmean(casesAll, 7, True)
Nvax = np.asarray(df2['verified_amount_vaccinated']/df2['verified_vaccinated_normalized']*10**5)
Nexp = np.asarray(df2['verified_amount_expired']/df2['verified_expired_normalized']*10**5)
sm = Nvax.copy()
sm[65:160+5] = np.linspace(sm[65], sm[159+5], 95+5)
sm = movmean(sm, win)
sm[-3] = sm[-4]
sm[-2] = sm[-4]
sm[-1] = sm[-4]
sm = np.round(sm, 1)
smExp = Nexp.copy()
smExp[0:185] = 0
smExp[300] = smExp[301]
# smExp = movmean(smExp, win)
smExp[-3] = smExp[-4]
smExp[-2] = smExp[-4]
smExp[-1] = smExp[-4]
unvax = np.asarray(df2['verified_not_vaccinated_normalized'])

date_ve = np.sort(np.unique(np.asarray(pd.to_datetime(dfsNorm[0]['day_date'].str.slice(0,10)))))
month_u = date2.astype('datetime64[M]').astype(int)
month = date2.astype('datetime64[M]').astype(int) % 12 + 1
year = date2.astype('datetime64[Y]').astype(int) + 1970
date_m = np.array(np.unique(month_u), dtype='datetime64[M]')
ms = measure.copy()
ms.append('Date')
# ve_by_month = [{'heb': ages2[0], 'eng': 'under 60', 'data': dict(zip(ms, [[], [], [], date_m]))},
#                {'heb': ages2[1], 'eng': 'over 60', 'data': dict(zip(ms, [[], [], [], date_m]))}]
ve_ages = ['60+','<60']
ve_list = [[], []]
dfVE2 = []
for iage, age in enumerate(ages2):
    for imon, mon in enumerate(np.unique(month_u)):
        for imea, mea in enumerate(measure):
            dfve = dfsNorm[imea].copy()
            dfve = dfve.loc[dfsNorm[imea]['age_group'] == age]
            dfve.reset_index(drop=True, inplace=True)
            vem = 1-dfve['vaccinated'][month_u == mon].sum() / dfve['unvaccinated'][month_u == mon].sum()
            ve_list[iage].append([date_m[imon], mea, vem])
    dfVE2.append(pd.DataFrame(ve_list[iage], columns = ['Date', 'measure', 'patients']))
            # ve_by_month[iage]['data'][mea].append(vem)

# for iage, age in enumerate(ages2):
#     for imea, mea in enumerate(measure):
#         dfve = dfsNorm[imea].copy()
#         dfve = dfve.loc[dfsNorm[imea]['age_group'] == age]
#         dfve.reset_index(drop=True, inplace=True)
#         for mon in np.unique(month_u):
#             vem = 1-dfve['vaccinated'][month_u == mon].sum() / dfve['unvaccinated'][month_u == mon].sum()
#             ve_by_month[iage]['data'][mea].append(vem)

figW60 = px.histogram(dfVE2[0], x="Date", y='patients', color='measure', barmode='group', nbins=len(date_m))
figW60.update_layout(bargap=0.2)
# figW60.show()
# print('okay')



def makeVE(age_gr):
    # dfW60 = dfsNorm[0].copy()
    if age_gr == 'מעל גיל 60':
        tit = "Crude VE (60+) vs cases per 100k, for recently vaccinated (<6m) and unvaccinated"
        ag = 0
    else:
        tit = "Crude VE (<60) vs cases per 100k, for recently vaccinated (<6m) and unvaccinated"
        ag = 1

    figW60 = px.histogram(dfVE2[ag], x="Date", y='patients', color='measure', barmode='group')
    figWaves.data[0].text = np.round(figWaves.data[0]['y'], 2)
    figWaves.data[1].text = np.round(figWaves.data[1]['y'], 2)
    figWaves.layout['yaxis']['title']['text'] = 'patients'
    figWaves.layout['xaxis']['title']['text'] = ''
    figWaves['data'][0]['marker']['color'] = 'green'
    figWaves['data'][1]['marker']['color'] = 'purple'
    figWaves['layout']['title'] = 'Deaths and severe patients (all ages)'
    figWaves['layout']['title']['x'] = 0.45
    figWaves['layout']['title']['font_color'] = "black"
    figWaves['layout']['title']['xanchor'] = 'center'

    # layoutW60 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)',
    #                       xaxis_range=xlW60)  # , xaxis_range=xl)
    # # figW60 = go.Figure(layout=layoutW60)
    # figW60.add_trace(go.Scatter(x=date2ve, y=veW60, name='VE                                      ', line_color='#222277'))
    # figW60.add_trace(go.Scatter(x=date2ve[-4:], y=veW60[-4:], name='not final', line_color='#aaaaaa'))
    # figW60.update_yaxes(range=[-50, 100], dtick=10, zeroline=True, zerolinecolor='#aaaaaa', gridcolor='#bdbdbd')
    # figW60.add_trace(go.Scatter(x=date2ve, y=vaccW60, yaxis='y2', name='vaccinated   ', line_color='#99ff99'))
    # figW60.update_xaxes(dtick="M1", tickformat="%d-%b \n%Y", gridcolor='#bdbdbd')
    # figW60.update_layout(
    #     yaxis_title="crude VE (%)",
    #     yaxis=dict(
    #         tickmode='linear',
    #         zeroline=True,
    #     ),
    #     legend=dict(
    #         yanchor="top",
    #         y=1.1,
    #         xanchor="left",
    #         x=1.05
    #     ),
    #     title_text=tit, font_size=15, hovermode="x unified",
    #     yaxis2=dict(
    #         title="Cases per 100k",
    #         color='#ff9999',
    #         anchor="free",
    #         overlaying="y",
    #         side="right",
    #         position=1,
    #         zerolinecolor='lightgray',
    #         gridcolor='lightgray',
    #         zeroline=True,
    #         range=[0, 150]
    #     ))
    # figW60.add_trace(go.Scatter(x=date2ve, y=unvaccW60, yaxis='y2', name='unvaccinated', line_color='#ff9999'))
    return figW60
#%% world
JH = pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv')
JHC = pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv')

pop = pd.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/scripts/input/un/population_latest.csv')
JHT = JH.T
jhn = JHT.to_numpy()
jhc = JHC.T.to_numpy()
if jhc.shape != jhn.shape:
    raise Exception('JH different sizes')

# owid = pd.read_csv('https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv?raw=true')
JHisr = JH[JH['Country/Region'] == 'Israel']
date_str = list(JHisr.columns[4:])
dateW = []
for ii, dd in enumerate(date_str):
    parsed = dd.split('/')
    for dm in [0, 1]:
        if len(parsed[dm]) == 1:
            parsed[dm] = '0'+parsed[dm]
    dateW.append(np.datetime64('20'+parsed[2]+'-'+parsed[0]+'-'+parsed[1]))
dateW = np.asarray(dateW)
WHO = pd.read_csv('https://covid19.who.int/WHO-COVID-19-global-data.csv')
wc = np.unique(np.asarray(WHO['Country']))
WHOisr = WHO[WHO['Country'] == 'Israel']
dateWho = np.asarray(list(WHOisr['Date_reported']))
# deathWho = np.asarray(list(WHOisr['New_deaths']))
# casesWho = np.asarray(list(WHOisr['New_cases']))
fixJH = np.asarray([['US', 'United States'], ['Korea, South', 'South Korea']])
for ii in range(len(fixJH)):
    col = np.where(jhn[1, :] == fixJH[ii, 0])[0][0]
    jhn[1, col] = fixJH[ii, 1]
country = []
pop_jh = []
for cntr in list(pop['entity']):
    if cntr in jhn[1, :]:  # and pop['population'][pop['entity'] == cntr].to_numpy()[0] > 10**6:
        country.append(cntr)
        pop_jh.append(pop['population'][pop['entity'] == cntr].to_numpy()[0])
pop_jh = np.asarray(pop_jh)

date_who_list = np.asarray(WHO['Date_reported'])
death_who_list = np.asarray(WHO['New_deaths'])
cases_who_list = np.asarray(WHO['New_cases'])
country_who_list = np.asarray(WHO['Country'])
country_whu = np.unique(country_who_list)
# for ii in country_whu:
#     if 'ussia' in ii:
#         print(ii)
WHO = WHO.replace('Republic of Korea', 'South Korea')
WHO = WHO.replace('United States of America', 'United States')
WHO = WHO.replace('Russian Federation', 'Russia')
WHO = WHO.replace('The United Kingdom', 'United Kingdom')
country_who_list = np.asarray(WHO['Country'])
country_whu = np.unique(country_who_list)
country_common = []
pop_common = []
for ii, cntr in enumerate(country):
    if cntr in list(WHO['Country']):
        country_common.append(cntr)
        pop_common.append(pop_jh[ii])




#%% compute deaths per million
day0 = np.where(date_who_list == str(dateW[0]))[0][0]
day1 = np.where(date_who_list == str(dateW[-1]))[0]
if len(day1) == 0:
    day1 = np.where(date_who_list == str(dateW[-2]))[0]
if len(day1) == 0:
    day1 = np.where(date_who_list == str(dateW[-3]))[0]
day1 = day1[0]+1
dpm = {'WHO': {}, 'JH': {}}
lastWeek = []
cpm = {'WHO': {}, 'JH': {}}
lastWeekC = []
lastWeekRise = []
for cc, ctr in enumerate(country_common):
    # print(str(cc)+' of '+str(len(country_common))+' '+ctr)
    pp = list(pop['population'][pop['entity'] == ctr])
    if len(pp) == 1:
        pp = pp[0]
    else:
        raise Exception('population for '+ctr+' wrong')
    row = np.where(country_who_list == country_common[cc])[0]
    yyWcum = np.sum(jhn[4:, jhn[1, :] == ctr], axis=1)
    yyWcum = yyWcum / pp * 10 ** 6
    yyW = yyWcum.copy()
    yyW[1:] = np.diff(yyWcum)
    yyW =yyW
    yyW = yyW.astype(float)
    yyW[yyW > 200] = np.nan
    dpm['JH'][ctr] = {}
    dpm['JH'][ctr]['daily'] = yyW
    dpm['JH'][ctr]['cum'] = yyWcum
    yyWc = np.sum(jhc[4:, jhc[1, :] == ctr], axis=1)
    yyWc = yyWc / pp * 10 ** 6
    yyWd = yyWc.copy()
    yyWd[1:] = np.diff(yyWc)
    yyWd = yyWd.astype(float)
    bad = np.where((yyWd[1:-1]-yyWd[0:-2] > 15000) & (yyWd[1:-1]-yyWd[2:] > 15000))[0]
    if len(bad) > 0:
        yyWd[bad+1] = np.nan
    cpm['JH'][ctr] = {}
    cpm['JH'][ctr]['daily'] = np.round(yyWd)
    cpm['JH'][ctr]['cum'] = np.round(yyWc.astype('float'))

    yW = death_who_list[row][day0:day1]
    yW = np.asarray(yW) / pp * 10 ** 6
    yWcum = np.cumsum(yW)
    yW[yW > 200] = np.nan
    dpm['WHO'][ctr] = {}
    dpm['WHO'][ctr]['daily'] = yW
    dpm['WHO'][ctr]['cum'] = yWcum
    lastWeek.append(np.nanmean(yW[-7:]))
    yWc = cases_who_list[row][day0:day1]
    yWc = np.asarray(yWc) / pp * 10 ** 6
    yWccum = np.cumsum(yWc)
    bad = np.where((yWc[1:-1] - yWc[0:-2] > 15000) & (yWc[1:-1]-yWc[2:] > 15000))[0]
    if len(bad) > 0:
        yWc[bad+1] = np.nan
    cpm['WHO'][ctr] = {}
    cpm['WHO'][ctr]['daily'] = np.round(yWc)
    cpm['WHO'][ctr]['cum'] = np.round(yWccum.astype('float'))
    lastWeekC.append(np.nanmean(yWc[-7:]))
    lastWeekRise.append(np.nanmean(yWc[-7:])-np.nanmean(yWc[-14:-7]))
    # lastWeekRise.append(np.nanmean(yWc[-7:])/np.nanmean(yWc[-14:-7]))


maxCountry = 3*10**5
order = np.argsort(lastWeek)
order = order[::-1]
large = []
c = -1
while len(large) < 10:
    c += 1
    if pop_common[order[c]] > maxCountry:
        large.append(country_common[order[c]])
country_v = large
orderC = np.argsort(lastWeekC)
orderC = orderC[::-1]
largeC = []
c = -1
while len(largeC) < 10:
    c += 1
    if pop_common[orderC[c]] > maxCountry:
        largeC.append(country_common[orderC[c]])
country_c = largeC

orderRise = np.argsort(lastWeekRise)
orderRise = orderRise[::-1]
largeRise = []
c = -1
while len(largeRise) < 10:
    c += 1
    if pop_common[orderRise[c]] > maxCountry:
        largeRise.append(country_common[orderRise[c]])
country_Rise = largeRise

# country_v = ['Canada', 'Germany', 'India', 'Italy', 'United Kingdom', 'United States', 'Israel']
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
jet = ['#0000AA', '#0000FF', '#0055FF', '#00AAFF', '#00FFFF', '#55FFAA', '#AAFF55', '#FFFF00', '#FFAA00', '#FF5500'][::-1]*5
def make_figW(srcl, cum, smooth, start_date, end_date, checklist, measure='deaths'):
    figW = go.Figure(layout=layout)
    if measure == 'deaths':
        data = dpm[srcl]
    else:
        data = cpm[srcl]
    xl = [dateW[start_date], dateW[end_date]]
    titW = 'Daily '+measure+' per million. '
    color_count = -1
    if srcl == 'WHO':
        td = -1
    else:
        td = 0
    for ct in checklist:
        yyy = data[ct][cum]
        if smooth == 'sm' and cum == 'daily':
            yyy = np.round(movmean(yyy, 7, nanTail=False), 2)
            yyy[-4:] = np.nan
        if cum == 'cum':
            # yyy = np.cumsum(yyy)
            titW = 'Cumulative '+measure+' per million. '

        if ct == 'Israel':
            color_trace = '#000000'
        else:
            color_count += 1
            color_trace = jet[color_count]
        figW.add_trace(go.Scatter(x=dateW+np.timedelta64(td), y=yyy, mode='lines', name=ct, line={'color': color_trace}))
    figW.update_layout(font_size=14, showlegend=True, hovermode="x unified",
                       hoverlabel=dict(bgcolor='rgba(255,255,255,0.25)',
                       bordercolor='rgba(255,255,255,0.25)',
                       font=dict(color='black')),
                       title_text=titW,
                       # sequential='hot',
                       legend=dict(
                           yanchor="top",
                           y=0.99,
                           xanchor="left",
                           x=-0.2
                       ),
                       margin=dict(
                           l=150,
                           r=250,
                           b=100,
                           t=100,
                           pad=4
                       ),
                       )
    figW.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=xl, dtick="M1", tickformat="%d/%m\n%Y")
    figW.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
    # figW.layout.colorscale['sequential'] = 'hot'
    figW.layout.colorscale.update()
    return figW


app = Dash(
    __name__,
    external_stylesheets=[dbc.themes.BOOTSTRAP],
    # external_stylesheets=['https://codepen.io/chriddyp/pen/bWLwgP.css'],
    meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
)
server = app.server
app.layout = html.Div([
    html.Div([
        html.Div([
            html.H3('Israel COVID19 data'),
            html.A('zoom in (click and drag) and out (double click), adapted from the MOH '),
            html.A('dashboard', href="https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral", target='_blank'),
            html.A(' by '), html.A('@yuvharpaz.', href="https://twitter.com/yuvharpaz", target='_blank'),html.A(' '),
            html.A(' code ', href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/covid_dash1.py", target='_blank'),
            html.Div([
                html.A('To get hospitalizations data click  '),
                html.Button("Download", id="btn-download-txt"),
                dcc.Download(id="download-text"),
                html.A(' '),
                html.A('<json>', href='https://datadashboardapi.health.gov.il/api/queries/hospitalizationStatus', target='_blank'),
                html.A('. Download vaccination status for  '),
                html.Button("Cases", id="btn-inf"),
                dcc.Download(id="download-inf"),
                html.A(' '),
                html.Button("Severe", id="btn-sev"),
                dcc.Download(id="download-sev"),
                html.A('  '),
                html.Button("Deaths", id="btn-dea"),
                dcc.Download(id="download-dea")]
            ),
            html.Br(), html.A('other dashboards: '),
            html.A('South Africa',
                   href="https://sa-covid.herokuapp.com/",
                   target='_blank'),
            html.A(' , '),
            html.A('England',
                   href="https://uk-covid.herokuapp.com/",
                   target='_blank'),
            html.Br(), html.Br()
        ]),
        dbc.Row([
            dbc.Col(dcc.Graph(id='infected'), lg=4),
            dbc.Col(dcc.Graph(id='severe'), lg=4),
            dbc.Col(dcc.Graph(id='death'), lg=4)
        ]),
        dbc.Row([
            dbc.Col([dcc.RadioItems(id='loglin',
                options=[
                    {'label': 'lin', 'value': 'linear'},
                    {'label': 'log', 'value': 'log'}
                ],
                value='linear',
                labelStyle={'display': 'inline-block'}
                )], lg=1),
            dbc.Col([dcc.RadioItems(id='age',
                options=[
                    {'label': '60+', 'value': 'מעל גיל 60'},
                    {'label': '<60', 'value': 'מתחת לגיל 60'}
                ],
                value='מעל גיל 60',
                labelStyle={'display': 'inline-block'}
            )], lg=1),
            dbc.Col([dcc.RadioItems(id='smoo',
                options=[
                    {'label': 'smooth ', 'value': 'sm'},
                    {'label': 'raw ', 'value': 'rw'}
                ],
                value='sm',
                labelStyle={'display': 'inline-block'}
            )], lg=1),
            dbc.Col([dcc.RadioItems(id='doNorm',
                options=[
                    {'label': 'absolute', 'value': 'absolute'},
                    {'label': 'per 100k', 'value': 'normalized'}
                ],
                value='normalized',
                labelStyle={'display': 'inline-block'}
            )], lg=2),
            dbc.Col([dcc.DatePickerRange(
                id='date-picker',
                display_format='DD/MM/Y',
                min_date_allowed=dfsNorm[0]['date'][0].date(),
                max_date_allowed=dfsNorm[0]['date'][len(dfsNorm[0])-1].date(),
                initial_visible_month=dfsNorm[0]['date'][0].date(),
                start_date=dfsNorm[0]['date'][0].date(),
                end_date=dfsNorm[0]['date'][len(dfsNorm[0])-1].date()
            )], lg=2),
        ]),
        html.Br(), html.Br(), html.Br(),
        html.A('Deaths for wave IV (11-Jul-2021 to 11-Nov-2021) and V (1-Jan-22 to present) vs new severe cases, 10 days earlier.'),
        html.Br(),
        html.A('Ratio plot is black/red for Delta wave IV and (mainly) Omicron wave V.'),
        dbc.Row([
            dbc.Col(dcc.Graph(id='frat1'), lg=3),
            dbc.Col(dcc.Graph(id='frat2'), lg=3),
            dbc.Col(dcc.Graph(id='frat3'), lg=3),
            dbc.Col(dcc.Graph(figure=figWaves), lg=3),
            dbc.Col(dcc.Graph(id='g2', figure=fig1), lg=6, md=12)
        ]),
    ]),
    html.Div([
        html.Div([
            html.H3('COVID19 deaths and cases per million'),
            html.A('First display is for World Health Organization (WHO) data, you can switch to Johns Hopkins (OWID).'), html.Br(),
            html.A('Countries are selected for high mortality in last 7 days. Use button to switch to top-cases countries'), html.Br(),
            html.A('Deselect countries by clicking the legend, or uncheck from list. Select time with slider below.'),
        ]),
        dbc.Row([
            dbc.Col([
                dcc.RadioItems(id='src',
                               options=[
                                   {'label': 'WHO', 'value': 'WHO'},
                                   {'label': 'JH', 'value': 'JH'}
                               ],
                               value='WHO',
                               labelStyle={'display': 'inline-block'}
                               ),
            ], lg=1),
            dbc.Col([
                dcc.RadioItems(id='cum',
                               options=[
                                   {'label': 'cumulative', 'value': 'cum'},
                                   {'label': 'daily', 'value': 'daily'}
                               ],
                               value='daily',
                               labelStyle={'display': 'inline-block'}
                )
            ], lg=2),
            dbc.Col([
                dcc.RadioItems(id='smoot',
                               options=[
                                   {'label': 'smooth ', 'value': 'sm'},
                                   {'label': 'raw ', 'value': 'rw'}
                               ],
                               value='sm',
                               labelStyle={'display': 'inline-block'}
                               )
            ], lg=1),
            dbc.Col([html.Button('clear', id='btn-clear', n_clicks=0),
                    html.A('       '), html.A('sort by: '),
                    html.Button('deaths', id='btn-death-sort', n_clicks=0),
                    html.Button('cases', id='btn-cases-sort', n_clicks=0),
                    html.Button('rise', id='btn-rise-sort', n_clicks=0)], lg=2),
        ])
    ]),

    dbc.Row([dbc.Col(dcc.Graph(id='deathW'), lg=7, md=12),
        dbc.Col(dcc.Checklist(
            id="checklist",
            options=[{"label": x, "value": x} for x in country_common],
            value=country_v,
            labelStyle={'display': 'inline-block'}),
        lg=5, md=12)]),
    dbc.Row([dbc.Col(dcc.Graph(id='casesW'), lg=7, md=12)]),
    dbc.Col(dcc.RangeSlider(
        id='rangeslider',
        min=0,
        max=len(dateW) - 1,
        value=[161, len(dateW) - 1],
        allowCross=False
    ), lg=6, md=12),
    dbc.Row([
        html.Div([
            dcc.RadioItems(id='age60w',
                           options=[
                               {'label': '60+', 'value': 'מעל גיל 60'},
                               {'label': '<60', 'value': 'מתחת לגיל 60'}
                           ],
                           value='מעל גיל 60',
                           labelStyle={'display': 'inline-block'}
                           )
        ]),
        dbc.Col(dcc.Graph(id='gw60'), lg=8, md=12)
    ]),
    # dbc.Row([dbc.Col(dcc.Graph(id='gw'), lg=8, md=12)]),
])
@app.callback(
    Output('infected', 'figure'),
    Output('severe', 'figure'),
    Output('death', 'figure'),
    # Output('gw', 'figure'),
    Output('gw60', 'figure'),
    Output('frat1', 'figure'),
    Output('frat2', 'figure'),
    Output('frat3', 'figure'),
    Input('age', 'value'),
    Input('doNorm', 'value'),
    Input('smoo', 'value'),
    Input('loglin', 'value'),
    Input('age60w', 'value'),
    Input('date-picker', 'start_date'),
    Input('date-picker', 'end_date'),
    )

def update_graph(age_group, norm_abs, smoo, loglin, age60w, start_date, end_date):
    if norm_abs == 'normalized':
        figb = make_figs3(dfsNorm[0], measure[0], age_group, smoo, ', per 100k ', start_date, end_date, loglin)
        figc = make_figs3(dfsNorm[1], measure[1], age_group, smoo, ', per 100k ', start_date, end_date, loglin)
        figd = make_figs3(dfsNorm[2], measure[2], age_group, smoo, ', per 100k ', start_date, end_date, loglin)
    else:
        figb = make_figs3(dfsAbs[0], measure[0], age_group, smoo,  ' ', start_date, end_date, loglin)
        figc = make_figs3(dfsAbs[1], measure[1], age_group, smoo,  ' ', start_date, end_date, loglin)
        figd = make_figs3(dfsAbs[2], measure[2], age_group, smoo, ' ', start_date, end_date, loglin)
    # fige = make_wane(dfAge.copy())
    figf = makeVE(age60w)
    if age_group == 'מעל גיל 60':
        age = 1
    else:
        age = 0
    figG, figH, figI = make_ratios(age=age)
    return figb, figc, figd, figf, figG, figH, figI

@app.callback(
    Output("download-text", "data"),
    Input("btn-download-txt", "n_clicks"),
    prevent_initial_call=True
)
def func(n_clicks):
    return dict(content=hospitalizationStatus, filename="hospitalizationStatus.csv")
@app.callback(
    Output("download-inf", "data"),
    Input("btn-inf", "n_clicks"),
    prevent_initial_call=True
)
def func(n_clicks):
    return dict(content=downloads[0].to_csv(), filename="VerifiedStatusDaily.csv")
@app.callback(
    Output("download-sev", "data"),
    Input("btn-sev", "n_clicks"),
    prevent_initial_call=True
)
def func(n_clicks):
    return dict(content=downloads[1].to_csv(), filename="SeriousVaccinationStatusDaily.csv")
@app.callback(
    Output("download-dea", "data"),
    Input("btn-dea", "n_clicks"),
    prevent_initial_call=True
)
def func(n_clicks):
    return dict(content=downloads[2].to_csv(), filename="DeathVaccinationStatusDaily.csv")
# @app.callback(
#     Output("download-text", "data"),
#     Input("btn-download-txt", "n_clicks"),
#     prevent_initial_call=True
# )
# def func(n_clicks):
#     return dict(content=hospitalizationStatus, filename="VerfiiedVaccinationStatusDaily.csv")
@app.callback(
    Output('deathW', 'figure'),
    Output('casesW', 'figure'),
    Output('checklist', 'value'),
    Input('src', 'value'),
    Input('cum', 'value'),
    Input('smoot', 'value'),
    Input('rangeslider', 'value'),
    Input("checklist", "value"),
    Input('btn-clear', 'n_clicks'),
    Input('btn-death-sort', 'n_clicks'),
    Input('btn-cases-sort', 'n_clicks'),
    Input('btn-rise-sort', 'n_clicks'),
    State("checklist", "options")
    )
def update_world(src, cum, smoot, rangeslider, checklist, clear, sortD, sortC, sortRise, options):
    changed_id = [p['prop_id'] for p in callback_context.triggered][0]
    if 'btn-clear' in changed_id:
        checklist = ['Israel']
    elif 'btn-death-sort' in changed_id:
        checklist = country_v
    elif 'btn-cases-sort' in changed_id:
        checklist = country_c
    elif 'btn-rise-sort' in changed_id:
        checklist = country_Rise
    figDeaths = make_figW(src, cum, smoot, rangeslider[0], rangeslider[1], checklist)
    figCases = make_figW(src, cum, smoot, rangeslider[0], rangeslider[1], checklist, measure='cases')
    return figDeaths, figCases, checklist


if __name__ == '__main__':
    app.run_server(debug=True)
