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
import plotly.graph_objects as go
import dash_bootstrap_components as dbc


def movmean(vec, win, nanTail=False):
    #  smooth a vector with a moving average. win should be an odd number of samples.
    #  vec is np.ndarray size (N,) or (N,0)
    #  to get smoothing of 3 samples back and 3 samples forward use win=7
    smooth = vec.copy()
    if win > 1:
        if nanTail:
            smooth[:] = np.nan
        for ii in range(int(win/2),len(vec)-int(win/2)):
            smooth[ii] = np.nanmean(vec[ii-int(win/2):ii+int(win/2)+1].astype(float))
    return smooth

url1 = 'https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_raw_hospitalization.csv'
df = pd.read_csv(url1)
df = df[df.Owner.isin(['Total'])]

url2 = 'https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_confirmed.csv'
dfCases = pd.read_csv(url2)
date2 = pd.to_datetime(dfCases['date'], format='%d-%m-%Y')
date2 = [np.datetime64(x) for x in date2]
region = ['Eastern Cape', 'Free State', 'Gauteng', 'KwaZulu-Natal', 'Limpopo', 'Mpumalanga',
          'North West', 'Northern Cape', 'Western Cape', 'Total']
dfCases.columns = ['date', 'YYYYMMDD', 'Eastern Cape', 'Free State', 'Gauteng', 'KwaZulu-Natal', 'Limpopo', 'Mpumalanga',
                   'Northern Cape', 'North West', 'Western Cape', 'UNKNOWN', 'Total', 'source']
dfCases = dfCases.drop(columns='UNKNOWN')
for col in dfCases.columns[2:12]:
    dif = np.zeros((len(date2)))
    dif[0] = dfCases[col][0]
    dif[1:] = np.diff(dfCases[col])
    dfCases[col] = dif
for badCases in ['23-11-2021', '12-12-2021']:
    row = np.where(dfCases['date'] == badCases)[0][0]
    for col in dfCases.columns[2:12]:
        dfCases[col].at[row] = np.nan
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')  # , xaxis_range=xl
date = np.asarray([np.datetime64(x) for x in list(df['Date'])])

field = ['Facilities Reporting', 'Admissions to Date', 'Died to Date', 'Discharged to Date',
         'Currently Admitted', 'Currently in ICU', 'Currently Ventilated', 'Currently Oxygenated',
         'Admissions in Previous Day']

figs = []
for ff in np.asarray(field)[[2, 4, 5, 6, 7, 8]]:
    figs.append(go.Figure(layout=layout))
    figs[-1].update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
    figs[-1].update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
    mask = df.variable.isin([ff.replace(' ', '')])
    dff = df[mask]
    for rr in region:
        mask = dff.Province.isin([rr.replace(' ', '')])
        dfr = dff[mask]

        yy = np.asarray(dfr['value']).astype('float')
        if ff == 'Died to Date' or ff == 'Admissions to Date':
            spike = np.where(dfr['Date'] == '2021-11-23')[0][0]
            yy[spike] = (yy[spike - 1] + yy[spike + 1]) / 2
            yy = np.diff(yy)
            bad1 = np.where(dfr['Date'] == '2020-10-05')[0][0]

            for bad in np.asarray([0, 1, 2, 3, 77, 92, 238]) + bad1:
                yy[bad] = np.nan
            for bad in np.where(yy < 0)[0]:
                yy[bad] = np.nan
            if ff == 'Died to Date' and rr == 'Total':
                deaths = yy
                dateDeaths = dfr['Date']
        else:
            for bad in [bad1 + 94]:
                yy[bad] = np.nan
            if ff == 'Admissions in Previous Day' and rr == 'Total':
                hosp = yy
        figs[-1].add_trace(go.Scatter(x=dfr['Date'], y=yy, name=rr))
    figs[-1].layout['title'] = ff


figCases = go.Figure(layout=layout)
for rr in region[:-1]+['Total']:
    figCases.add_trace(go.Scatter(x=date2, y=dfCases[rr], name=rr))
figCases.layout['title'] = 'Cases'
figCases.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
figCases.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')

figHospDeath = go.Figure(layout=layout)
figHospDeath.add_trace(go.Scatter(x=dateDeaths, y=movmean(deaths, 7, True), name='deaths', line_color='black'))
figHospDeath.add_trace(go.Scatter(x=dfr['Date'], y=movmean(hosp, 7, True), name='hospitalizations', line_color='red'))
figHospDeath.layout['title'] = 'Deaths vs Hospitalizations'
figHospDeath.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
figHospDeath.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
figHospDeath.update_layout(hovermode="x unified")
figHospDeath.layout['yaxis']['dtick'] = 150

figCaseHosp = go.Figure(layout=layout)
figCaseHosp.add_trace(go.Scatter(x=dfr['Date'], y=movmean(hosp, 7, True), name='hospitalizations', line_color='red'))
figCaseHosp.add_trace(go.Scatter(x=date2, y=movmean(dfCases['Total'], 7, True), yaxis='y2', name='cases', line_color='blue'))
figCaseHosp.layout['title'] = 'Cases vs Hospitalizations'
figCaseHosp.layout['yaxis']['dtick'] = 150
figCaseHosp.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 720])
figCaseHosp.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
figCaseHosp.update_layout(hovermode="x unified",
        yaxis2=dict(
            title="Cases",
            anchor="free",
            overlaying="y",
            side="right",
            position=1,
            zerolinecolor='lightgray',
            gridcolor='lightgray',
            range=[0, 24000]
        ), )
