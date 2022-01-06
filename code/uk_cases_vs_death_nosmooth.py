# from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import requests
import dash
from dash import dcc
from dash import html
import plotly.graph_objects as go
import dash_bootstrap_components as dbc
from dash.dependencies import Input, Output

def movmean(vec, win, nanTail=False):
    smooth = vec.copy()
    if win > 1:
        if nanTail:
            smooth[:] = np.nan
        for ii in range(int(win/2),len(vec)-int(win/2)):
            smooth[ii] = np.nanmean(vec[ii-int(win/2):ii+int(win/2)+1].astype(float))
    return smooth


url='https://api.coronavirus.data.gov.uk/v2/data?'
date = np.datetime64('today')-np.timedelta64(1)
metric = ['maleCases', 'femaleCases', 'newDeaths28DaysByDeathDate']
loc = ['England', 'London']

age = ['0_to_4','5_to_9','10_to_14','15_to_19','20_to_24','25_to_29','30_to_34','35_to_39',
       '40_to_44','45_to_49','50_to_54','55_to_59','60_to_64','65_to_69','70_to_74',
       '75_to_79','80_to_84','85_to_89','90+']
data = {'England': [], 'London': []}
dates = {'England': [], 'London': []}
dates_deaths = {'England': [], 'London': []}
for ll in loc:
    if ll == 'England':
        at = 'nation'
    else:
        at = 'region'

    dataLoc = {'maleCases': [], 'femaleCases': [], 'deaths': []}
    for s in metric:
        # req = 'areaType='+at+'&areaName='+ll+'&metric='+s+'&release='+str(date)
        req = 'areaType=' + at + '&areaName=' + ll + '&metric=' + s
        response = requests.get(url+req, timeout=10)
        gen = response.json()['body'][::-1]
        if s == 'newDeaths28DaysByDeathDate':
            dtd = []
            for day in gen:
                dtd.append(day['date'])
                dataLoc['deaths'].append(day[s])
        else:
            dt = []
            for day in gen:
                dt.append(day['date'])
                d = [[]]*19  # np.zeros(19)
                for a in day[s]:
                    ia = age.index(a['age'])
                    d[ia] = a['value']
                dataLoc[s].append(d)
    data[ll] = dataLoc
    dates[ll] = dt
    dates_deaths[ll] = dtd
data['London']['hosp'] = pd.read_csv('https://api.coronavirus.data.gov.uk/v2/data?areaType=nhsRegion&areaCode=E40000003&metric=cumAdmissionsByAge&format=csv').iloc[::-1]
i65 = data['London']['hosp']['age'] == '65_to_84'
i85 = data['London']['hosp']['age'] == '85+'
dateLhosp = [np.datetime64(x) for x in data['London']['hosp']['date'][i65]]
old = np.asarray(data['London']['hosp']['value'][i65]) + np.asarray(data['London']['hosp']['value'][i85])
old[1:] = np.diff(old)
# df = pd.read_json(response.text)
start = 13  # avoid empty
male = np.asarray(data['London']['maleCases'][start:])
female = np.asarray(data['London']['femaleCases'][start:])
London = np.diff(male + female, axis=0)

dateL = [np.datetime64(dates['London'][x]) for x in range(start+1,len(dates['London']))]
dateLdeaths = [np.datetime64(dates_deaths['London'][x]) for x in range(start+1,len(dates_deaths['London']))]
clipEnd = 3
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
figLon = go.Figure(layout=layout)
figLon.add_trace(go.Scatter(x=dateLdeaths, y=np.asarray(data['London']['deaths']),
                            name='deaths', line_color='black', line_width=1))
# figLon.add_trace(go.Scatter(x=dateLhosp+np.timedelta64(21), y=movmean(old, 7, nanTail=False),
#                             name='hosp 65+', line_color='red', line_width=1))
figLon.add_trace(go.Scatter(x=dateL,
                            y=np.sum(London[:, 12:], axis=1),
                            yaxis='y2', name='cases 60+', line_color='#0000cc', line_width=1))
figLon.add_trace(go.Scatter(x=dateL,
                            y=np.sum(London[:, 9:12], axis=1),
                            yaxis='y2', name='cases 45-60', line_color='#5555ff'))
figLon.add_trace(go.Scatter(x=dateL,
                            y=np.sum(London[:, 6:9], axis=1),
                            yaxis='y2', name='cases 30-45', line_color='#7777ff'))
figLon.add_trace(go.Scatter(x=dateL,
                            y=np.sum(London[:, 3:6], axis=1),
                            yaxis='y2', name='cases 15-30', line_color='#9999ff'))
