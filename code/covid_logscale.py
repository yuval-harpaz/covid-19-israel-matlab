import os
import pandas as pd
import numpy as np
import sys
import plotly.graph_objects as go
import requests
api = 'https://datadashboardapi.health.gov.il/api/queries/'
local = '/home/innereye/covid-19-israel-matlab/'
if os.path.isdir(local):
    os.chdir(local)
    remote = False
else:
    remote = True

update = requests.get(api+'lastUpdate', verify=False).json()
update = update[0]['lastUpdate'].replace('T', ' ')[:-5]
with open('docs/hospitalizations.html', 'r') as file:
    prev_update = file.read()[15:34]

if update == prev_update:
    print('no news')
    if remote:
        sys.exit(0)


def movmean(vec, win, nanTail=False, round=0):
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
    smooth = np.round(smooth, round)
    return smooth

try:
    dfTS = pd.read_json(requests.get(api+'hospitalizationStatus', verify=False).text)
    prev = pd.read_csv('data/Israel/hospitalizationStatus.csv')
    # if prev.loc[len(prev)-1, 'date'] == dfTS.loc[len(dfTS)-1, 'dayDate'][:10]:
    #     raise Exception('no new dates')
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

# try:
#     dfInfected = pd.read_json(requests.get(api + 'infectedPerDate', verify=False).text)
#     dfCases = pd.read_json(requests.get(api + 'testResultsPerDate', verify=False).text)
#     # dfTS = dfTS[dfTS.duplicated(['date'], keep=False)]
#     dfCases = dfCases.drop_duplicates(subset=['date'], keep='first')
#     dfCases.sort_values('date')
#     # dfCases['date'] = dfCases['date'].str.slice(start=None, stop=10)
#     dfCases.to_csv('data/Israel/testResultsPerDate.csv', index=False, sep=',', date_format='%Y-%m-%d')
# except:
#     raise Exception('download cases failed')

try:
    dfCases = pd.read_json(requests.get(api + 'infectedPerDate', verify=False).text)
    # dfCases = pd.read_json(requests.get(api + 'testResultsPerDate', verify=False).text)
    # dfTS = dfTS[dfTS.duplicated(['date'], keep=False)]
    dfCases = dfCases.drop_duplicates(subset=['date'], keep='first')
    dfCases = dfCases.sort_values('date')
    # dfCases['date'] = dfCases['date'].str.slice(start=None, stop=10)
    dfCases.to_csv('data/Israel/infectedPerDate.csv', index=False, sep=',', date_format='%Y-%m-%d')
except:
    raise Exception('download cases failed')


dfCases = dfCases[0:len(dfCases)-1]

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
round = [0, 0, 1, 1]
fig1 = go.Figure(layout=layout1)
fig1.add_trace(go.Scatter(x=dfCases['date'], y=movmean(dfCases['amount'].to_numpy(), 7, True, 0),
                          mode='lines', line_color='#%02x%02x%02x' % cco[0], name='מאומתים'))
for ii in range(len(columns)):
    fig1.add_trace(go.Scatter(x=dfTS['date'], y=movmean(dfTS[columns[ii]].to_numpy(), 7, True, round[ii]),
                              mode='lines', line_color='#%02x%02x%02x' % cco[ii+2], name=label[ii]))
fig1.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', type='log', side='right')
# fig1.update_yaxes(range=(-0.25, 3), minor_ticks=dict(ticks="inside", ticklen=6, showgrid=True))
fig1.update_yaxes(range=(-0.25, 5), tickmode='array',
                  tickvals=[1,2,3,4,5,6,7,8,9,10,
                            20,30,40,50,60,70,80,90,100,
                            200,300,400,500,600,700,800,900,1000,
                            2000,3000,4000,5000,6000,7000,8000,9000,10000,
                            20000,30000,40000,50000,60000,70000,80000,90000,100000],
                  ticktext=['1',
                            '','','','','','','','','10',
                            '','','','','','','','','100',
                            '','','','','','','','','1,000',
                            '','','','','','','','','10,000',
                            '','','','','','','','','100,0000'])
fig1.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%d/%m\n%Y")
fig1.update_layout(legend=dict(yanchor="top", y=0.99, xanchor="left", x=0.85, font=dict(size=20)),
                   margin=dict(l=0, r=0, t=0, b=0))
# fig1.update_layout(title=dict(text="קורונה בישראל, מקרים חדשים לפי חומרה", font_size=40, xanchor='center', yanchor='bottom', x=0.5, y=0.8),
#                    font_size=20)
txt0 = '<!last update: '+update+'>\n'
    # '<h2>New cases by condition</h2>'
txt = txt0+'by <a href="https://twitter.com/yuvharpaz" target="_blank">@yuvharpaz</a>. ' + \
      ' <a href='+api+'hospitalizationStatus>source</a>, ' + \
      '<a href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/hospitalizationStatus.csv">sheet</a>'
txt = txt+'. last update- '+update+'. see also <a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc.html" target="_blank">Cases by Vaccination Status</a><br>'
txt = txt+'<h1><center>קורונה בישראל, מקרים חדשים לפי חומרה</center></h1>'
txt = txt+fig1.to_html()
file = open("docs/hospitalizations.html", "w")
a = file.write(txt)
file.close()
print('tada')

