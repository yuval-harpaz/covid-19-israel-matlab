import os
import pandas as pd
import numpy as np
import dash
from dash import dcc
from dash import html
import plotly.express as px
import plotly.graph_objects as go
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
import urllib.request
import json


if os.path.isfile('/home/innereye/Downloads/VerfiiedVaccinationStatusDaily'):
    api = '/home/innereye/Downloads/'
    df = pd.read_csv(
        '/home/innereye/covid-19-israel-matlab/data/Israel/cases_by_age.csv')
else:
    api = 'https://datadashboardapi.health.gov.il/api/queries/'
    df = pd.read_csv(
    'https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/cases_by_age.csv')
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
for ii in [0, 1, 2]:
    dfs = pd.read_json(url[ii])
    dfs['date'] = pd.to_datetime(dfs['day_date'])
    dfsNorm[ii] = dfs.rename(columns={varsNorm[ii][0]: 'vaccinated', varsNorm[ii][1]: 'expired', varsNorm[ii][2]: 'unvaccinated'})
    dfsNorm[ii] = dfsNorm[ii][['date', 'day_date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
    dfsAbs[ii] = dfs.rename(columns={varsAbs[ii][0]: 'vaccinated', varsAbs[ii][1]: 'expired', varsAbs[ii][2]: 'unvaccinated'})
    dfsAbs[ii] = dfsAbs[ii][['date', 'day_date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
shifts = [0, 11, 21]
ages2 = ['מתחת לגיל 60', 'מעל גיל 60']
yy = np.zeros((3,2,2))
dd = [[], [], []]
for im in [0, 1, 2]:  # cases, severe, deaths
    for ia in [0, 1]:  # young, old
        df_age1 = dfsAbs[im].loc[dfsAbs[im]['age_group'] == ages2[ia]]
        df_age1.reset_index()
        meas = np.asarray(df_age1['unvaccinated'])
        day_date = np.asarray(df_age1['day_date'])
        d0 = np.where(day_date == '2021-06-20T00:00:00.000Z')[0][0]
        d1 = np.where(day_date == '2021-10-21T00:00:00.000Z')[0][0]
        d2 = np.where(day_date == '2021-12-11T00:00:00.000Z')[0][0]
        yy[im, ia, 0] = np.sum(meas[d0+shifts[im]:d1+shifts[im]])
        yy[im, ia, 1] = np.sum(meas[d2+shifts[im]:-shifts[-im-1]-1])
    dd[im] = [str(day_date[d0+shifts[im]]),
              str(day_date[d1+shifts[im]]),
              str(day_date[d2+shifts[im]]),
              str(day_date[-shifts[-im-1]-1])]

dfRat = pd.DataFrame([['Delta', yy[2, 1, 0]/yy[1, 1, 0]], ['Omi', yy[2, 1, 1]/yy[1, 1, 1]]], columns=['wave','death ratio'])
fig = px.histogram(dfRat, x="wave", y="death ratio")
             # color='smoker', barmode='group',
             # height=1)
fig.show()




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
x = df['date']
x = pd.to_datetime(x)
yyAge = np.asarray(df.iloc[:, 1:11])
label = ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80-89', '90+']
color = ['#E617E6', '#6A17E6', '#1741E6', '#17BEE6', '#17E6BE', '#17E641', '#6AE617', '#E6E617', '#E69417', '#E61717']
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', legend={'traceorder': 'reversed'})
layout1 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
fig1 = go.Figure(layout=layout1)
for ii, line in enumerate(yyAge.T):
    fig1.add_trace(go.Scatter(x=x, y=line,
                        mode='lines',
                        line_color = color[ii],
                        name=label[ii]))

fig1.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
fig1.update_yaxes(range=(20, 19000))
fig1.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%b\n%Y")
fig1.update_layout(title_text="Weekly cases by age", font_size=15, updatemenus=updatemenus)


def make_figs3(df_in, meas, age_gr='מעל גיל 60', smoo='sm', nrm=', per 100k '):
    df_age = df_in.loc[df_in["age_group"] == age_gr]
    date = df_age['date']
    mx = np.max(df_age.max()[2:5])*1.05
    xl = [df_age.iloc[0,0], df_age.iloc[-1,0]]
    if smoo == 'sm':
        df_age = df_age.rolling(7, min_periods=7).mean().round(1)
        df_age['date'] = date - pd.to_timedelta(df_age.shape[0] * [3], 'd')
    fig = px.line(df_age, x="date", y=['vaccinated', 'expired', 'unvaccinated'])
    fig.update_traces(hovertemplate="%{y}")
    fig['data'][0]['line']['color'] = '#0e7d7d'
    fig['data'][1]['line']['color'] = '#b9c95b'
    fig['data'][2]['line']['color'] = '#2fcdfb'
    fig.layout = layout
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, mx])
    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=xl, dtick="M1", tickformat="%d/%m\n%Y")
    if age_gr == 'מעל גיל 60':
        txt60 = '(60+)'
    else:
        txt60 = '(<60)'
    fig.update_layout(title_text=meas+' by vaccination status'+nrm+txt60, font_size=15, hovermode="x unified")
    return fig

## waning
url1 = 'https://data.gov.il/api/3/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd&limit=10000'
with urllib.request.urlopen(url1) as api1:
    data1 = json.loads(api1.read().decode())
win = 7


def movmean(vec, win, nanTail=False):
    #  smooth a vector with a moving average. win should be an odd number of samples.
    #  vec is np.ndarray size (N,) or (N,0)
    #  to get smoothing of 3 samples back and 3 samples forward use win=7
    smooth = vec.copy()
    if win > 1:
        if nanTail:
            smooth[:] = np.nan
        for ii in range(int(win/2), len(vec)-int(win/2)):
            smooth[ii] = np.nanmean(vec[ii-int(win/2):ii+int(win/2)+1])
    return smooth


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
df = pd.DataFrame(date,columns=['date'])
df['% unvaccinated of 60+ cases'] = cases
df['% unvaccinated of mild hospitalizations'] = mild
df['cases'] = movmean(casesAll, 7, True)
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
## VE TIMNA
urlVE = 'https://data.gov.il/api/3/action/datastore_search?resource_id=9b623a64-f7df-4d0c-9f57-09bd99a88880&limit=50000'
with urllib.request.urlopen(urlVE) as api1:
    dataCases = json.loads(api1.read().decode())

for week in dataCases['result']['records']:
    keys = list(week.keys())
    for field in keys:
        if week[field] == '<5':
            week[field] = '2.5'
        if week[field] == '<15':
            week[field] = '7'
cases = pd.DataFrame(dataCases['result']['records'])
# dateVE = np.asarray(pd.to_datetime(cases['Week'].str.slice(12, 23)))
urlVacc = 'https://data.gov.il/api/3/action/datastore_search?resource_id=57410611-936c-49a6-ac3c-838171055b1f&limit=5000'
with urllib.request.urlopen(urlVacc) as api1:
    dataVacc = json.loads(api1.read().decode())
for day in dataVacc['result']['records']:
    keys = list(day.keys())
    for field in keys:
        if day[field] == '<15':
            day[field] = '7'
        if day[field] == '<5':
            day[field] = '2'
vaccA = pd.DataFrame(dataVacc['result']['records'])
# dateVacc = pd.to_datetime(vaccA['VaccinationDate'])
vaccA['first_dose'] = vaccA['first_dose'].astype(int)
vaccA['second_dose'] = vaccA['second_dose'].astype(int)
vaccA['third_dose'] = vaccA['third_dose'].astype(int)
# dd = dateVacc.sort_values()  # maybe no need to sort

# keep 60+ only
ages = cases['Age_group'].unique()
iAge = [5, 6, 7, 8]
mask = cases['Age_group'].isin(ages[iAge])
cases = cases[mask]
dateVE = np.asarray(pd.to_datetime(cases['Week'].str.slice(12, 23)))
weekEnd = np.unique(dateVE)
weekEnd.sort()
mask = vaccA['age_group'].isin(ages[iAge])
vaccX = vaccA[mask]
dateVacc = np.asarray(pd.to_datetime(vaccX['VaccinationDate']))

pop = 1587000

dose2 = np.ndarray((len(cases), 3))
dose3 = np.ndarray((len(cases), 3))
dose2[:, 0] = np.asarray(cases['positive_14_30_days_after_2nd_dose'].astype(float))
dose2[:, 1] = cases['positive_14_30_days_after_3rd_dose'].astype(float)
dose2[:, 2] = cases['positive_above_3_month_after_2nd_before_3rd_dose'].astype(float)
dose2 = np.nansum(dose2, axis=1)
dose3[:, 0] = np.asarray(cases['positive_14_30_days_after_3rd_dose'].astype(float))
dose3[:, 1] = np.asarray(cases['positive_31_90_days_after_3rd_dose'].astype(float))
dose3[:, 2] = np.asarray(cases['positive_above_90_days_after_3rd_dose'].astype(float))
dose3 = np.nansum(dose3, axis=1)
unvacc = np.asarray(cases['Sum_positive_without_vaccination'].astype(float))
ve2 = np.ndarray(len(weekEnd))
ve3 = np.ndarray(len(weekEnd))
for ii in range(len(weekEnd)):
    date1 = weekEnd[ii]
    caseRow = dateVE == weekEnd[ii]
    # first dose a week before, used to evaluate unvaccinated
    idx = dateVacc < (date1-7+3)
    if np.sum(idx) == 0:
        vacc1 = 0
    else:
        vacc1 = np.sum(vaccX['first_dose'][idx])
    # third dose 20 days before
    idx = dateVacc < (date1-20+3)
    if np.sum(idx) == 0:
        vacc3 = 0
    else:
        vacc3 = np.sum(vaccX['third_dose'][idx])
    # 2nd dose two weeks before (but with no 3rd dose)
    idx = dateVacc < (date1-14+3)
    if np.sum(idx) == 0:
        vacc2 = 0
    else:
        vc3 = np.sum(vaccX['third_dose'][idx])
        vacc2 = np.sum(vaccX['second_dose'][idx]) - vc3
    ve2[ii] = 100*(1-(np.nansum(dose2[caseRow])/vacc2)/(np.nansum(unvacc[caseRow])/(pop-vacc1)))
    ve3[ii] = 100 * (1 - (np.nansum(dose3[caseRow]) / vacc3) / (np.nansum(unvacc[caseRow]) / (pop - vacc1)))

ve3[[31, 32, 33]] = np.nan  # 100% VE, too few vaccinated
ve3 = np.round(ve3, 1)
ve2 = np.round(ve2, 1)


def make_wane(dfW, win):
    win = int(np.floor((int(win)-1)/2)*2+1)

    # smExp = np.round(smExp, 1)
    ratioVax =  ((np.asarray(df2['verified_amount_vaccinated']) + \
                np.asarray(df2['verified_amount_expired'])) / \
                (sm + smExp))
    VE = 100*(1-ratioVax/(movmean(unvax, win, nanTail=False)/10**5))
    idx = [np.where(date == date2[0])[0][0], np.where(date == date2[-1])[0][0]+1]
    VE = np.round(movmean(VE, win, nanTail=False), 1)
    if win > 1:
        VE[-int(win / 2):] = np.nan
    ve[idx[0]:idx[1]] = VE
    # df7 = df.rolling(win, min_periods=3).mean().round(1)

    dfW['VE for 60+ cases (2 doses or more)'] = ve
    # df7['cases (normalized)'] = np.round(100*df7['cases (normalized)']/np.max(df7['cases (normalized)']))
    dfW['% unvaccinated of mild hospitalizations'] = np.round(
        movmean(np.asarray(dfW['% unvaccinated of mild hospitalizations']), win, True),1)
    dfW['% unvaccinated of 60+ cases'] = np.round(
        movmean(np.asarray(dfW['% unvaccinated of 60+ cases']), win, True), 1)

    xl = [str(np.datetime_as_string(date[288]))[0:10], str(np.datetime_as_string(date[-1]))[0:10]]
    dfW['date'] = date
    layoutW = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', xaxis_range=xl)
    fig_wane = go.Figure(layout=layoutW)
    fig_wane.add_trace(go.Scatter(x=weekEnd - 3, y=ve2, name='VE dose 2, Data.Gov', line_color='#66ff66'))
    fig_wane.add_trace(go.Scatter(x=weekEnd - 3, y=ve3, name='VE dose 3, Data.Gov', line_color='#227722'))
    name = 'VE for 60+ cases (2 doses or more)'
    fig_wane.add_trace(go.Scatter(x=dfW['date'], y=dfW[name], line_color='red', name='VE dose 2+3, dashboard'))
    name = '% unvaccinated of mild hospitalizations'
    fig_wane.add_trace(go.Scatter(x=dfW['date'], y=dfW[name], line_color='red', name='% unvax of mild hospitalizations'))
    name = '% unvaccinated of 60+ cases'
    fig_wane.add_trace(go.Scatter(x=dfW['date'], y=dfW[name], line_color='red', name='% unvax of 60+ cases'))
    # fig_wane.layout = layoutW
    fig_wane.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 100],
                          tickfont=dict(color="#cc3333"), titlefont=dict(color="#cc3333"), title='% unvaccinated or VE',
                          hoverformat=None)
    fig_wane.add_trace(go.Scatter(x=dfW['date'], y=np.round(dfW['cases']), yaxis='y2', name='Cases', line_color='#bbbbbb'))
    fig_wane.update_layout(
        legend=dict(
                        yanchor="top",
                        y=1.1,
                        xanchor="left",
                        x=1.05
                    ),
        title_text="Looking for signs of waning immunity.", font_size=15, hovermode="x unified",
        yaxis2=dict(
            title="Cases",
            anchor="free",
            overlaying="y",
            side="right",
            position=1,
            zerolinecolor='lightgray',
            gridcolor='lightgray',
            range=[0, 10000]
        ), )
    fig_wane['data'][2]['line']['dash'] = 'dash'
    fig_wane['data'][3]['line']['dash'] = 'dot'
    fig_wane.layout['yaxis']['titlefont']['color'] = "#cc3333"
    fig_wane.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%d/%m\n%Y", range=xl)
    fig_wane.layout['xaxis']['title'] = 'Month'
    fig_wane.layout['yaxis']['dtick'] = 10
    # fig_wane.show()
    return fig_wane


