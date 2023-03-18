import os
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
import requests
import sys


local = '/home/innereye/covid-19-israel-matlab/'
if os.path.isdir(local):
    os.chdir(local)
    remote = False
else:
    remote = True
api = 'https://datadashboardapi.health.gov.il/api/queries/'
update = requests.get(api+'lastUpdate', verify=False).json()
update = update[0]['lastUpdate'].replace('T', ' ')[:-5]
with open('docs/lastUpdate.txt', 'r') as file:
    prev_update = file.read()
if update == prev_update:
    print('no news')
    if remote:
        sys.exit(0)

file = open("docs/lastUpdate.txt", "w")
a = file.write(update)
file.close()
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


warning = ''
try:
    dfAge = pd.read_csv('https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/cases_by_age.csv')
    dfAge.to_csv('data/Israel/cases_by_age.csv', index=False, sep=',')
except:
    warning += ' | download cases_by_age failed'
    dfAge = pd.read_csv('data/Israel/cases_by_age.csv')
try:
    dfTS = pd.read_json(requests.get(api+'hospitalizationStatus', verify=False).text)
    cn = list(dfTS.columns)
    cn[0] = 'date'
    dfTS.columns = cn
    # dfTS = dfTS[dfTS.duplicated(['date'], keep=False)]
    dfTS = dfTS.drop_duplicates(subset=['date'], keep='first')
    dfTS.sort_values('date')
    dfTS['date'] = dfTS['date'].str.slice(start=None, stop=10)
    dfTS.to_csv('data/Israel/hospitalizationStatus.csv', index=False, sep=',')
except:
    warning += ' | download hospitalizationStatus failed'
    dfTS = pd.read_csv('data/Israel/hospitalizationStatus.csv')
hospitalizationStatus = dfTS.to_csv(index=False)


url = [api+'VerfiiedVaccinationStatusDaily',
       api+'SeriousVaccinationStatusDaily',
       api+'deathVaccinationStatusDaily']
measure = ['Cases', 'New Severe', 'Deaths']
varsNorm = [['verified_vaccinated_normalized', 'verified_expired_normalized', 'verified_not_vaccinated_normalized'],
            ['new_serious_vaccinated_normalized', 'new_serious_expired_normalized', 'new_serious_not_vaccinated_normalized'],
            ['death_vaccinated_normalized', 'death_expired_normalized', 'death_not_vaccinated_normalized']]
varsAbs = [['verified_amount_vaccinated', 'verified_amount_expired', 'verified_amount_not_vaccinated'],
           ['new_serious_amount_vaccinated', 'new_serious_amount_expired', 'new_serious_amount_not_vaccinated'],
           ['death_amount_vaccinated', 'death_amount_expired', 'death_amount_not_vaccinated']]

