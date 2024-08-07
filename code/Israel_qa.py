import os
import pandas as pd
import numpy as np
import dash
from dash import dcc
from dash import html
import plotly.express as px
import plotly.graph_objects as go
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
import urllib.request
import json


def movmean(vec, win, nanTail=False):
    #  smooth a vector with a moving average. win should be an odd number of samples.
    #  vec is np.ndarray size (N,) or (N,0)
    #  to get smoothing of 3 samples back and 3 samples forward use win=7
    if type(vec) == list:
        vec = np.asarray(vec)
    vec = vec.astype('float')
    smooth = vec.copy()
    if win > 1:
        if nanTail:
            smooth[:] = np.nan
        for ii in range(int(win/2), len(vec)-int(win/2)):
            smooth[ii] = np.nanmean(vec[ii-int(win/2):ii+int(win/2)+1])
    return smooth


JH = pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv')
pop = pd.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/scripts/input/un/population_latest.csv')
JHT = JH.T
# owid = pd.read_csv('https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv?raw=true')
JHisr = JH[JH['Country/Region'] == 'Israel']
date_str = list(JHisr.columns[4:])
date = []
for ii, dd in enumerate(date_str):
    parsed = dd.split('/')
    for dm in [0, 1]:
        if len(parsed[dm]) == 1:
            parsed[dm] = '0'+parsed[dm]
    date.append(np.datetime64('20'+parsed[2]+'-'+parsed[0]+'-'+parsed[1]))
date = np.asarray(date)
WHO = pd.read_csv('https://covid19.who.int/WHO-COVID-19-global-data.csv')
wc = np.unique(np.asarray(WHO['Country']))
WHOisr = WHO[WHO['Country'] == 'Israel']
dateWho = np.asarray(list(WHOisr['Date_reported']))
deathWho = np.asarray(list(WHOisr['New_deaths']))
country = ['Israel', 'Italy', 'United Kingdom']
wountry = ['Israel', 'Italy', 'The United Kingdom']
date_who_list = np.asarray(WHO['Date_reported'])
death_who_list = list(WHO['New_deaths'])
country_who_list = np.asarray(WHO['Country'])
jhn = JHT.to_numpy()
dpm = {'WHO': {}, 'JH': {}}
for cc, ctr in enumerate(country):
    pp = list(pop['population'][pop['entity'] == ctr])
    if len(pp) == 1:
        pp = pp[0]
    else:
        raise Exception('population for '+ctr+' wrong')
    y = []
    for ii, dd in enumerate(date):
        row = np.where((date_who_list == str(dd)) & (country_who_list == wountry[cc]))[0]
        if len(row) == 1:
            y.append(death_who_list[row[0]])
        else:
            y.append(np.nan)
    yy = np.sum(jhn[4:, jhn[1, :] == ctr], axis=1)
    yy[1:] = np.diff(yy)
    dpm['WHO'][ctr] = np.asarray(y)/pp*10**6
    dpm['JH'][ctr] = yy/pp*10**6

# layoutX = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', legend={'traceorder': 'reversed'})
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
src = ['JH', 'WHO']
fig = [0, 0]
for iSource in [0, 1]:
    fig[iSource] = go.Figure(layout=layout)
    for ctr in country:
        fig[iSource].add_trace(go.Scatter(x=date, y=dpm[src[iSource]][ctr], mode='lines', name=ctr))
    fig[iSource].update_layout(title_text=src[iSource], font_size=15)
    fig[iSource].show()



JHisrT = JHisr.T
JHisrT.columns = ['isr']
tmp = np.asarray([0]+list(np.diff(np.asarray(JHisrT['isr'][4:]))))
deaths = {'JH': tmp}




tmp = []
for ii, dt in enumerate(date):
    who_row = np.where(str(dt) == dateWho)[0]
    if len(who_row) == 1:
        tmp.append(deathWho[who_row[0]])
    else:
        tmp.append(np.nan)
if not len(tmp) == len(deaths['JH']):
    raise Exception('wrong number of dates')
deaths['WHO'] = tmp

MOH = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/hospitalizationStatus')
dateMOH = np.asarray(list(MOH['dayDate'].str.slice(0, 10)))
deathMOH = np.asarray(list(MOH['countDeath']))
tmp = []
for ii, dtm in enumerate(date):
    row = np.where(dateMOH == str(dtm))[0]
    if len(row) == 0:
        tmp.append(0)
    else:
        tmp.append(deathMOH[row[0]])

deaths['MOH'] = tmp
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', legend={'traceorder': 'reversed'})
# layout1 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
fig1 = go.Figure(layout=layout)
for source in ['JH', 'WHO', 'MOH']:
    fig1.add_trace(go.Scatter(x=date, y=movmean(deaths[source],7), mode='lines', name=source))
    fig1.add_trace(go.Scatter(x=date, y=deaths[source], mode='lines', name=source))