def makeVE(dfW60, age_gr):
    if age_gr == 'מעל גיל 60':
        tit = "Crude VE (60+) vs cases per 100k, for recently vaccinated (<6m) and unvaccinated"
    else:
        tit = "Crude VE (<60) vs cases per 100k, for recently vaccinated (<6m) and unvaccinated"
    df_age = dfW60.loc[dfW60["age_group"] == age_gr]
    df_age = df_age.reset_index()
    tm = df_age['date'].to_numpy()
    date2ve = []
    for t in tm:
        date2ve.append(pd.Timestamp.to_datetime64(t))
    date2ve = np.asarray(date2ve)
    # date2ve = np.datetime64(df_age['date'].to_string.str.slice(0,10))
    # date2ve = np.asarray(pd.to_datetime(df2['day_date'].str.slice(0, 10)))
    vaccW60 = np.round(movmean(np.asarray(df_age['vaccinated']), 7, nanTail=False), 2)
    unvaccW60 = np.round(movmean(np.asarray(df_age['unvaccinated']), 7, nanTail=False), 2)
    veW60 = np.round(100 * (1 - vaccW60 / unvaccW60))
    xlW60 = [str(np.datetime_as_string(date2ve[4]))[0:10],
             str(np.datetime_as_string(date2ve[-1] + np.timedelta64(1, 'D')))[0:10]]
    layoutW60 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)',
                          xaxis_range=xlW60)  # , xaxis_range=xl)
    figW60 = go.Figure(layout=layoutW60)
    figW60.add_trace(go.Scatter(x=date2ve, y=veW60, name='VE                                      ', line_color='#222277'))
    figW60.add_trace(go.Scatter(x=date2ve[-4:], y=veW60[-4:], name='not final', line_color='#aaaaaa'))
    figW60.update_yaxes(range=[-50, 100], dtick=10, zeroline=True, zerolinecolor='#aaaaaa', gridcolor='#bdbdbd')
    figW60.add_trace(go.Scatter(x=date2ve, y=vaccW60, yaxis='y2', name='vaccinated   ', line_color='#99ff99'))
    figW60.update_xaxes(dtick="M1", tickformat="%d-%b \n%Y", gridcolor='#bdbdbd')
    figW60.update_layout(
        yaxis_title="crude VE (%)",
        yaxis=dict(
            tickmode='linear',
            zeroline=True,
        ),
        legend=dict(
            yanchor="top",
            y=1.1,
            xanchor="left",
            x=1.05
        ),
        title_text=tit, font_size=15, hovermode="x unified",
        yaxis2=dict(
            title="Cases per 100k",
            color='#ff9999',
            anchor="free",
            overlaying="y",
            side="right",
            position=1,
            zerolinecolor='lightgray',
            gridcolor='lightgray',
            zeroline=True,
            range=[0, 150]
        ))
    figW60.add_trace(go.Scatter(x=date2ve, y=unvaccW60, yaxis='y2', name='unvaccinated', line_color='#ff9999'))
    return figW60
