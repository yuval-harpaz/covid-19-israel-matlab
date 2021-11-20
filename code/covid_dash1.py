import pandas as pd
import numpy as np
import plotly.graph_objects as go
import dash
from dash import dcc
from dash import html
import plotly.express as px
import os
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
    dfsNorm[ii] = dfsNorm[ii][['date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
    dfsAbs[ii] = dfs.rename(columns={varsAbs[ii][0]: 'vaccinated', varsAbs[ii][1]: 'expired', varsAbs[ii][2]: 'unvaccinated'})
    dfsAbs[ii] = dfsAbs[ii][['date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]




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
win =21
def movmean(vec, win, nanTail=True):
    #  smooth a vector with a moving average. win should be an odd number of samples.
    #  vec is np.ndarray size (N,) or (N,0)
    #  to get smoothing of 3 samples back and 3 samples forward use win=7
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
df['cases'] = casesAll
Nvax = np.asarray(df2['verified_amount_vaccinated']/df2['verified_vaccinated_normalized']*10**5)
Nexp = np.asarray(df2['verified_amount_expired']/df2['verified_expired_normalized']*10**5)
def make_wane(win):
    win = int(np.floor((int(win)-1)/2)*2+1)
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
    unvax = np.asarray(df2['verified_not_vaccinated_normalized'])
    VE = 100*(1-ratioVax/(movmean(unvax, win, nanTail=False)/10**5))  # FIXME - too many nans
    idx = [np.where(date == date2[0])[0][0], np.where(date == date2.loc[len(date2)-1])[0][0]+1]
    ve[idx[0]:idx[1]] = movmean(VE, win, nanTail=False)
    df7 = df.rolling(win, min_periods=3).mean().round(1)
    df7['VE for 60+ cases (2 doses or more)'] = ve
    # df7['cases (normalized)'] = np.round(100*df7['cases (normalized)']/np.max(df7['cases (normalized)']))
    xl = [str(np.datetime_as_string(date[288]))[0:10], str(np.datetime_as_string(date[-1]))[0:10]]
    df7['date'] = date
    # layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', xaxis_range=xl)
    fig_wane = px.line(df7, x='date', y=['VE for 60+ cases (2 doses or more)',  '% unvaccinated of mild hospitalizations', '% unvaccinated of 60+ cases'])
    fig_wane.layout = layout
    fig_wane.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 100],
                     tickfont=dict(color="#cc3333"), titlefont=dict(color="#cc3333"), title='% unvaccinated')
    fig_wane.add_trace(go.Scatter(x=df7['date'], y=df7['cases'], yaxis='y2', name='Cases', line_color='black'))
    fig_wane.update_layout(
        title_text="Looking for signs of waning immunity", font_size=15,
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
    fig_wane['data'][0]['line']['color'] = '#cc3333'
    fig_wane['data'][1]['line']['color'] = '#cc3333'
    fig_wane['data'][1]['line']['dash'] = 'dashdot'
    fig_wane['data'][2]['line']['color'] = '#cc3333'
    fig_wane['data'][2]['line']['dash'] = 'dot'
    fig_wane.layout['yaxis']['titlefont']['color'] = "#cc3333"
    # fig_wane.layout['xaxis']['range'] = xl
    # fig_wane.update_layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
    fig_wane.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%m\n%Y", range=xl)
    fig_wane.layout['xaxis']['title'] = 'Month'
    fig_wane.layout['yaxis']['dtick'] = 10
    return fig_wane

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
            html.A(' by '),html.A('@yuvharpaz', href="https://twitter.com/yuvharpaz.", target='_blank'),
            html.A(' code ', href="https://twitter.com/yuvharpaz.", target='_blank'),
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
            dbc.Col(dcc.Graph(id='infected'), md=4),
            dbc.Col(dcc.Graph(id='severe'), md=4),
            dbc.Col(dcc.Graph(id='death'), md=4)
        ]),
        dbc.Row([
            dbc.Col([" "], md=4),
            dbc.Col(["Smoothing factor (odd number of days): ", dcc.Input(id='gwi', value='7', type='text')], md=4)
        ]),
        dbc.Row([
            dbc.Col(dcc.Graph(id='g2', figure=fig1), md=4),
            dbc.Col(dcc.Graph(id='gw'), md=8)
        ])
    ])
])
@app.callback(
    Output('infected', 'figure'),
    Output('severe', 'figure'),
    Output('death', 'figure'),
    Output('gw', 'figure'),
    Input('age', 'value'),
    Input('doNorm', 'value'),
    Input('smoo', 'value'),
    Input('gwi', 'value'))
def update_graph(age_group, norm_abs, smoo, win):
    if norm_abs == 'normalized':
        figb = make_figs3(dfsNorm[0], measure[0], age_group, smoo, ', per 100k ')
        figc = make_figs3(dfsNorm[1], measure[1], age_group, smoo, ', per 100k ')
        figd = make_figs3(dfsNorm[2], measure[2], age_group, smoo, ', per 100k ')
    else:
        figb = make_figs3(dfsAbs[0], measure[0], age_group, smoo,  ' ')
        figc = make_figs3(dfsAbs[1], measure[1], age_group, smoo,  ' ')
        figd = make_figs3(dfsAbs[2], measure[2], age_group, smoo, ' ')
    fige = make_wane(win)
    return figb, figc, figd, fige


if __name__ == '__main__':
    app.run_server(debug=True)