dfsNorm = [[], [], []]
dfsAbs = [[], [], []]
downloads = []
for ii in [0, 1, 2]:
    opfn = url[ii][len(api):]
    try:
        dfs = pd.read_json(requests.get(url[ii], verify=False).text)
        dfs.to_csv('data/Israel/'+opfn+'.csv', sep=',', index=False)
    except:
        warning += ' | download '+opfn+' failed'
        dfs = pd.read_csv('data/Israel/'+opfn+'.csv')
    downloads.append(dfs.copy())
    downloads[-1]['day_date'] = downloads[-1]['day_date'].str.slice(0, 10)
    downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('מעל גיל 60', 'over 60')
    downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('מתחת לגיל 60', 'under 60')
    downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('כלל האוכלוסיה', 'all')

    dfs['date'] = pd.to_datetime(dfs['day_date'])
    dfsNorm[ii] = dfs.rename(columns={varsNorm[ii][0]: 'vaccinated', varsNorm[ii][1]: 'expired', varsNorm[ii][2]: 'unvaccinated'})
    dfsNorm[ii] = dfsNorm[ii][['date', 'day_date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
    dfsAbs[ii] = dfs.rename(columns={varsAbs[ii][0]: 'vaccinated', varsAbs[ii][1]: 'expired', varsAbs[ii][2]: 'unvaccinated'})
    dfsAbs[ii] = dfsAbs[ii][['date', 'day_date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
# writer = pd.ExcelWriter(engine='xlsxwriter')

def make_ratios(age=1):
    dfRat = pd.DataFrame([['Delta', 'vaccinated', yy[2, age, 0, 0]/yy[1, age, 0, 0]],
                          ['Omi', 'vaccinated', yy[2, age, 1, 0]/yy[1, age, 1, 0]],
                          ['Delta', 'unvaccinated', yy[2, age, 0, 1]/yy[1, age, 0, 1]],
                          ['Omi', 'unvaccinated', yy[2, age, 1, 1]/yy[1, age, 1, 1]]],
                         columns=['wave', 'vaccination', 'death ratio'])
    dfSD = pd.DataFrame([['Delta', 'vaccinated', 'deaths', yy[2, age, 0, 0]],
                         ['Delta', 'vaccinated', 'severe', yy[1, age, 0, 0]],
                         ['Omi', 'vaccinated', 'deaths', yy[2, age, 1, 0]],
                         ['Omi', 'vaccinated', 'severe', yy[1, age, 1, 0]],
                         ['Delta', 'unvaccinated', 'deaths', yy[2, age, 0, 1]],
                         ['Delta', 'unvaccinated', 'severe', yy[1, age, 0, 1]],
                         ['Omi', 'unvaccinated', 'deaths', yy[2, age, 1, 1]],
                         ['Omi', 'unvaccinated', 'severe', yy[1, age, 1, 1], ]],
                         columns=['wave', 'vaccination', 'measure', 'value'])
    if age == 1:
        ag = ' 60+'
    else:
        ag = ' <60'
    # figDelta = go.Figure()
    # figDelta.add_trace(go.Histogram(dfSD[dfSD['wave'] == 'Delta'], x="vaccination", y="value", color='measure',
    #                         barmode='group'))
    figDelta = px.histogram(dfSD[dfSD['wave'] == 'Delta'], x="vaccination", y="value", color='measure', barmode='group')
    figDelta.data[0].text = figDelta.data[0]['y']
    figDelta.data[1].text = figDelta.data[1]['y']
    figOmi = px.histogram(dfSD[dfSD['wave'] == 'Omi'], x="vaccination", y="value", color='measure', barmode='group')
    figOmi.data[0].text = figOmi.data[0]['y']
    figOmi.data[1].text = figOmi.data[1]['y']
    figR = px.histogram(dfRat, x="vaccination", y="death ratio", color='wave', barmode='group')
    figR.data[0].text = np.round(figR.data[0]['y'], 2)
    figR.data[1].text = np.round(figR.data[1]['y'], 2)

    figOmi.layout['yaxis']['title']['text'] = 'patients'+ag
    figOmi.layout['xaxis']['title']['text'] = ''
    figOmi['data'][0]['marker']['color'] = 'black'
    figOmi['layout']['title'] = 'Wave V + VI'
    figOmi['layout']['title']['x'] = 0.45
    figOmi['layout']['title']['font_color'] = "purple"
    figOmi['layout']['title']['xanchor'] = 'center'

    figDelta.layout['yaxis']['title']['text'] = 'patients'+ag
    figDelta.layout['xaxis']['title']['text'] = ''
    figDelta['data'][0]['marker']['color'] = 'black'
    figDelta['layout']['title'] = 'Wave IV'
    figDelta['layout']['title']['x'] = 0.45
    figDelta['layout']['title']['font_color'] = "green"
    figDelta['layout']['title']['xanchor'] = 'center'

    figR.layout['yaxis']['title']['text'] = 'death to severe ratio'
    figR.layout['xaxis']['title']['text'] = ''
    figR['data'][0]['marker']['color'] = 'green'
    figR['data'][1]['marker']['color'] = 'purple'
    figR['layout']['title'] = 'Death ratio'+ag
    figR['layout']['title']['x'] = 0.45
    figR['layout']['title']['font_color'] = "black"
    figR['layout']['title']['xanchor'] = 'center'
    return figDelta, figOmi, figR

updatemenus = [
    dict(
        type="buttons",
        direction="down",
        buttons=list([
            dict(
                args=[{'yaxis.type': 'linear'}],
                label="Linear",
                method="relayout"
            ),
            dict(
                args=[{'yaxis.type': 'log'}],
                label="Log",
                method="relayout"
            )
        ])
    ),
]
x = dfAge['date']
x = pd.to_datetime(x)
yyAge = np.asarray(dfAge.iloc[:, 1:11])
label = ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80-89', '90+']
color = ['#E617E6', '#6A17E6', '#1741E6', '#17BEE6', '#17E6BE', '#17E641', '#6AE617', '#E6E617', '#E69417', '#E61717']
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', legend={'traceorder': 'reversed'})
layout1 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
fig1 = go.Figure(layout=layout1)
for ii, line in enumerate(yyAge.T):
    fig1.add_trace(go.Scatter(x=x, y=line, mode='lines', line_color=color[ii], name=label[ii]))

fig1.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
fig1.update_yaxes(range=(20, int(10000*np.ceil(np.nanmax(yyAge)/10000))))
fig1.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%b\n%Y")
fig1.update_layout(title_text="Weekly cases by age", font_size=15, updatemenus=updatemenus)
fig1.write_html('docs/cases_by_age.html')

def make_figs3(df_in, meas, age_gr='מעל גיל 60', smoo='sm', nrm=', per 100k ', start_date=[], end_date=[], loglin='linear'):
    df_age = df_in.loc[df_in["age_group"] == age_gr]
    # date = df_age['date']
    mx = np.max(df_age.max()[3:6])*1.05
    if loglin == 'log':
        mx = np.ceil(np.log(mx)/np.log(10))
    # xl = [df_age.iloc[0,0], df_age.iloc[-1,0]]
    xl = [start_date, end_date]
    if smoo == 'sm':
        for yts in ['vaccinated', 'expired', 'unvaccinated']:
            yybef = np.asarray(df_age[yts])
            yyaft = np.round(movmean(yybef, 7, nanTail=True), 1)
            yyaft[-4] = np.nan
            df_age[yts] = yyaft
        # df_age = df_age.rolling(7, min_periods=7).mean().round(1)
        # df_age['date'] = date - pd.to_timedelta(df_age.shape[0] * [3], 'd')
    fig = px.line(df_age, x="date", y=['vaccinated', 'expired', 'unvaccinated'])
    fig.update_traces(hovertemplate="%{y}")
    fig['data'][0]['line']['color'] = '#0e7d7d'
    fig['data'][1]['line']['color'] = '#b9c95b'
    fig['data'][2]['line']['color'] = '#2fcdfb'
    fig.layout = layout
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, mx], type=loglin)
    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=xl, dtick="M1", tickformat="%d/%m\n%Y")
    if age_gr == 'מעל גיל 60':
        txt60 = '(60+)'
    else:
        txt60 = '(<60)'
    fig.update_layout(title_text=meas+' by vaccination status'+nrm+txt60, font_size=15, hovermode="x unified",
                      legend=dict(
                          yanchor="top",
                          y=1.1,
                          xanchor="left",
                          x=0.05
                      ),
                      width=800,
                      height=600
                      )
    return fig

##
txt0 = '<h1>Israel COVID19 data from the Ministry of Health</h1>'+\
    '<h2>Confirmed cases, new severe cases, and mortality by vaccination status</h2>'


txt = txt0+'by <a href="https://twitter.com/yuvharpaz" target="_blank">@yuvharpaz</a><br>'+\
      'Switch to <a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc_abs.html">absolute</a>, '+\
      '<a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc_young.html">younger than 60</a><br>'

fig = make_figs3(dfsNorm[0], measure[0],  age_gr='מעל גיל 60', smoo='sm', nrm=', per 100k ')
txt = txt+fig.to_html()  # +'\n<br>\n'
fig = make_figs3(dfsNorm[1], measure[1], age_gr='מעל גיל 60', smoo='sm', nrm=', per 100k ')
txt = txt+fig.to_html()
fig = make_figs3(dfsNorm[2], measure[2], age_gr='מעל גיל 60', smoo='sm', nrm=', per 100k ')
txt = txt+fig.to_html()
file = open("docs/by_vacc.html", "w")
a = file.write(txt)
file.close()
txt = txt0+'by <a href="https://twitter.com/yuvharpaz" target="_blank">@yuvharpaz</a><br>'+\
      'Switch to <a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc.html">per 100k</a>, '+\
      '<a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc_abs_young.html">younger than 60</a><br>'
fig = make_figs3(dfsAbs[0], measure[0],  age_gr='מעל גיל 60', smoo='sm', nrm=', absolute ')
txt = txt+fig.to_html()  # +'\n<br>\n'
fig = make_figs3(dfsAbs[1], measure[1], age_gr='מעל גיל 60', smoo='sm', nrm=', absolute ')
txt = txt+fig.to_html()
fig = make_figs3(dfsAbs[2], measure[2], age_gr='מעל גיל 60', smoo='sm', nrm=', absolute ')
txt = txt+fig.to_html()
file = open("docs/by_vacc_abs.html", "w")
a = file.write(txt)
file.close()

txt = txt0+'by <a href="https://twitter.com/yuvharpaz" target="_blank">@yuvharpaz</a><br>'+\
      'Switch to <a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc_abs_young.html">absolute</a>, '+ \
      '<a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc.html">older than 60</a><br>'
fig = make_figs3(dfsNorm[0], measure[0],  age_gr='מתחת לגיל 60', smoo='sm', nrm=', per 100k ')
txt = txt+fig.to_html()  # +'\n<br>\n'
fig = make_figs3(dfsNorm[1], measure[1], age_gr='מתחת לגיל 60', smoo='sm', nrm=', per 100k ')
txt = txt+fig.to_html()
fig = make_figs3(dfsNorm[2], measure[2], age_gr='מתחת לגיל 60', smoo='sm', nrm=', per 100k ')
txt = txt+fig.to_html()
file = open("docs/by_vacc_young.html", "w")
a = file.write(txt)
file.close()

txt = txt0+'by <a href="https://twitter.com/yuvharpaz" target="_blank">@yuvharpaz</a><br>'+\
      'Switch to <a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc_young.html">per 100k</a>, '+\
      '<a href="https://yuval-harpaz.github.io/covid-19-israel-matlab/by_vacc_abs.html">older than 60</a><br>'
fig = make_figs3(dfsAbs[0], measure[0],  age_gr='מתחת לגיל 60', smoo='sm', nrm=', absolute ')
txt = txt+fig.to_html()  # +'\n<br>\n'
fig = make_figs3(dfsAbs[1], measure[1], age_gr='מתחת לגיל 60', smoo='sm', nrm=', absolute ')
txt = txt+fig.to_html()
fig = make_figs3(dfsAbs[2], measure[2], age_gr='מתחת לגיל 60', smoo='sm', nrm=', absolute ')
txt = txt+fig.to_html()
file = open("docs/by_vacc_abs_young.html", "w")
a = file.write(txt)
file.close()
