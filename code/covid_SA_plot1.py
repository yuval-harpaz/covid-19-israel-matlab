'''
Visualizing South Africa's COVID19 hospitalizations as appear in alex1770's github repo.
Deaths data was converted from cumulative to daily, and some bad data was ignored.
@yuvharpaz on twitter
'''

import pandas as pd
import numpy as np
import urllib.request
import json
import dash
from dash import dcc
from dash import html
import plotly.express as px
import plotly.graph_objects as go
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
url1 = 'https://raw.githubusercontent.com/alex1770/Covid-19/master/VOCgrowth/EarlyOmicronEstimate/extracthospdata/SouthAfricaHospData.json'
with urllib.request.urlopen(url1) as api1:
    data1 = json.loads(api1.read().decode())
date = list(data1.keys())
date = np.asarray(date)
date.sort()
region = list(data1[date[-1]].keys())
field = list(data1[date[-1]][region[0]].keys())
column = [[], [], [], [], [], [], [], [], [], [], []]
for dd in date:
    for rr in region:
        column[0].append(dd)
        column[1].append(rr)
        for ii, ff in enumerate(field):
            column[2 + ii].append(np.nan)
            if rr in data1[dd].keys():
                if ff in data1[dd][rr].keys():
                    column[2+ii][-1] = data1[dd][rr][ff]

df = pd.DataFrame(column)
dft = df.transpose()
dft.columns = ['Date', 'Region']+field
# dft.to_csv('SA.csv', index=False)
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')  # , xaxis_range=xl
date = np.asarray([np.datetime64(x) for x in list(dft['Date'])])
# for ff in field:
#     fig = px.line(dft, x=date, y=ff, color="Region", title=ff)
#     fig.show()

figs = []
for ff in np.asarray(field)[[2, 4, 5, 6, 7, 8]]:
    figs.append(go.Figure(layout=layout))
    for rr in region:
        mask = dft.Region.isin([rr])
        dfr = dft[mask]
        yy = np.asarray(dfr[ff])
        if ff == 'Died to Date' or ff == 'Admissions to Date':
            spike = np.where(dfr['Date'] == '2021-11-23')[0][0]
            yy[spike] = (yy[spike-1]+yy[spike+1])/2
            yy = np.diff(yy)
            for bad in [129, 130, 131, 132, 205, 221, 366]:
                yy[bad] = np.nan
            for bad in np.where(yy < 0)[0]:
                yy[bad] = np.nan
        else:
            for bad in [222]:
                yy[bad] = np.nan
        figs[-1].add_trace(go.Scatter(x=dfr['Date'], y=yy, name=rr))
    # fig = go.Figure(layout=layout)
    # fig = px.line(dft, x=date, y=ff, color="Region", title=ff)
    figs[-1].layout['title'] = ff
    # figs[-1].show()
figs[0].layout['title'] = 'Died'
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
            html.A('dashboard',
                   href="https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral",
                   target='_blank'),
            html.A(' by '), html.A('@yuvharpaz.', href="https://twitter.com/yuvharpaz", target='_blank'),
            html.A(' '),
            html.A(' code ',
                   href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/covid_dash1.py",
                   target='_blank'),
            html.Br(), html.Br()
        ]),
        dbc.Row([
            dbc.Col(dcc.Graph(figure=figs[0]), lg=6),
            dbc.Col(dcc.Graph(figure=figs[1]), lg=6)
        ]),
        dbc.Row([
            dbc.Col(dcc.Graph(figure=figs[2]), lg=6),
            dbc.Col(dcc.Graph(figure=figs[3]), lg=6)
        ]),
        dbc.Row([
            dbc.Col(dcc.Graph(figure=figs[4]), lg=6),
            dbc.Col(dcc.Graph(figure=figs[5]), lg=6)
        ])
    ])
])
if __name__ == '__main__':
    app.run_server(debug=True)