figCaseHosp.layout['yaxis']['title'] = "Patients"
figCaseHosp.layout['yaxis']['titlefont']['color'] = "red"
figCaseHosp.layout['yaxis2']['titlefont']['color'] = "blue"

mask = df.Province.isin(['Total'])
dfSA = df[mask]
# dfSA['Currently Admitted'][2229] = np.nan
figCurrent = go.Figure(layout=layout)
field4 = list(np.asarray(field)[[4, 7, 5, 6]])
yax = ['y1', 'y2', 'y2', 'y2']
for ii, ff in enumerate(field4):
    mask = dfSA.variable.isin([ff.replace(' ', '')])
    dfSAf = dfSA[mask]
    figCurrent.add_trace(go.Scatter(x=dfSAf['Date'], y=dfSAf['value'], yaxis=yax[ii], name=ff[10:]))
    figCurrent.layout['title'] = 'Currently hospitalized'
    figCurrent.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
    figCurrent.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
figCurrent.layout['yaxis']['title'] = 'All patients'
figCurrent['data'][0]['line']['color'] = 'blue'
figCurrent['data'][2]['line']['color'] = '#ffaaaa'
figCurrent['data'][3]['line']['color'] = '#ffcccc'
figCurrent.layout['yaxis']['dtick'] = 3000
figCurrent.layout['yaxis']['range'] = [0, 15000]
figCurrent.layout['yaxis']['titlefont']['color'] = "blue"
figCurrent.update_layout(hovermode="x unified",
        yaxis2=dict(
            title="Oxy / ICU",
            anchor="free",
            overlaying="y",
            side="right",
            position=1,
            zerolinecolor='lightgray',
            gridcolor='lightgray',
            range=[0, 5000]
        ), )
figCurrent.layout['yaxis2']['titlefont']['color'] = "red"
app = dash.Dash(
    __name__,
    external_stylesheets=[dbc.themes.BOOTSTRAP],
    meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
)

server = app.server
app.layout = html.Div([
    html.Div([
        html.Div([
            html.H3('South Africa COVID19 hospitalizations data'),
            html.A("The "),
            html.A('hospitalizations',
                   href="https://github.com/dsfsi/covid19za/blob/master/data/covid19za_provincial_raw_hospitalization.csv",
                   target='_blank'),
            html.A(" and "),
            html.A('cases',
                   href='https://github.com/dsfsi/covid19za/blob/master/data/covid19za_provincial_cumulative_timeline_confirmed.csv',
                   target='_blank'),
            html.A(' data are provided by '),
            html.A('NICD',
                   href='https://www.nicd.ac.za/diseases-a-z-index/disease-index-covid-19/surveillance-reports/daily-hospital-surveillance-datcov-report/',
                   target='_blank'),
            html.A(' via '),
            html.A('@vokusi',
                   href="https://twitter.com/vukosi",
                   target='_blank'),
            html.A(' and '),
            html.A('@SalomonKabongo',
                   href="https://twitter.com/SalomonKabongo",
                   target='_blank'),
            html.A('. Visualization by '),
            html.A('@yuvharpaz',
                   href="https://twitter.com/yuvharpaz",
                   target='_blank'),
            html.A(' . '),
            html.A('<code>',
                   href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/covid_SA_plot2.py",
                   target='_blank'),
            html.Br(), html.A('Note that data here is by reporting date. Last cases update: '+str(date2[-1])[0:10]+'. Last hospitalizations update: '+str(date[-1])),
            html.Br(), html.Br()
        ]),
        dbc.Row([html.H3('Incidence data: new cases, hospital admissions and deaths.')]),
        dbc.Row([
            dbc.Col(dcc.Graph(figure=figHospDeath), lg=6),
            dbc.Col(dcc.Graph(figure=figCaseHosp), lg=6)
        ]),
        dbc.Row([
            dbc.Col(dcc.Graph(figure=figCases), lg=6),
            dbc.Col(dcc.Graph(figure=figs[5]), lg=6),
            dbc.Col(dcc.Graph(figure=figs[0]), lg=6)
        ]),
    dbc.Row([html.H3('Prevalence data: currently hospitalized cases, cases with oxygen support, in ICU and with mechanical ventilation.')]),
        dbc.Row([dbc.Col(dcc.Graph(figure=figCurrent), lg=6)]),
        dbc.Row([
            dbc.Col(dcc.Graph(figure=figs[1]), lg=6),
            dbc.Col(dcc.Graph(figure=figs[4]), lg=6)
        ]),
        dbc.Row([
            dbc.Col(dcc.Graph(figure=figs[2]), lg=6),
            dbc.Col(dcc.Graph(figure=figs[3]), lg=6)
        ]),
    ])
])
if __name__ == '__main__':
    app.run_server(debug=True)