figLon.add_trace(go.Scatter(x=dateL,
                            y=np.sum(London[:, 0:3], axis=1),
                            yaxis='y2', name='cases <15', line_color='#ccccff'))
figLon.layout['title'] = 'London daily cases by age and deaths (all ages)'
figLon.layout['yaxis']['dtick'] = 50
figLon.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 250])
figLon.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
figLon.update_layout(hovermode="x unified",
        yaxis2=dict(
            title="Cases",
            anchor="free",
            overlaying="y",
            side="right",
            position=1,
            zerolinecolor='lightgray',
            gridcolor='lightgray',
            dtick=500,
            range=[0, 2500]
        ),
        legend = dict(
            yanchor="top",
            y=0.99,
            xanchor="left",
            x=0.1
        )
                     )
figLon.layout['yaxis']['title'] = "Deaths"
figLon.layout['yaxis']['titlefont']['color'] = "black"
figLon.layout['yaxis']['showgrid'] = False
figLon.layout['yaxis2']['titlefont']['color'] = "blue"
ratios = {'Sep': [10, 44, 198], 'Jan': [196, 453, 1279]}
start_date = {'Sep': '2021-8-1', 'Jan': '2020-12-1'}
def make_fig_shift(case_shift=21, hosp_shift=18, death_shift=0, rat='Sep'):
    figLonNorm = go.Figure(layout=layout)
    figLonNorm.add_trace(go.Scatter(x=dateLdeaths+np.timedelta64(death_shift), y=movmean(np.asarray(data['London']['deaths']), 7, nanTail=False)/ratios[rat][0],
                                    name='deaths', line_color='black', line_width=3))
    figLonNorm.add_trace(go.Scatter(x=dateLhosp[:-clipEnd]+np.timedelta64(hosp_shift), y=movmean(old[:-clipEnd], 7, nanTail=False)/ratios[rat][1],
                                    name='hosp 65+', line_color='red', line_width=1))
    figLonNorm.add_trace(go.Scatter(x=dateL[:-clipEnd]+np.timedelta64(case_shift),
                                    y=movmean(np.sum(London[:-clipEnd, 13:], axis=1), 7, nanTail=False)/ratios[rat][2],
                                    name='cases 65+', line_color='#0000cc', line_width=3))
    figLonNorm.layout['xaxis']['range'] = [start_date[rat], str(dateL[-1]+np.timedelta64(31))]
    figLonNorm.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
    figLonNorm.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
    figLonNorm.update_layout(hovermode="x unified",
                             legend=dict(
                                 yanchor="top",
                                 y=0.99,
                                 xanchor="left",
                                 x=0.5
                             ))
    figLonNorm.layout['yaxis']['title'] = "1 = "+rat+" 2021 peak"
    figLonNorm.layout['title'] = 'London - normalized deaths (all), hospital admissions (65+) and cases (65+).<br>' \
                                 'Time shifts (days)->   cases: '+str(case_shift)+',  hospitalizations: '+str(hosp_shift)+', deaths:'+str(death_shift)
    return figLonNorm
##
start = 25
male = np.asarray(data['England']['maleCases'][start:])
female = np.asarray(data['England']['femaleCases'][start:])
England = np.diff(male + female, axis=0)
dateE = [np.datetime64(dates['England'][x]) for x in range(start+1,len(dates['England']))]
dateEdeaths = [np.datetime64(dates_deaths['England'][x]) for x in range(start+1,len(dates_deaths['England']))]
shift = 35
figEng = go.Figure(layout=layout)
figEng.add_trace(go.Scatter(x=dateEdeaths, y=movmean(np.asarray(data['England']['deaths']), 7, nanTail=False),
                            name='deaths', line_color='black', line_width=3))
