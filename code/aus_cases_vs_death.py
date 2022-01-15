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

data = pd.read_csv('https://raw.githubusercontent.com/M3IT/COVID-19_Data/master/Data/COVID19_Data_Hub.csv')
data = data[data['administrative_area_level_2'].isna()]
date = np.asarray(data['date'])
cases = np.asarray(data['confirmed'])
cases[1:] = np.diff(cases)
# casesAge = pd.read_csv('/home/innereye/Downloads/tmp.csv')
casesAge = pd.read_csv('https://data.nsw.gov.au/data/dataset/nsw-covid-19-cases-by-age-range/resource/24b34cb5-8b01-4008-9d93-d14cf5518aec/download/confirmed_cases_table2_age_group.csv')
date65 = np.asarray(casesAge['notification_date'])
date65 = np.unique(date65)
ages = np.asarray(casesAge['age_group'])
ages = np.unique(ages)
cases65 = np.zeros(len(date65))
ratio = np.zeros(len(date65))
for row, ymd in enumerate(date65):
    all = int(cases[date == ymd])
    dat = np.asarray(casesAge['age_group'][casesAge['notification_date'] == ymd])
    dat = np.delete(dat, dat == 'AgeGroup_None')
    ratio[row] = (np.sum(dat == 'AgeGroup_65-69') + np.sum(dat == 'AgeGroup_70+'))/len(dat)
    cases65[row] = np.round(ratio[row]*all)

deaths = np.asarray(data['deaths'])
deaths[1:] = np.diff(deaths)
date65 = [np.datetime64(x) for x in date65]
date = [np.datetime64(x) for x in date]
nrm = [1, 2100/14, 120/14]
clipEnd = 1
shift = 14
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
fig = go.Figure(layout=layout)
y = deaths  # movmean(deaths[:-clipEnd], 7)/nrm[0]
fig.add_trace(go.Scatter(x=date, y=y, name='deaths', line_color='black', line_width=3))
y = np.round(movmean(cases[:-clipEnd], 7)/nrm[1])
fig.add_trace(go.Scatter(x=date[:-clipEnd]+np.timedelta64(shift), y=y, name='cases/150', line_color='cyan', line_width=3))
y65 = np.round(movmean(cases65[:-clipEnd], 7)/nrm[2])
fig.add_trace(go.Scatter(x=date65[:-clipEnd]+np.timedelta64(shift), y=y65, name='cases 65+/8.5', line_color='blue', line_width=3))
fig.layout['title'] = 'Australia, cases vs deaths'
fig.layout['yaxis']['dtick'] = 50
fig.update_layout(hovermode="x unified", legend=dict(yanchor="top", y=0.99, xanchor="left", x=0.1))
fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')  #  range=[0, 250]
fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
fig.layout['xaxis']['range'] = ['2021-8-1', str(date[-1]+np.timedelta64(31))]
fig.layout['yaxis']['title'] = "deaths or expected deaths"
fig.layout['yaxis']['titlefont']['color'] = "black"
app = dash.Dash(
    __name__,
    external_stylesheets=[dbc.themes.BOOTSTRAP],
    meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
    )

server = app.server
app.layout = html.Div([dbc.Row([dbc.Col([dcc.Graph(figure=fig)], lg=8)])])
if __name__ == '__main__':
    app.run_server(debug=True)