fig1.show()
# fig1.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
# fig1.update_yaxes(range=(20, int(10000*np.ceil(np.nanmax(yyAge)/10000))))
# fig1.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%b\n%Y")
# fig1.update_layout(title_text="Weekly cases by age", font_size=15, updatemenus=updatemenus)
# api = 'https://datadashboardapi.health.gov.il/api/queries/'
# dfAge = pd.read_csv('https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/cases_by_age.csv')
# dfTS = pd.read_json(api+'hospitalizationStatus')
# cn = list(dfTS.columns)
# cn[0] = 'date'
# dfTS.columns = cn
# # dfTS = dfTS[dfTS.duplicated(['date'], keep=False)]
# dfTS = dfTS.drop_duplicates(subset=['date'], keep='first')
# dfTS.sort_values('date')
# dfTS['date'] = dfTS['date'].str.slice(start=None, stop=10)
# hospitalizationStatus = dfTS.to_csv(index=False)
#
# url = [api+'VerfiiedVaccinationStatusDaily',
#        api+'SeriousVaccinationStatusDaily',
#        api+'deathVaccinationStatusDaily']
# measure = ['Cases', 'New Severe', 'Deaths']
# varsNorm = [['verified_vaccinated_normalized', 'verified_expired_normalized', 'verified_not_vaccinated_normalized'],
#             ['new_serious_vaccinated_normalized', 'new_serious_expired_normalized', 'new_serious_not_vaccinated_normalized'],
#             ['death_vaccinated_normalized', 'death_expired_normalized', 'death_not_vaccinated_normalized']]
# varsAbs = [['verified_amount_vaccinated', 'verified_amount_expired', 'verified_amount_not_vaccinated'],
#            ['new_serious_amount_vaccinated', 'new_serious_amount_expired', 'new_serious_amount_not_vaccinated'],
#            ['death_amount_vaccinated', 'death_amount_expired', 'death_amount_not_vaccinated']]
#
# dfsNorm = [[], [], []]
# dfsAbs = [[], [], []]
# downloads = []
# for ii in [0, 1, 2]:
#     dfs = pd.read_json(url[ii])
#     downloads.append(dfs.copy())
#     downloads[-1]['day_date'] = downloads[-1]['day_date'].str.slice(0, 10)
#     downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('מעל גיל 60', 'over 60')
#     downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('מתחת לגיל 60', 'under 60')
#     downloads[-1]['age_group'] = downloads[-1]['age_group'].str.replace('כלל האוכלוסיה', 'all')
#     dfs['date'] = pd.to_datetime(dfs['day_date'])
#     dfsNorm[ii] = dfs.rename(columns={varsNorm[ii][0]: 'vaccinated', varsNorm[ii][1]: 'expired', varsNorm[ii][2]: 'unvaccinated'})
#     dfsNorm[ii] = dfsNorm[ii][['date', 'day_date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
#     dfsAbs[ii] = dfs.rename(columns={varsAbs[ii][0]: 'vaccinated', varsAbs[ii][1]: 'expired', varsAbs[ii][2]: 'unvaccinated'})
#     dfsAbs[ii] = dfsAbs[ii][['date', 'day_date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
# # writer = pd.ExcelWriter(engine='xlsxwriter')
#
# shifts = [0, 11, 21]
# ages2 = ['מתחת לגיל 60', 'מעל גיל 60']
# yy = np.zeros((3, 2, 2, 2))
# dd = [[], [], []]
# for im in [0, 1, 2]:  # cases, severe, deaths
#     for ia in [0, 1]:  # young, old
#         df_age1 = dfsAbs[im].loc[dfsAbs[im]['age_group'] == ages2[ia]]
#         df_age1.reset_index()
#         for iv, vax in enumerate(['vaccinated','unvaccinated']):
#             meas = np.asarray(df_age1[vax])
#             day_date = np.asarray(df_age1['day_date'])
#             d0 = np.where(day_date == '2021-06-20T00:00:00.000Z')[0][0]
#             d1 = np.where(day_date == '2021-10-21T00:00:00.000Z')[0][0]
#             d2 = np.where(day_date == '2021-12-11T00:00:00.000Z')[0][0]
#             yy[im, ia, 0, iv] = np.sum(meas[d0+shifts[im]:d1+shifts[im]])
#             yy[im, ia, 1, iv] = np.sum(meas[d2+shifts[im]:-shifts[-im-1]-1])
#     dd[im] = [str(day_date[d0+shifts[im]])[:10],
#               str(day_date[d1+shifts[im]])[:10],
#               str(day_date[d2+shifts[im]])[:10],
#               str(day_date[-shifts[-im-1]-1])[:10]]
# print('severe')
# print(dd[1])
# print('deaths')
# print(dd[2])
#
#
# def make_ratios(age=1):
#     dfRat = pd.DataFrame([['Delta', 'vaccinated', yy[2, age, 0, 0]/yy[1, 1, 0, 0]],
#                           ['Omi', 'vaccinated', yy[2, age, 1, 0]/yy[1, 1, 1, 0]],
#                           ['Delta', 'unvaccinated', yy[2, age, 0, 1]/yy[1, 1, 0, 1]],
#                           ['Omi', 'unvaccinated', yy[2, age, 1, 1]/yy[1, 1, 1, 1]]],
#                          columns=['wave', 'vaccination', 'death ratio'])
#     dfSD = pd.DataFrame([['Delta', 'vaccinated', 'deaths', yy[2, age, 0, 0]],
#                          ['Delta', 'vaccinated', 'severe', yy[1, age, 0, 0]],
#                          ['Omi', 'vaccinated', 'deaths', yy[2, age, 1, 0]],
#                          ['Omi', 'vaccinated', 'severe', yy[1, age, 1, 0]],
#                          ['Delta', 'unvaccinated', 'deaths', yy[2, age, 0, 1]],
#                          ['Delta', 'unvaccinated', 'severe', yy[1, age, 0, 1]],
#                          ['Omi', 'unvaccinated', 'deaths', yy[2, age, 1, 1]],
#                          ['Omi', 'unvaccinated', 'severe', yy[1, age, 1, 1], ]],
#                          columns=['wave', 'vaccination', 'measure', 'value'])
#     if age == 1:
#         ag = ' 60+'
#     else:
#         ag = ' <60'
#     figDelta = px.histogram(dfSD[dfSD['wave'] == 'Delta'], x="vaccination", y="value", color='measure', barmode='group')
#     figOmi = px.histogram(dfSD[dfSD['wave'] == 'Omi'], x="vaccination", y="value", color='measure', barmode='group')
#     figR = px.histogram(dfRat, x="vaccination", y="death ratio", color='wave', barmode='group')
#
#     figOmi.layout['yaxis']['title']['text'] = 'patients'+ag
#     figOmi.layout['xaxis']['title']['text'] = ''
#     figOmi['data'][0]['marker']['color'] = 'black'
#     figOmi['layout']['title'] = 'Wave V'
#     figOmi['layout']['title']['x'] = 0.45
#     figOmi['layout']['title']['font_color'] = "purple"
#     figOmi['layout']['title']['xanchor'] = 'center'
#
#     figDelta.layout['yaxis']['title']['text'] = 'patients'+ag
#     figDelta.layout['xaxis']['title']['text'] = ''
#     figDelta['data'][0]['marker']['color'] = 'black'
#     figDelta['layout']['title'] = 'Wave IV'
#     figDelta['layout']['title']['x'] = 0.45
#     figDelta['layout']['title']['font_color'] = "green"
#     figDelta['layout']['title']['xanchor'] = 'center'
#
#     figR.layout['yaxis']['title']['text'] = 'death to severe ratio'
#     figR.layout['xaxis']['title']['text'] = ''
#     figR['data'][0]['marker']['color'] = 'green'
#     figR['data'][1]['marker']['color'] = 'purple'
#     figR['layout']['title'] = 'Death ratio'+ag
#     figR['layout']['title']['x'] = 0.45
#     figR['layout']['title']['font_color'] = "black"
#     figR['layout']['title']['xanchor'] = 'center'
#     return figDelta, figOmi, figR
#
# updatemenus = [
#     dict(
#         type="buttons",
#         direction="down",
#         buttons=list([
#             dict(
#                 args=[{'yaxis.type': 'linear'}],
#                 label="Linear",
#                 method="relayout"
#             ),
#             dict(
#                 args=[{'yaxis.type': 'log'}],
#                 label="Log",
#                 method="relayout"
#             )
#         ])
#     ),
# ]
# x = dfAge['date']
# x = pd.to_datetime(x)
# yyAge = np.asarray(dfAge.iloc[:, 1:11])
# label = ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80-89', '90+']
# color = ['#E617E6', '#6A17E6', '#1741E6', '#17BEE6', '#17E6BE', '#17E641', '#6AE617', '#E6E617', '#E69417', '#E61717']
# layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', legend={'traceorder': 'reversed'})
# layout1 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
# fig1 = go.Figure(layout=layout1)
# for ii, line in enumerate(yyAge.T):
#     fig1.add_trace(go.Scatter(x=x, y=line, mode='lines', line_color=color[ii], name=label[ii]))
#
# fig1.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
# fig1.update_yaxes(range=(20, int(10000*np.ceil(np.nanmax(yyAge)/10000))))
# fig1.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%b\n%Y")
# fig1.update_layout(title_text="Weekly cases by age", font_size=15, updatemenus=updatemenus)
#
#
# def make_figs3(df_in, meas, age_gr='מעל גיל 60', smoo='sm', nrm=', per 100k ', start_date=[], end_date=[], loglin='linear'):
#     df_age = df_in.loc[df_in["age_group"] == age_gr]
#     # date = df_age['date']
#     mx = np.max(df_age.max()[3:6])*1.05
#     if loglin == 'log':
#         mx = np.ceil(np.log(mx)/np.log(10))
#     # xl = [df_age.iloc[0,0], df_age.iloc[-1,0]]
#     xl = [start_date, end_date]
#     if smoo == 'sm':
#         for yts in ['vaccinated', 'expired', 'unvaccinated']:
#             yybef = np.asarray(df_age[yts])
#             yyaft = np.round(movmean(yybef, 7, nanTail=True), 1)
#             yyaft[-4] = np.nan
#             df_age[yts] = yyaft
#         # df_age = df_age.rolling(7, min_periods=7).mean().round(1)
#         # df_age['date'] = date - pd.to_timedelta(df_age.shape[0] * [3], 'd')
#     fig = px.line(df_age, x="date", y=['vaccinated', 'expired', 'unvaccinated'])
#     fig.update_traces(hovertemplate="%{y}")
#     fig['data'][0]['line']['color'] = '#0e7d7d'
#     fig['data'][1]['line']['color'] = '#b9c95b'
#     fig['data'][2]['line']['color'] = '#2fcdfb'
#     fig.layout = layout
#     fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, mx], type=loglin)
#     fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=xl, dtick="M1", tickformat="%d/%m\n%Y")
#     if age_gr == 'מעל גיל 60':
#         txt60 = '(60+)'
#     else:
#         txt60 = '(<60)'
#     fig.update_layout(title_text=meas+' by vaccination status'+nrm+txt60, font_size=15, hovermode="x unified")
#     return fig
#
# ## waning
# url1 = 'https://data.gov.il/api/3/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd&limit=10000'
# with urllib.request.urlopen(url1) as api1:
#     data1 = json.loads(api1.read().decode())
# win = 7
#
#
#
#
# df1 = pd.DataFrame(data1['result']['records'])
# date1 = np.asarray(pd.to_datetime(df1['תאריך']))
# url2 = 'https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily'
# df2 = pd.read_json(url2)
# df2 = df2.loc[df2["age_group"] == 'מעל גיל 60']
# df2 = df2.reset_index()
# date2 = np.asarray(pd.to_datetime(df2['day_date'].str.slice(0,10)))
# date = np.concatenate([date1, date2])
# date = np.unique(date)
# date = np.sort(date)
# url3 = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate'
# df3 = pd.read_json(url3)
# date3 = list(pd.to_datetime(df3['date'].dt.strftime('%Y-%m-%d')))
# casesAll = np.zeros((len(date)))
# casesAll[:] = np.nan
# for ii, _ in enumerate(date3):
#     if date3[ii] in date:
#         casesAll[np.where(date == date3[ii])[0][0]] = df3['amount'][ii]
# cases = np.zeros((len(date)))
# cases[:] = np.nan
# mild = np.zeros((len(date)))
# mild[:] = np.nan
# ve = np.zeros((len(date)))
# ve[:] = np.nan
# for ii, d in enumerate(date1):
#     mild[np.where(date == date1[ii])[0][0]] = df1['אחוז חולים קל לא מחוסנים'][ii]
# for ii, d in enumerate(date2):
#     total = df2['verified_amount_vaccinated'][ii]+df2['verified_amount_expired'][ii]+df2['verified_amount_not_vaccinated'][ii]
#     cases[np.where(date == date2[ii])[0][0]] = np.round(100*df2['verified_amount_not_vaccinated'][ii]/total, 1)
# dfAge = pd.DataFrame(date, columns=['date'])
# dfAge['% unvaccinated of 60+ cases'] = cases
# dfAge['% unvaccinated of mild hospitalizations'] = mild
# dfAge['cases'] = movmean(casesAll, 7, True)
# Nvax = np.asarray(df2['verified_amount_vaccinated']/df2['verified_vaccinated_normalized']*10**5)
# Nexp = np.asarray(df2['verified_amount_expired']/df2['verified_expired_normalized']*10**5)
# sm = Nvax.copy()
# sm[65:160+5] = np.linspace(sm[65], sm[159+5], 95+5)
# sm = movmean(sm, win)
# sm[-3] = sm[-4]
# sm[-2] = sm[-4]
# sm[-1] = sm[-4]
# sm = np.round(sm, 1)
# smExp = Nexp.copy()
# smExp[0:185] = 0
# smExp[300] = smExp[301]
# # smExp = movmean(smExp, win)
# smExp[-3] = smExp[-4]
# smExp[-2] = smExp[-4]
# smExp[-1] = smExp[-4]
# unvax = np.asarray(df2['verified_not_vaccinated_normalized'])
# ## VE TIMNA
# urlVE = 'https://data.gov.il/api/3/action/datastore_search?resource_id=9b623a64-f7df-4d0c-9f57-09bd99a88880&limit=50000'
# with urllib.request.urlopen(urlVE) as api1:
#     dataCases = json.loads(api1.read().decode())
#
# for week in dataCases['result']['records']:
#     keys = list(week.keys())
#     for field in keys:
#         if week[field] == '<5':
#             week[field] = '2.5'
#         if week[field] == '<15':
#             week[field] = '7'
# cases = pd.DataFrame(dataCases['result']['records'])
# # dateVE = np.asarray(pd.to_datetime(cases['Week'].str.slice(12, 23)))
# urlVacc = 'https://data.gov.il/api/3/action/datastore_search?resource_id=57410611-936c-49a6-ac3c-838171055b1f&limit=5000'
# with urllib.request.urlopen(urlVacc) as api1:
#     dataVacc = json.loads(api1.read().decode())
# for day in dataVacc['result']['records']:
#     keys = list(day.keys())
#     for field in keys:
#         if day[field] == '<15':
#             day[field] = '7'
#         if day[field] == '<5':
#             day[field] = '2'
# vaccA = pd.DataFrame(dataVacc['result']['records'])
# # dateVacc = pd.to_datetime(vaccA['VaccinationDate'])
# vaccA['first_dose'] = vaccA['first_dose'].astype(int)
# vaccA['second_dose'] = vaccA['second_dose'].astype(int)
# vaccA['third_dose'] = vaccA['third_dose'].astype(int)
# # dd = dateVacc.sort_values()  # maybe no need to sort
#
# # keep 60+ only
# ages = cases['Age_group'].unique()
# iAge = [5, 6, 7, 8]
# mask = cases['Age_group'].isin(ages[iAge])
# cases = cases[mask]
# dateVE = np.asarray(pd.to_datetime(cases['Week'].str.slice(12, 23)))
# weekEnd = np.unique(dateVE)
# weekEnd.sort()
# mask = vaccA['age_group'].isin(ages[iAge])
# vaccX = vaccA[mask]
# dateVacc = np.asarray(pd.to_datetime(vaccX['VaccinationDate']))
#
# pop = 1587000
#
# dose2 = np.ndarray((len(cases), 3))
# dose3 = np.ndarray((len(cases), 3))
# dose2[:, 0] = np.asarray(cases['positive_14_30_days_after_2nd_dose'].astype(float))
# dose2[:, 1] = cases['positive_14_30_days_after_3rd_dose'].astype(float)
# dose2[:, 2] = cases['positive_above_3_month_after_2nd_before_3rd_dose'].astype(float)
# dose2 = np.nansum(dose2, axis=1)
# dose3[:, 0] = np.asarray(cases['positive_14_30_days_after_3rd_dose'].astype(float))
# dose3[:, 1] = np.asarray(cases['positive_31_90_days_after_3rd_dose'].astype(float))
# dose3[:, 2] = np.asarray(cases['positive_above_90_days_after_3rd_dose'].astype(float))
# dose3 = np.nansum(dose3, axis=1)
# unvacc = np.asarray(cases['Sum_positive_without_vaccination'].astype(float))
# ve2 = np.ndarray(len(weekEnd))
# ve3 = np.ndarray(len(weekEnd))
# for ii in range(len(weekEnd)):
#     date1 = weekEnd[ii]
#     caseRow = dateVE == weekEnd[ii]
#     # first dose a week before, used to evaluate unvaccinated
#     idx = dateVacc < (date1-7+3)
#     if np.sum(idx) == 0:
#         vacc1 = 0
#     else:
#         vacc1 = np.sum(vaccX['first_dose'][idx])
#     # third dose 20 days before
#     idx = dateVacc < (date1-20+3)
#     if np.sum(idx) == 0:
#         vacc3 = 0
#     else:
#         vacc3 = np.sum(vaccX['third_dose'][idx])
#     # 2nd dose two weeks before (but with no 3rd dose)
#     idx = dateVacc < (date1-14+3)
#     if np.sum(idx) == 0:
#         vacc2 = 0
#     else:
#         vc3 = np.sum(vaccX['third_dose'][idx])
#         vacc2 = np.sum(vaccX['second_dose'][idx]) - vc3
#     ve2[ii] = 100*(1-(np.nansum(dose2[caseRow])/vacc2)/(np.nansum(unvacc[caseRow])/(pop-vacc1)))
#     ve3[ii] = 100 * (1 - (np.nansum(dose3[caseRow]) / vacc3) / (np.nansum(unvacc[caseRow]) / (pop - vacc1)))
#
# ve3[[31, 32, 33]] = np.nan  # 100% VE, too few vaccinated
# ve3 = np.round(ve3, 1)
# ve2 = np.round(ve2, 1)
#
#
# def make_wane(dfW, win=7):
#     win = int(np.floor((int(win)-1)/2)*2+1)
#
#     # smExp = np.round(smExp, 1)
#     ratioVax =  ((np.asarray(df2['verified_amount_vaccinated']) + \
#                 np.asarray(df2['verified_amount_expired'])) / \
#                 (sm + smExp))
#     VE = 100*(1-ratioVax/(movmean(unvax, win, nanTail=False)/10**5))
#     idx = [np.where(date == date2[0])[0][0], np.where(date == date2[-1])[0][0]+1]
#     VE = np.round(movmean(VE, win, nanTail=False), 1)
#     if win > 1:
#         VE[-int(win / 2):] = np.nan
#     ve[idx[0]:idx[1]] = VE
#     # df7 = dfAge.rolling(win, min_periods=3).mean().round(1)
#
#     dfW['VE for 60+ cases (2 doses or more)'] = ve
#     # df7['cases (normalized)'] = np.round(100*df7['cases (normalized)']/np.max(df7['cases (normalized)']))
#     dfW['% unvaccinated of mild hospitalizations'] = np.round(
#         movmean(np.asarray(dfW['% unvaccinated of mild hospitalizations']), win, True),1)
#     dfW['% unvaccinated of 60+ cases'] = np.round(
#         movmean(np.asarray(dfW['% unvaccinated of 60+ cases']), win, True), 1)
#
#     xl = [str(np.datetime_as_string(date[288]))[0:10], str(np.datetime_as_string(date[-1]))[0:10]]
#     dfW['date'] = date
#     layoutW = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', xaxis_range=xl)
#     fig_wane = go.Figure(layout=layoutW)
#     fig_wane.add_trace(go.Scatter(x=weekEnd - 3, y=ve2, name='VE dose 2, Data.Gov', line_color='#66ff66'))
#     fig_wane.add_trace(go.Scatter(x=weekEnd - 3, y=ve3, name='VE dose 3, Data.Gov', line_color='#227722'))
#     # name = 'VE for 60+ cases (2 doses or more)'
#     # fig_wane.add_trace(go.Scatter(x=dfW['date'], y=dfW[name], line_color='red', name='VE dose 2+3, dashboard'))
#     # name = '% unvaccinated of mild hospitalizations'
#     # fig_wane.add_trace(go.Scatter(x=dfW['date'], y=dfW[name], line_color='red', name='% unvax of mild hospitalizations'))
#     # name = '% unvaccinated of 60+ cases'
#     # fig_wane.add_trace(go.Scatter(x=dfW['date'], y=dfW[name], line_color='red', name='% unvax of 60+ cases'))
#
#     fig_wane.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray',
#                           # tickfont=dict(color="#cc3333"), titlefont=dict(color="#cc3333"), title='VE',
#                           range=[-50, 100], title='VE', hoverformat=None)
#     fig_wane.add_trace(go.Scatter(x=dfW['date'], y=np.round(dfW['cases']), yaxis='y2', name='Cases', line_color='#bbbbbb'))
#     fig_wane.update_layout(
#         legend=dict(
#                         yanchor="top",
#                         y=1.1,
#                         xanchor="left",
#                         x=1.05
#                     ),
#         title_text="Crude VE (60+) for dose II and dose III.", font_size=15, hovermode="x unified",
#         yaxis=dict(
#             side="right",
#             gridcolor='lightgray',
#             zerolinecolor='lightgray'
#         ),
#         yaxis2=dict(
#         #     title="Cases",
#         #     anchor="free",
#         #     overlaying="y",
#         #     side="right",
#         #     position=1,
#             showgrid=False,
#             zerolinecolor='lightgray',
#             gridcolor='lightgray',
#         #     range=[0, 50000])
#         ))
#     # fig_wane.layout['yaxis']['titlefont']['color'] = "#cc3333"
#     fig_wane.layout['yaxis2']['title'] = 'Cases'
#     fig_wane.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray',
#                           dtick="M1", tickformat="%d/%m\n%Y", range=xl)
#     fig_wane.layout['xaxis']['title'] = 'Month'
#     fig_wane.layout['yaxis']['dtick'] = 10
#     # fig_wane.show()
#     return fig_wane
#
#
# def makeVE(dfW60, age_gr):
#     if age_gr == 'מעל גיל 60':
#         tit = "Crude VE (60+) vs cases per 100k, for recently vaccinated (<6m) and unvaccinated"
#     else:
#         tit = "Crude VE (<60) vs cases per 100k, for recently vaccinated (<6m) and unvaccinated"
#     df_age = dfW60.loc[dfW60["age_group"] == age_gr]
#     df_age = df_age.reset_index()
#     tm = df_age['date'].to_numpy()
#     date2ve = []
#     for t in tm:
#         date2ve.append(pd.Timestamp.to_datetime64(t))
#     date2ve = np.asarray(date2ve)
#     # date2ve = np.datetime64(df_age['date'].to_string.str.slice(0,10))
#     # date2ve = np.asarray(pd.to_datetime(df2['day_date'].str.slice(0, 10)))
#     vaccW60 = np.round(movmean(np.asarray(df_age['vaccinated']), 7, nanTail=False), 2)
#     unvaccW60 = np.round(movmean(np.asarray(df_age['unvaccinated']), 7, nanTail=False), 2)
#     veW60 = np.round(100 * (1 - vaccW60 / unvaccW60))
#     xlW60 = [str(np.datetime_as_string(date2ve[4]))[0:10],
#              str(np.datetime_as_string(date2ve[-1] + np.timedelta64(1, 'D')))[0:10]]
#     layoutW60 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)',
#                           xaxis_range=xlW60)  # , xaxis_range=xl)
#     figW60 = go.Figure(layout=layoutW60)
#     figW60.add_trace(go.Scatter(x=date2ve, y=veW60, name='VE                                      ', line_color='#222277'))
#     figW60.add_trace(go.Scatter(x=date2ve[-4:], y=veW60[-4:], name='not final', line_color='#aaaaaa'))
#     figW60.update_yaxes(range=[-50, 100], dtick=10, zeroline=True, zerolinecolor='#aaaaaa', gridcolor='#bdbdbd')
#     figW60.add_trace(go.Scatter(x=date2ve, y=vaccW60, yaxis='y2', name='vaccinated   ', line_color='#99ff99'))
#     figW60.update_xaxes(dtick="M1", tickformat="%d-%b \n%Y", gridcolor='#bdbdbd')
#     figW60.update_layout(
#         yaxis_title="crude VE (%)",
#         yaxis=dict(
#             tickmode='linear',
#             zeroline=True,
#         ),
#         legend=dict(
#             yanchor="top",
#             y=1.1,
#             xanchor="left",
#             x=1.05
#         ),
#         title_text=tit, font_size=15, hovermode="x unified",
#         yaxis2=dict(
#             title="Cases per 100k",
#             color='#ff9999',
#             anchor="free",
#             overlaying="y",
#             side="right",
#             position=1,
#             zerolinecolor='lightgray',
#             gridcolor='lightgray',
#             zeroline=True,
#             range=[0, 150]
#         ))
#     figW60.add_trace(go.Scatter(x=date2ve, y=unvaccW60, yaxis='y2', name='unvaccinated', line_color='#ff9999'))
#     return figW60
# app = dash.Dash(
#     __name__,
#     external_stylesheets=[dbc.themes.BOOTSTRAP],
#     # external_stylesheets=['https://codepen.io/chriddyp/pen/bWLwgP.css'],
#     meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
# )
# server = app.server
# app.layout = html.Div([
#     html.Div([
#         html.Div([
#             html.H3('Israel COVID19 data'),
#             html.A('zoom in (click and drag) and out (double click), adapted from the MOH '),
#             html.A('dashboard', href="https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral", target='_blank'),
#             html.A(' by '), html.A('@yuvharpaz.', href="https://twitter.com/yuvharpaz", target='_blank'),html.A(' '),
#             html.A(' code ', href="https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/covid_dash1.py", target='_blank'),
#             html.Div([
#                 html.A('To get hospitalizations data click  '),
#                 html.Button("Download", id="btn-download-txt"),
#                 dcc.Download(id="download-text"),
#                 html.A(' '),
#                 html.A('<json>', href='https://datadashboardapi.health.gov.il/api/queries/hospitalizationStatus', target='_blank'),
#                 html.A('. Vacination status for  '),
#                 html.Button("Cases", id="btn-inf"),
#                 dcc.Download(id="download-inf"),
#                 html.A(' '),
#                 html.Button("Severe", id="btn-sev"),
#                 dcc.Download(id="download-sev"),
#                 html.A('  '),
#                 html.Button("Deaths", id="btn-dea"),
#                 dcc.Download(id="download-dea")]
#             ),
#             html.Br(), html.A('other dashboards: '),
#             html.A('South Africa',
#                    href="https://sa-covid.herokuapp.com/",
#                    target='_blank'),
#             html.A(' , '),
#             html.A('England',
#                    href="https://uk-covid.herokuapp.com/",
#                    target='_blank'),
#             html.Br(), html.Br()
#         ]),
#         dbc.Row([
#             html.Div([
#                 dcc.RadioItems(id='doNorm',
#                     options=[
#                         {'label': 'absolute', 'value': 'absolute'},
#                         {'label': 'per 100k', 'value': 'normalized'}
#                     ],
#                     value='normalized',
#                     labelStyle={'display': 'inline-block'}
#                 ),
#             ]),
#             html.Div([
#                 dcc.RadioItems(id='age',
#                     options=[
#                         {'label': '60+', 'value': 'מעל גיל 60'},
#                         {'label': '<60', 'value': 'מתחת לגיל 60'}
#                     ],
#                     value='מעל גיל 60',
#                     labelStyle={'display': 'inline-block'}
#                 )
#             ]),
#
#             html.Div([
#                 dcc.RadioItems(id='smoo',
#                     options=[
#                         {'label': 'smooth ', 'value': 'sm'},
#                         {'label': 'raw ', 'value': 'rw'}
#                     ],
#                     value='sm',
#                     labelStyle={'display': 'inline-block'}
#                 )
#             ]),
#             html.Div([
#                 dcc.RadioItems(id='loglin',
#                     options=[
#                         {'label': 'lin', 'value': 'linear'},
#                         {'label': 'log', 'value': 'log'}
#                     ],
#                     value='linear',
#                     labelStyle={'display': 'inline-block'}
#                 )
#             ])
#         ]),
#         dbc.Row([
#             dbc.Col(dcc.Graph(id='infected'), lg=4),
#             dbc.Col(dcc.Graph(id='severe'), lg=4),
#             dbc.Col(dcc.Graph(id='death'), lg=4)
#         ]),
#         dcc.DatePickerRange(
#             id='date-picker',
#             display_format='DD/MM/Y',
#             min_date_allowed=dfsNorm[0]['date'][0].date(),
#             max_date_allowed=dfsNorm[0]['date'][len(dfsNorm[0])-1].date(),
#             initial_visible_month=dfsNorm[0]['date'][0].date(),
#             start_date=dfsNorm[0]['date'][0].date(),
#             end_date=dfsNorm[0]['date'][len(dfsNorm[0])-1].date()
#         ),
#         html.Br(),html.Br(),html.Br(),
#         html.A('Deaths for wave IV (11-Jul-2021 to 11-Nov-2021) and V (1-Jan-22 to present) vs new severe cases, 10 days earlier.'),
#         html.Br(),
#         html.A('Ratio plot is black/red for Delta wave IV and (mainly) Omicron wave V.'),
#         dbc.Row([
#             dbc.Col(dcc.Graph(id='frat1'), lg=2),
#             dbc.Col(dcc.Graph(id='frat2'), lg=2),
#             dbc.Col(dcc.Graph(id='frat3'), lg=2),
#             dbc.Col(dcc.Graph(id='g2', figure=fig1), lg=6, md=12)
#         ]),
#         dbc.Row([
#             dbc.Col(dcc.Graph(id='gw'), lg=8, md=12),
#             # dbc.Col(dcc.Graph(id='g2', figure=fig1), lg=4, md=12)
#         ]),
#         dbc.Row([
#             html.Div([
#                 dcc.RadioItems(id='age60w',
#                     options=[
#                         {'label': '60+', 'value': 'מעל גיל 60'},
#                         {'label': '<60', 'value': 'מתחת לגיל 60'}
#                     ],
#                     value='מעל גיל 60',
#                     labelStyle={'display': 'inline-block'}
#                 )
#             ]),
#             dbc.Col(dcc.Graph(id='gw60'), lg=8, md=12)
#         ])
#     ])
# ])
# @app.callback(
#     Output('infected', 'figure'),
#     Output('severe', 'figure'),
#     Output('death', 'figure'),
#     Output('gw', 'figure'),
#     Output('gw60', 'figure'),
#     Output('frat1', 'figure'),
#     Output('frat2', 'figure'),
#     Output('frat3', 'figure'),
#     Input('age', 'value'),
#     Input('doNorm', 'value'),
#     Input('smoo', 'value'),
#     Input('loglin', 'value'),
#     Input('age60w', 'value'),
#     Input('date-picker', 'start_date'),
#     Input('date-picker', 'end_date'),
#     )
#
# def update_graph(age_group, norm_abs, smoo, loglin, age60w, start_date, end_date):
#     if norm_abs == 'normalized':
#         figb = make_figs3(dfsNorm[0], measure[0], age_group, smoo, ', per 100k ', start_date, end_date, loglin)
#         figc = make_figs3(dfsNorm[1], measure[1], age_group, smoo, ', per 100k ', start_date, end_date, loglin)
#         figd = make_figs3(dfsNorm[2], measure[2], age_group, smoo, ', per 100k ', start_date, end_date, loglin)
#     else:
#         figb = make_figs3(dfsAbs[0], measure[0], age_group, smoo,  ' ', start_date, end_date, loglin)
#         figc = make_figs3(dfsAbs[1], measure[1], age_group, smoo,  ' ', start_date, end_date, loglin)
#         figd = make_figs3(dfsAbs[2], measure[2], age_group, smoo, ' ', start_date, end_date, loglin)
#     fige = make_wane(dfAge.copy())
#     figf = makeVE(dfsNorm[0].copy(), age60w)
#     if age_group == 'מעל גיל 60':
#         age = 1
#     else:
#         age = 0
#     figG, figH, figI = make_ratios(age=age)
#     return figb, figc, figd, fige, figf, figG, figH, figI
#
# @app.callback(
#     Output("download-text", "data"),
#     Input("btn-download-txt", "n_clicks"),
#     prevent_initial_call=True
# )
# def func(n_clicks):
#     return dict(content=hospitalizationStatus, filename="hospitalizationStatus.csv")
# @app.callback(
#     Output("download-inf", "data"),
#     Input("btn-inf", "n_clicks"),
#     prevent_initial_call=True
# )
# def func(n_clicks):
#     return dict(content=downloads[0].to_csv(), filename="VerifiedStatusDaily.csv")
# @app.callback(
#     Output("download-sev", "data"),
#     Input("btn-sev", "n_clicks"),
#     prevent_initial_call=True
# )
# def func(n_clicks):
#     return dict(content=downloads[1].to_csv(), filename="SeriousVaccinationStatusDaily.csv")
# @app.callback(
#     Output("download-dea", "data"),
#     Input("btn-dea", "n_clicks"),
#     prevent_initial_call=True
# )
# def func(n_clicks):
#     return dict(content=downloads[2].to_csv(), filename="DeathVaccinationStatusDaily.csv")
# # @app.callback(
# #     Output("download-text", "data"),
# #     Input("btn-download-txt", "n_clicks"),
# #     prevent_initial_call=True
# # )
# # def func(n_clicks):
# #     return dict(content=hospitalizationStatus, filename="VerfiiedVaccinationStatusDaily.csv")
#
# if __name__ == '__main__':
#     app.run_server(debug=True)
#
#
#
#
#