app = dash.Dash(
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
            html.A(' by '),html.A('@yuvharpaz.', href="https://twitter.com/yuvharpaz", target='_blank'),html.A(' '),
            html.A(' code ', href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/covid_dash1.py", target='_blank'),
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
            html.Div([
                dcc.RadioItems(id='doNorm',
                    options=[
                        {'label': 'absolute', 'value': 'absolute'},
                        {'label': 'per 100k', 'value': 'normalized'}
                    ],
                    value='normalized',
                    labelStyle={'display': 'inline-block'}
                )
            ]),
            html.Div([
                dcc.RadioItems(id='age',
                    options=[
                        {'label': '60+', 'value': 'מעל גיל 60'},
                        {'label': '<60', 'value': 'מתחת לגיל 60'}
                    ],
                    value='מעל גיל 60',
                    labelStyle={'display': 'inline-block'}
                )
            ]),

            html.Div([
                dcc.RadioItems(id='smoo',
                    options=[
                        {'label': 'smooth ', 'value': 'sm'},
                        {'label': 'raw ', 'value': 'rw'}
                    ],
                    value='sm',
                    labelStyle={'display': 'inline-block'}
                )
            ]),
        ]),

        dbc.Row([
            dbc.Col(dcc.Graph(id='infected'), lg=4),
            dbc.Col(dcc.Graph(id='severe'), lg=4),
            dbc.Col(dcc.Graph(id='death'), lg=4)
        ]),
        dbc.Row([
            dbc.Col([" "], lg=4),
            dbc.Col(["Smoothing factor (odd number of days): ",
                     dcc.Input(id='gwi', value='7', type='text', debounce=True)], lg=4)  # style={'width': '1%'} not working
        ]),
        dbc.Row([
            dbc.Col(dcc.Graph(id='gw'), lg=8, md=12),
            dbc.Col(dcc.Graph(id='g2', figure=fig1), lg=4, md=12)
        ]),
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
        ])
    ])
])
@app.callback(
    Output('infected', 'figure'),
    Output('severe', 'figure'),
    Output('death', 'figure'),
    Output('gw', 'figure'),
    Output('gw60', 'figure'),
    Input('age', 'value'),
    Input('doNorm', 'value'),
    Input('smoo', 'value'),
    Input('gwi', 'value'),
    Input('age60w', 'value'))

def update_graph(age_group, norm_abs, smoo, win, age60w):
    if norm_abs == 'normalized':
        figb = make_figs3(dfsNorm[0], measure[0], age_group, smoo, ', per 100k ')
        figc = make_figs3(dfsNorm[1], measure[1], age_group, smoo, ', per 100k ')
        figd = make_figs3(dfsNorm[2], measure[2], age_group, smoo, ', per 100k ')
    else:
        figb = make_figs3(dfsAbs[0], measure[0], age_group, smoo,  ' ')
        figc = make_figs3(dfsAbs[1], measure[1], age_group, smoo,  ' ')
        figd = make_figs3(dfsAbs[2], measure[2], age_group, smoo, ' ')
    fige = make_wane(df.copy(), win)
    figf = makeVE(dfsNorm[0].copy(), age60w)
    return figb, figc, figd, fige, figf


if __name__ == '__main__':
    app.run_server(debug=True)