figEng.add_trace(go.Scatter(x=dateE[:-1]+np.timedelta64(shift),
                            y=movmean(np.sum(England[:-1,12:], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases 60+', line_color='#0000cc', line_width=3))
figEng.add_trace(go.Scatter(x=dateE[:-1]+np.timedelta64(shift),
                            y=movmean(np.sum(England[:,9:12], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases 45-60', line_color='#5555ff'))
figEng.add_trace(go.Scatter(x=dateE[:-1]+np.timedelta64(shift),
                            y=movmean(np.sum(England[:,6:9], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases 30-45', line_color='#7777ff'))
figEng.add_trace(go.Scatter(x=dateE[:-1]+np.timedelta64(shift),
                            y=movmean(np.sum(England[:,3:6], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases 15-30', line_color='#9999ff'))
figEng.add_trace(go.Scatter(x=dateE[:-1]+np.timedelta64(shift),
                            y=movmean(np.sum(England[:,0:3], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases <15', line_color='#ccccff'))
figEng.layout['title'] = 'England daily cases by age (shifted '+str(shift)+' days ahead) and deaths (all ages)'
figEng.layout['yaxis']['dtick'] = 250
figEng.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 1500])
figEng.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
figEng.update_layout(hovermode="x unified",
        yaxis2=dict(
            title="Cases",
            anchor="free",
            overlaying="y",
            side="right",
            position=1,
            zerolinecolor='lightgray',
            gridcolor='lightgray',
            dtick=2500,
            range=[0, 15000]
        ),
        legend = dict(
            yanchor="top",
            y=0.99,
            xanchor="left",
            x=0.1
        )
                     )
figEng.layout['yaxis']['title'] = "Deaths"
figEng.layout['yaxis']['titlefont']['color'] = "black"
figEng.layout['yaxis']['showgrid'] = False
figEng.layout['yaxis2']['titlefont']['color'] = "blue"
# figEng.show()

app = dash.Dash(
    __name__,
    external_stylesheets=[dbc.themes.BOOTSTRAP],
    meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
)

server = app.server
app.layout = html.Div([
    html.Div([
        html.Div([
            html.H3('England (not UK) and London COVID19 deaths, and cases by age'),
            html.A('Data are provided by '),
            # html.A(&#128081;)	U+1F451
            html.A('GOV.UK',
                   href='https://coronavirus.data.gov.uk/details/download',
                   target='_blank'),
            html.A(', see API cheat sheet '),
            html.A('here',
                   href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/apps.md",
                   target='_blank'),
            html.A('. Visualization by '),
            html.A('@yuvharpaz',
                   href="https://twitter.com/yuvharpaz",
                   target='_blank'),
            html.A(' . '),
            html.A('<code>',
                   href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/uk_cases_vs_death.py",
                   target='_blank'),
            html.Br(), html.A('Cases data were manually shifted to sync the Jan-2021 deaths rise with 60+ cases, and smoothed -3+ days. Last cases update: '+str(dateL[-1])[0:10]+'. Last deaths update: '+str(dateLdeaths[-1])),
            html.Br(), html.A('Interactive tips: You can zoom-in, double-click to zooms out, home button for reset. Hover for data preview and hide lines by clicks on legend items.'),
            html.Br(), html.A('other dashboards: '),
            html.A('South Africa',
                   href="https://sa-covid.herokuapp.com/",
                   target='_blank'),
            html.A(' , '),
            html.A('Israel',
                   href="https://covid-israel.herokuapp.com/",
                   target='_blank'),
        ]),
        dbc.Row([dbc.Col(html.H3('London'), lg=6),
                 dbc.Col(dcc.RadioItems(id='lon_rat',
                                options=[
                                    {'label': 'Sep 2021 ratios', 'value': 'Sep'},
                                    {'label': 'Jan 2020 ratios', 'value': 'Jan'}
                                ],
                                value='Sep',
                                labelStyle={'display': 'inline-block'}
                                ), lg=1,
                         )
                 ]),
        dbc.Row([
            dbc.Col([" "], lg=6),
            dbc.Col(["shift cases by N days ",
                     dcc.Input(id='shc', value=21, type='number')], lg=2),  # style={'width': '1%'} not working
            dbc.Col(["shift hospitalizations by N days",
                     dcc.Input(id='shh', value=18, type='number')], lg=2),
            dbc.Col(["shift deaths by N days",
                     dcc.Input(id='shd', value=0, type='number')], lg=2)
        ]),
        dbc.Row([dbc.Col(dcc.Graph(figure=figLon), lg=6),
                 dbc.Col(dcc.Graph(id='lonorm'), lg=6)]),
        dbc.Row([html.H3('England')]),
        dbc.Row([dbc.Col(dcc.Graph(figure=figEng), lg=6)]),
    ])
])

@app.callback(
    Output('lonorm', 'figure'),
    Input('shc', 'value'),
    Input('shh', 'value'),
    Input('shd', 'value'),
    Input('lon_rat', 'value'))


def update_graph(case_shift, hosp_shift, death_shift, lr):
    fig_shift = make_fig_shift(case_shift, hosp_shift, death_shift, rat=lr)
    return fig_shift


if __name__ == '__main__':
    app.run_server(debug=True)