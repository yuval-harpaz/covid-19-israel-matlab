import os
import pandas as pd
import numpy as np
from dash import dcc, callback_context, html, Dash
from dash.dependencies import Input, Output, State
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
import urllib.request
import json
import requests

local = '/home/innereye/covid-19-israel-matlab/'
if os.path.isdir(local):
    os.chdir(local)
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

# if os.path.isfile('/home/innereye/Downloads/VerfiiedVaccinationStatusDaily'):
#     api = '/home/innereye/Downloads/'
#     dfAge = pd.read_csv(
#         '/home/innereye/covid-19-israel-matlab/data/Israel/cases_by_age.csv')
# else:
api = 'https://datadashboardapi.health.gov.il/api/queries/'
warning = ''
# try:
#     dfAge = pd.read_csv('https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/cases_by_age.csv')
#     dfAge.to_csv('cases_by_age.csv', index=False, sep=',')
# except:
#     warning += ' | download cases_by_age failed'
#     dfAge = pd.read_csv('cases_by_age.csv')
try:
    dfTS = pd.read_json(requests.get(api+'hospitalizationStatus', verify=False).text)
    prev = pd.read_csv('data/Israel/hospitalizationStatus.csv')
    if prev.loc[len(prev)-1, 'date'] == dfTS.loc[len(dfTS)-1, 'dayDate'][:10]:
        raise Exception('no new dates')
    cn = list(dfTS.columns)
    cn[0] = 'date'
    dfTS.columns = cn
    # dfTS = dfTS[dfTS.duplicated(['date'], keep=False)]
    dfTS = dfTS.drop_duplicates(subset=['date'], keep='first')
    dfTS.sort_values('date')
    dfTS['date'] = dfTS['date'].str.slice(start=None, stop=10)
    dfTS.to_csv('data/Israel/hospitalizationStatus.csv', index=False, sep=',')
    # dfTS.to_csv('hospitalizationStatus.csv', index=False, sep=',')
except:
    raise Exception('download hospitalizationStatus failed')

dfTS = dfTS[0:len(dfTS)-1]
dfTS['date'] = pd.to_datetime(dfTS['date'])
dfTS['vent'] = dfTS['countBreathCum'].to_numpy()
dfTS.loc[1:, 'vent'] = np.diff(dfTS['countBreathCum'].to_numpy())
dfTS['newSevere'] = dfTS['countSeriousCriticalCum'].to_numpy()
dfTS.loc[1:, 'newSevere'] = np.diff(dfTS['countSeriousCriticalCum'].to_numpy())
cco = [(91, 163, 0), (137, 206, 0), (0, 115, 230), (230, 48, 148), (181, 25, 99), (0, 0, 0)]
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', legend={'traceorder': 'reversed'})
layout1 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
columns = ['newHospitalized', 'newSevere','vent','countDeath']
label = ['מאושפזים', 'חולים-קשה' , 'מונשמים','נפטרים']
fig1 = go.Figure(layout=layout1)
for ii in range(len(columns)):
    fig1.add_trace(go.Scatter(x=dfTS['date'], y=movmean(dfTS[columns[ii]].to_numpy(), 7, True),
                              mode='lines', line_color='#%02x%02x%02x' % cco[ii+2], name=label[ii]))
fig1.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', type='log', side='right')
fig1.update_yaxes(range=(-0.25, 3))
fig1.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%b\n%Y")
fig1.update_layout(legend=dict(yanchor="top", y=0.99, xanchor="left", x=0.85, font=dict(size=20)))
fig1.update_layout(title=dict(text="קורונה בישראל, מקרים חדשים לפי חומרה", font_size=40, xanchor='center', x=0.5), font_size=20)
# fig1.show()


txt0 = '<h1>Israel COVID19 data from the Ministry of Health</h1>'+\
    '<h2>New cases by condition</h2>'
txt = txt0+'by <a href="https://twitter.com/yuvharpaz" target="_blank">@yuvharpaz</a>. '+\
      ' <a href='+api+'hospitalizationStatus>source</a>, '+\
      '<a href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/hospitalizationStatus.csv">sheet</a><br>'
txt = txt+'see also <a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc_abs.html" target="_blank">Cases by Vaccination Status</a><br>'
txt = txt+fig1.to_html()
file = open("docs/hospitalizations.html", "w")
a = file.write(txt)
file.close()
print('tada')
#     dfTS = pd.read_csv('hospitalizationStatus.csv')
# hospitalizationStatus = dfTS.to_csv(index=False)
