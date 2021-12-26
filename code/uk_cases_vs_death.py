# from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import requests
import dash
from dash import dcc
from dash import html
import plotly.graph_objects as go
import dash_bootstrap_components as dbc

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
# df = pd.read_json(response.text)
start = 13  # avoid empty
male = np.asarray(data['London']['maleCases'][start:])
female = np.asarray(data['London']['femaleCases'][start:])
London = np.diff(male + female, axis=0)
dateL = [np.datetime64(dates['London'][x]) for x in range(start+1,len(dates['London']))]
dateLdeaths = [np.datetime64(dates_deaths['London'][x]) for x in range(start+1,len(dates_deaths['London']))]

layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
figLon = go.Figure(layout=layout)
figLon.add_trace(go.Scatter(x=dateLdeaths, y=movmean(np.asarray(data['London']['deaths']), 7, nanTail=False),
                            name='deaths', line_color='black', line_width=3))
figLon.add_trace(go.Scatter(x=dateL[:-1]+np.timedelta64(21),
                            y=movmean(np.sum(London[:-1,12:], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases 60+', line_color='#0000cc', line_width=3))
figLon.add_trace(go.Scatter(x=dateL[:-1]+np.timedelta64(21),
                            y=movmean(np.sum(London[:,9:12], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases 45-60', line_color='#5555ff'))
figLon.add_trace(go.Scatter(x=dateL[:-1]+np.timedelta64(21),
                            y=movmean(np.sum(London[:,6:9], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases 30-45', line_color='#7777ff'))
figLon.add_trace(go.Scatter(x=dateL[:-1]+np.timedelta64(21),
                            y=movmean(np.sum(London[:,3:6], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases 15-30', line_color='#9999ff'))
figLon.add_trace(go.Scatter(x=dateL[:-1]+np.timedelta64(21),
                            y=movmean(np.sum(London[:,0:3], axis=1), 7, nanTail=False),
                            yaxis='y2', name='cases <15', line_color='#ccccff'))
figLon.layout['title'] = 'London daily cases by age (shifted 21 days ahead) and deaths (all ages)'
figLon.layout['yaxis']['dtick'] = 25
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
figLon.layout['yaxis2']['titlefont']['color'] = "blue"
# figLon.show()


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
figEng.layout['yaxis']['dtick'] = 100
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
            dtick=1000,
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
        dbc.Row([html.H3('London')]),
        dbc.Row([dbc.Col(dcc.Graph(figure=figLon), lg=8)]),
        dbc.Row([html.H3('England')]),
        dbc.Row([dbc.Col(dcc.Graph(figure=figEng), lg=8)]),
    ])
])
if __name__ == '__main__':
    app.run_server(debug=True)