import pandas as pd
import numpy as np
from dash import dcc, callback_context, html, Dash
from dash.dependencies import Input, Output, State
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
import urllib.request
import json
from matplotlib import pyplot as plt

def movmean(vec, win=7, nanTail=True):
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

data = pd.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv')
country = 'France'

row = data['location'] == country
date = np.asarray(data['date'][row])
date = [np.datetime64(d) for d in date]
deaths = np.asarray(data['new_deaths'][row])
deaths = movmean(deaths)
deaths = deaths/np.nanpercentile(deaths, 90)
icu = np.asarray(data['weekly_icu_admissions'][row])
icu = movmean(icu)
icu = icu/np.nanpercentile(icu,90)
plt.figure()
plt.plot(date, deaths)
plt.plot(date, icu)
plt.legend(['deaths', 'ICU admissions'])
# pop = pd.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/scripts/input/un/population_latest.csv')
# JHT = JH.T
# jhn = JHT.to_numpy()
# jhc = JHC.T.to_numpy()
# if jhc.shape != jhn.shape:
#     raise Exception('JH different sizes')
#
# # owid = pd.read_csv('https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv?raw=true')
# JHisr = JH[JH['Country/Region'] == 'Israel']
# date_str = list(JHisr.columns[4:])
# dateW = []
# for ii, dd in enumerate(date_str):
#     parsed = dd.split('/')
#     for dm in [0, 1]:
#         if len(parsed[dm]) == 1:
#             parsed[dm] = '0'+parsed[dm]
#     dateW.append(np.datetime64('20'+parsed[2]+'-'+parsed[0]+'-'+parsed[1]))
# dateW = np.asarray(dateW)
# WHO = pd.read_csv('https://covid19.who.int/WHO-COVID-19-global-data.csv')
# wc = np.unique(np.asarray(WHO['Country']))
# WHOisr = WHO[WHO['Country'] == 'Israel']
# dateWho = np.asarray(list(WHOisr['Date_reported']))
# # deathWho = np.asarray(list(WHOisr['New_deaths']))
# # casesWho = np.asarray(list(WHOisr['New_cases']))
# fixJH = np.asarray([['US', 'United States'], ['Korea, South', 'South Korea']])
# for ii in range(len(fixJH)):
#     col = np.where(jhn[1, :] == fixJH[ii, 0])[0][0]
#     jhn[1, col] = fixJH[ii, 1]
# country = []
# pop_jh = []
# for cntr in list(pop['entity']):
#     if cntr in jhn[1, :]:  # and pop['population'][pop['entity'] == cntr].to_numpy()[0] > 10**6:
#         country.append(cntr)
#         pop_jh.append(pop['population'][pop['entity'] == cntr].to_numpy()[0])
# pop_jh = np.asarray(pop_jh)
#
# date_who_list = np.asarray(WHO['Date_reported'])
# death_who_list = np.asarray(WHO['New_deaths'])
# cases_who_list = np.asarray(WHO['New_cases'])
# country_who_list = np.asarray(WHO['Country'])
# country_whu = np.unique(country_who_list)
# # for ii in country_whu:
# #     if 'ussia' in ii:
# #         print(ii)
# WHO = WHO.replace('Republic of Korea', 'South Korea')
# WHO = WHO.replace('United States of America', 'United States')
# WHO = WHO.replace('Russian Federation', 'Russia')
# WHO = WHO.replace('The United Kingdom', 'United Kingdom')
# country_who_list = np.asarray(WHO['Country'])
# country_whu = np.unique(country_who_list)
# country_common = []
# pop_common = []
# for ii, cntr in enumerate(country):
#     if cntr in list(WHO['Country']):
#         country_common.append(cntr)
#         pop_common.append(pop_jh[ii])
#
#
#
#
# #%% compute deaths per million
# day0 = np.where(date_who_list == str(dateW[0]))[0][0]
# day1 = np.where(date_who_list == str(dateW[-1]))[0]
# if len(day1) == 0:
#     day1 = np.where(date_who_list == str(dateW[-2]))[0]
# if len(day1) == 0:
#     day1 = np.where(date_who_list == str(dateW[-3]))[0]
# day1 = day1[0]+1
# dpm = {'WHO': {}, 'JH': {}}
# lastWeek = []
# cpm = {'WHO': {}, 'JH': {}}
# lastWeekC = []
# lastWeekRise = []
# for cc, ctr in enumerate(country_common):
#     # print(str(cc)+' of '+str(len(country_common))+' '+ctr)
#     pp = list(pop['population'][pop['entity'] == ctr])
#     if len(pp) == 1:
#         pp = pp[0]
#     else:
#         raise Exception('population for '+ctr+' wrong')
#     row = np.where(country_who_list == country_common[cc])[0]
#     yyWcum = np.sum(jhn[4:, jhn[1, :] == ctr], axis=1)
#     yyWcum = yyWcum / pp * 10 ** 6
#     yyW = yyWcum.copy()
#     yyW[1:] = np.diff(yyWcum)
#     yyW =yyW
#     yyW = yyW.astype(float)
#     yyW[yyW > 200] = np.nan
#     dpm['JH'][ctr] = {}
#     dpm['JH'][ctr]['daily'] = yyW
#     dpm['JH'][ctr]['cum'] = yyWcum
#     yyWc = np.sum(jhc[4:, jhc[1, :] == ctr], axis=1)
#     yyWc = yyWc / pp * 10 ** 6
#     yyWd = yyWc.copy()
#     yyWd[1:] = np.diff(yyWc)
#     yyWd = yyWd.astype(float)
#     bad = np.where((yyWd[1:-1]-yyWd[0:-2] > 15000) & (yyWd[1:-1]-yyWd[2:] > 15000))[0]
#     if len(bad) > 0:
#         yyWd[bad+1] = np.nan
#     cpm['JH'][ctr] = {}
#     cpm['JH'][ctr]['daily'] = np.round(yyWd)
#     cpm['JH'][ctr]['cum'] = np.round(yyWc.astype('float'))
#
#     yW = death_who_list[row][day0:day1]
#     yW = np.asarray(yW) / pp * 10 ** 6
#     yWcum = np.cumsum(yW)
#     yW[yW > 200] = np.nan
#     dpm['WHO'][ctr] = {}
#     dpm['WHO'][ctr]['daily'] = yW
#     dpm['WHO'][ctr]['cum'] = yWcum
#     lastWeek.append(np.nanmean(yW[-7:]))
#     yWc = cases_who_list[row][day0:day1]
#     yWc = np.asarray(yWc) / pp * 10 ** 6
#     yWccum = np.cumsum(yWc)
#     bad = np.where((yWc[1:-1] - yWc[0:-2] > 15000) & (yWc[1:-1]-yWc[2:] > 15000))[0]
#     if len(bad) > 0:
#         yWc[bad+1] = np.nan
#     cpm['WHO'][ctr] = {}
#     cpm['WHO'][ctr]['daily'] = np.round(yWc)
#     cpm['WHO'][ctr]['cum'] = np.round(yWccum.astype('float'))
#     lastWeekC.append(np.nanmean(yWc[-7:]))
#     lastWeekRise.append(np.nanmean(yWc[-7:])-np.nanmean(yWc[-14:-7]))
#     # lastWeekRise.append(np.nanmean(yWc[-7:])/np.nanmean(yWc[-14:-7]))
#
#
# maxCountry = 3*10**5
# order = np.argsort(lastWeek)
# order = order[::-1]
# large = []
# c = -1
# while len(large) < 10:
#     c += 1
#     if pop_common[order[c]] > maxCountry:
#         large.append(country_common[order[c]])
# country_v = large
# orderC = np.argsort(lastWeekC)
# orderC = orderC[::-1]
# largeC = []
# c = -1
# while len(largeC) < 10:
#     c += 1
#     if pop_common[orderC[c]] > maxCountry:
#         largeC.append(country_common[orderC[c]])
# country_c = largeC
#
# orderRise = np.argsort(lastWeekRise)
# orderRise = orderRise[::-1]
# largeRise = []
# c = -1
# while len(largeRise) < 10:
#     c += 1
#     if pop_common[orderRise[c]] > maxCountry:
#         largeRise.append(country_common[orderRise[c]])
# country_Rise = largeRise
#
# # country_v = ['Canada', 'Germany', 'India', 'Italy', 'United Kingdom', 'United States', 'Israel']
# layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
# jet = ['#0000AA', '#0000FF', '#0055FF', '#00AAFF', '#00FFFF', '#55FFAA', '#AAFF55', '#FFFF00', '#FFAA00', '#FF5500'][::-1]*5
# def make_figW(srcl, cum, smooth, start_date, end_date, checklist, measure='deaths'):
#     figW = go.Figure(layout=layout)
#     if measure == 'deaths':
#         data = dpm[srcl]
#     else:
#         data = cpm[srcl]
#     xl = [dateW[start_date], dateW[end_date]]
#     titW = 'Daily '+measure+' per million. '
#     color_count = -1
#     if srcl == 'WHO':
#         td = -1
#     else:
#         td = 0
#     for ct in checklist:
#         yyy = data[ct][cum]
#         if smooth == 'sm' and cum == 'daily':
#             yyy = np.round(movmean(yyy, 7, nanTail=False), 2)
#             yyy[-4:] = np.nan
#         if cum == 'cum':
#             # yyy = np.cumsum(yyy)
#             titW = 'Cumulative '+measure+' per million. '
#
#         if ct == 'Israel':
#             color_trace = '#000000'
#         else:
#             color_count += 1
#             color_trace = jet[color_count]
#         figW.add_trace(go.Scatter(x=dateW+np.timedelta64(td), y=yyy, mode='lines', name=ct, line={'color': color_trace}))
#     figW.update_layout(font_size=14, showlegend=True, hovermode="x unified",
#                        hoverlabel=dict(bgcolor='rgba(255,255,255,0.25)',
#                        bordercolor='rgba(255,255,255,0.25)',
#                        font=dict(color='black')),
#                        title_text=titW,
#                        # sequential='hot',
#                        legend=dict(
#                            yanchor="top",
#                            y=0.99,
#                            xanchor="left",
#                            x=-0.2
#                        ),
#                        margin=dict(
#                            l=150,
#                            r=250,
#                            b=100,
#                            t=100,
#                            pad=4
#                        ),
#                        )
#     figW.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=xl, dtick="M1", tickformat="%d/%m\n%Y")
#     figW.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
#     # figW.layout.colorscale['sequential'] = 'hot'
#     figW.layout.colorscale.update()
#     return figW
#
#
# app = Dash(
#     __name__,
#     external_stylesheets=[dbc.themes.BOOTSTRAP],
#     # external_stylesheets=['https://codepen.io/chriddyp/pen/bWLwgP.css'],
#     meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
# )
# server = app.server
# app.layout = html.Div([
#     html.Div([
#         html.Div([
#             html.H3('COVID19 deaths and cases per million'),
#             html.A('First display is for World Health Organization (WHO) data, you can switch to Johns Hopkins (OWID).'), html.Br(),
#             html.A('Countries are selected for high mortality in last 7 days. Use button to switch to top-cases countries'), html.Br(),
#             html.A('Deselect countries by clicking the legend, or uncheck from list. Select time with slider below.'),
#         ]),
#         dbc.Row([
#             dbc.Col([
#                 dcc.RadioItems(id='src',
#                                options=[
#                                    {'label': 'WHO', 'value': 'WHO'},
#                                    {'label': 'JH', 'value': 'JH'}
#                                ],
#                                value='WHO',
#                                labelStyle={'display': 'inline-block'}
#                                ),
#             ], lg=1),
#             dbc.Col([
#                 dcc.RadioItems(id='cum',
#                                options=[
#                                    {'label': 'cumulative', 'value': 'cum'},
#                                    {'label': 'daily', 'value': 'daily'}
#                                ],
#                                value='daily',
#                                labelStyle={'display': 'inline-block'}
#                 )
#             ], lg=2),
#             dbc.Col([
#                 dcc.RadioItems(id='smoot',
#                                options=[
#                                    {'label': 'smooth ', 'value': 'sm'},
#                                    {'label': 'raw ', 'value': 'rw'}
#                                ],
#                                value='sm',
#                                labelStyle={'display': 'inline-block'}
#                                )
#             ], lg=1),
#             dbc.Col([html.Button('clear', id='btn-clear', n_clicks=0),
#                     html.A('       '), html.A('sort by: '),
#                     html.Button('deaths', id='btn-death-sort', n_clicks=0),
#                     html.Button('cases', id='btn-cases-sort', n_clicks=0),
#                     html.Button('rise', id='btn-rise-sort', n_clicks=0)], lg=2),
#         ])
#     ]),
#
#     dbc.Row([dbc.Col(dcc.Graph(id='deathW'), lg=7, md=12),
#         dbc.Col(dcc.Checklist(
#             id="checklist",
#             options=[{"label": x, "value": x} for x in country_common],
#             value=country_v,
#             labelStyle={'display': 'inline-block'}),
#         lg=5, md=12)]),
#     dbc.Row([dbc.Col(dcc.Graph(id='casesW'), lg=7, md=12)]),
#     dbc.Col(dcc.RangeSlider(
#         id='rangeslider',
#         min=0,
#         max=len(dateW) - 1,
#         value=[161, len(dateW) - 1],
#         allowCross=False
#     ), lg=6, md=12),
# ])
#
# @app.callback(
#     Output('deathW', 'figure'),
#     Output('casesW', 'figure'),
#     Output('checklist', 'value'),
#     Input('src', 'value'),
#     Input('cum', 'value'),
#     Input('smoot', 'value'),
#     Input('rangeslider', 'value'),
#     Input("checklist", "value"),
#     Input('btn-clear', 'n_clicks'),
#     Input('btn-death-sort', 'n_clicks'),
#     Input('btn-cases-sort', 'n_clicks'),
#     Input('btn-rise-sort', 'n_clicks'),
#     State("checklist", "options")
#     )
# def update_world(src, cum, smoot, rangeslider, checklist, clear, sortD, sortC, sortRise, options):
#     changed_id = [p['prop_id'] for p in callback_context.triggered][0]
#     if 'btn-clear' in changed_id:
#         checklist = ['Israel']
#     elif 'btn-death-sort' in changed_id:
#         checklist = country_v
#     elif 'btn-cases-sort' in changed_id:
#         checklist = country_c
#     elif 'btn-rise-sort' in changed_id:
#         checklist = country_Rise
#     figDeaths = make_figW(src, cum, smoot, rangeslider[0], rangeslider[1], checklist)
#     figCases = make_figW(src, cum, smoot, rangeslider[0], rangeslider[1], checklist, measure='cases')
#     return figDeaths, figCases, checklist
#
#
# if __name__ == '__main__':
#     app.run_server(debug=True)
