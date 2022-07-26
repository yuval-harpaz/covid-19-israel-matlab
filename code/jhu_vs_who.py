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


JH = pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv')
pop = pd.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/scripts/input/un/population_latest.csv')
JHT = JH.T
jhn = JHT.to_numpy()
# owid = pd.read_csv('https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv?raw=true')
JHisr = JH[JH['Country/Region'] == 'Israel']
date_str = list(JHisr.columns[4:])
date = []
for ii, dd in enumerate(date_str):
    parsed = dd.split('/')
    for dm in [0, 1]:
        if len(parsed[dm]) == 1:
            parsed[dm] = '0'+parsed[dm]
    date.append(np.datetime64('20'+parsed[2]+'-'+parsed[0]+'-'+parsed[1]))
date = np.asarray(date)
WHO = pd.read_csv('https://covid19.who.int/WHO-COVID-19-global-data.csv')
wc = np.unique(np.asarray(WHO['Country']))
WHOisr = WHO[WHO['Country'] == 'Israel']
dateWho = np.asarray(list(WHOisr['Date_reported']))
deathWho = np.asarray(list(WHOisr['New_deaths']))
fixJH = np.asarray([['US', 'United States'], ['Korea, South', 'South Korea']])
for ii in range(len(fixJH)):
    col = np.where(jhn[1, :] == fixJH[ii, 0])[0][0]
    jhn[1,col] = fixJH[ii, 1]
country = []
for cntr in list(pop['entity']):
    if cntr in jhn[1, :] and pop['population'][pop['entity'] == cntr].to_numpy()[0] > 1*10**6:
        country.append(cntr)

date_who_list = np.asarray(WHO['Date_reported'])
death_who_list = np.asarray(WHO['New_deaths'])
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
for cntr in country:
    if cntr in list(WHO['Country']):
        country_common.append(cntr)


# country_v = ['Canada', 'Germany', 'India', 'Italy', 'United Kingdom', 'United States', 'Israel']
country_v = 'Israel'
#%% compute deaths per million
day0 = np.where(date_who_list == str(date[0]))[0][0]
day1 = np.where(date_who_list == str(date[-1]))[0][0]+1
dpm = {'WHO': {}, 'JH': {}}
for cc, ctr in enumerate(country_common):
    # print(str(cc)+' of '+str(len(country_common))+' '+ctr)
    pp = list(pop['population'][pop['entity'] == ctr])
    if len(pp) == 1:
        pp = pp[0]
    else:
        raise Exception('population for '+ctr+' wrong')
    row = np.where(country_who_list == country_common[cc])[0]
    yW = death_who_list[row][day0:day1]
    yyW = np.sum(jhn[4:, jhn[1, :] == ctr], axis=1)
    yyW[1:] = np.diff(yyW)
    yyW =yyW / pp * 10 ** 6
    yyW = yyW.astype(float)
    yyW[yyW > 200] = np.nan
    dpm['JH'][ctr] = yyW
    yW = np.asarray(yW) / pp * 10 ** 6
    yW[yW > 200] = np.nan
    dpm['WHO'][ctr] = yW


layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
# layout1 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
def make_figW(cum, smooth, start_date, end_date, checklist):
    figW = go.Figure(layout=layout)
    figW.update_layout(font_size=15)
    who = dpm['WHO'][checklist]
    jhu = dpm['JH'][checklist]
    xl = [date[start_date], date[end_date]]
    if cum == 'cum':
        who = np.cumsum(who)
        jhu = np.cumsum(jhu)
    mx = np.max([np.max(who), np.max(jhu)])
    mn = np.min([np.min(who), np.min(jhu)])
    if smooth == 'sm':
        who = np.round(movmean(who, 7, nanTail=True), 2)
        jhu = np.round(movmean(jhu, 7, nanTail=True), 2)
    figW.add_trace(go.Scatter(x=date, y=jhu, mode='lines', name='JHU'))
    figW.add_trace(go.Scatter(x=date + np.timedelta64(0), y=who, mode='lines', name='WHO'))
    figW.update_layout(title_text=checklist, font_size=15, showlegend=True, hovermode="x unified",
                       legend=dict(
                          yanchor="top",
                          y=0.99,
                          xanchor="left",
                          x=0.01
                       ))
    figW.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=xl, dtick="M1", tickformat="%d/%m\n%Y")
    figW.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=[mn, mx])
    return figW


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
            html.H3('COVID19 deaths per million, WHO vs JH'),
            html.A('World Health Organization vs Johns Hopkins University data'),
            html.A(' by '), html.A('@yuvharpaz.', href="https://twitter.com/yuvharpaz", target='_blank'),html.A(' '),
        ]),
        dbc.Row([
            html.Div([
                dcc.RadioItems(id='cum',
                    options=[
                        {'label': 'cumulative', 'value': 'cum'},
                        {'label': 'daily', 'value': 'dif'}
                    ],
                    value='dif',
                    labelStyle={'display': 'inline-block'}
                )
            ]),
            html.Div([
                dcc.RadioItems(id='smoo',
                    options=[
                        {'label': " "+'smooth', 'value': 'sm'},
                        {'label': " "+'raw ', 'value': 'rw'}
                    ],
                    value='rw',
                    labelStyle={'display': 'inline-block'}
                )
            ])
        ])
    ]),
    dbc.Col(dcc.Graph(id='death'), lg=8, md=12),
    dbc.Col(dcc.RangeSlider(
        id='rangeslider',
        min=0,
        max=len(date)-1,
        value=[161, len(date)-1],
        allowCross=False
    ), lg=8, md=12),
    dcc.RadioItems(
        id="checklist",
        options=[{"label": x, "value": x} for x in country_common],
        value=country_v,
        labelStyle={'display': 'inline-block'}
    ),
])
@app.callback(
    Output('death', 'figure'),
    Input('cum', 'value'),
    Input('smoo', 'value'),
    Input('rangeslider', 'value'),
    Input("checklist", "value")
    )
def update_world(cum, smoo, rangeslider, checklist):
    figWorld = make_figW(cum, smoo, rangeslider[0], rangeslider[1], checklist)
    return figWorld
if __name__ == '__main__':
    app.run_server(debug=True)




