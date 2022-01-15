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



data = pd.read_csv('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/data-by-day.csv')
tests = pd.read_csv('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/testing-by-age.csv')
cases65 = np.round(np.asarray(tests['numtest_75up']*tests['perpos_75up']/100+tests['numtest_65_74']*tests['perpos_65_74']/100))
dateW = [np.datetime64(x[-4:]+'-'+x[:2]+'-'+x[3:5])-np.timedelta64(3) for x in tests['week_ending']]
date = [np.datetime64(x[-4:]+'-'+x[:2]+'-'+x[3:5]) for x in data['date_of_interest']]

nrm = [1, 5, 60, 12]
# nrm = [1,1,1,1]
# nrm = [83,397,5184,6753]
clipEnd = 3
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
fig = go.Figure(layout=layout)
fig.add_trace(go.Scatter(x=date, y=movmean(np.asarray(data['DEATH_COUNT'][:-clipEnd]), 7)/nrm[0],
                            name='deaths', line_color='black', line_width=3))
fig.add_trace(go.Scatter(x=date[:-clipEnd]+np.timedelta64(17), y=movmean(np.asarray(data['HOSPITALIZED_COUNT'][:-clipEnd])/nrm[1], 7),
                            name='hosp /'+str(nrm[1])+'            17 days ahead', line_color='red', line_width=3))
fig.add_trace(go.Scatter(x=date[:-clipEnd]+np.timedelta64(20), y=movmean(np.asarray(data['CASE_COUNT'][:-clipEnd-1])/nrm[2], 7),
                            name='cases /'+str(nrm[2])+'         20 days ahead', line_color='cyan', line_width=3))
fig.add_trace(go.Scatter(x=dateW+np.timedelta64(15), y=cases65/7/nrm[3],
                            name='cases 65+ /'+str(nrm[3])+'  15 days ahead', line_color='blue', line_width=3))

fig.layout['title'] = 'NYC cases vs hosp vs deaths'
# fig.layout['yaxis']['dtick'] = 1
fig.update_layout(hovermode="x unified", legend=dict(yanchor="top", y=0.99, xanchor="left", x=0.1))
fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')  #  range=[0, 250]
fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
fig.layout['xaxis']['range'] = ['2020-11-1', str(date[-1]+np.timedelta64(31))]
fig.layout['yaxis']['title'] = "1 = Aug peak"
fig.layout['yaxis']['titlefont']['color'] = "black"
# fig.layout['yaxis']['showgrid'] = False
# fig.show()


app = dash.Dash(
    __name__,
    external_stylesheets=[dbc.themes.BOOTSTRAP],
    meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
)

server = app.server
app.layout = html.Div([dbc.Row([dbc.Col(dcc.Graph(figure=fig), lg=6)])])

if __name__ == '__main__':
    app.run_server(debug=True)