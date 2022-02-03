import pandas as pd
import json
import urllib.request
import plotly.express as px
# import plotly.graph_objects as go
import numpy as np

urlVE = 'https://data.gov.il/api/3/action/datastore_search?resource_id=9b623a64-f7df-4d0c-9f57-09bd99a88880&limit=50000'
with urllib.request.urlopen(urlVE) as api1:
    dataCases = json.loads(api1.read().decode())

for week in dataCases['result']['records']:
    keys = list(week.keys())
    for field in keys:
        if week[field] == '<5':
            week[field] = '2.5'
cases = pd.DataFrame(dataCases['result']['records'])
# dateVE = np.asarray(pd.to_datetime(cases['Week'].str.slice(12, 23)))
urlVacc = 'https://data.gov.il/api/3/action/datastore_search?resource_id=57410611-936c-49a6-ac3c-838171055b1f&limit=5000'
with urllib.request.urlopen(urlVacc) as api1:
    dataVacc = json.loads(api1.read().decode())
for day in dataVacc['result']['records']:
    keys = list(day.keys())
    for field in keys:
        if day[field] == '<15':
            day[field] = '7'
vaccA = pd.DataFrame(dataVacc['result']['records'])
# dateVacc = pd.to_datetime(vaccA['VaccinationDate'])
vaccA['first_dose'] = vaccA['first_dose'].astype(int)
vaccA['second_dose'] = vaccA['second_dose'].astype(int)
vaccA['third_dose'] = vaccA['third_dose'].astype(int)
# dd = dateVacc.sort_values()  # maybe no need to sort

# keep 60+ only
ages = cases['Age_group'].unique()
iAge = [5, 6, 7, 8]
mask = cases['Age_group'].isin(ages[iAge])
cases = cases[mask]
dateVE = np.asarray(pd.to_datetime(cases['Week'].str.slice(12, 23)))
weekEnd = np.unique(dateVE)
weekEnd.sort()
mask = vaccA['age_group'].isin(ages[iAge])
vaccX = vaccA[mask]
dateVacc = np.asarray(pd.to_datetime(vaccX['VaccinationDate']))

pop = 1587000

dose2 = np.ndarray((len(cases), 3))
dose2[:, 0] = np.asarray(cases['positive_14_30_days_after_2nd_dose'].astype(float))
dose2[:, 1] = cases['positive_31_90_days_after_2nd_dose'].astype(float)
dose2[:, 2] = cases['positive_above_90_days_after_2nd_dose'].astype(float)
dose2 = np.nansum(dose2, axis=1)
dose3 = np.asarray(cases['positive_above_20_days_after_3rd_dose'].astype(float))
unvacc = np.asarray(cases['Sum_positive_without_vaccination'].astype(float))

ve2 = np.ndarray(len(weekEnd))
ve3 = np.ndarray(len(weekEnd))
for ii in range(len(weekEnd)):
    date1 = weekEnd[ii]
    caseRow = dateVE == weekEnd[ii]
    # first dose a week before, used to evaluate unvaccinated
    idx = dateVacc < (date1-7+3)
    if np.sum(idx) == 0:
        vacc1 = 0
    else:
        vacc1 = np.sum(vaccX['first_dose'][idx])
    # third dose 20 days before
    idx = dateVacc < (date1-20+3)
    if np.sum(idx) == 0:
        vacc3 = 0
    else:
        vacc3 = np.sum(vaccX['third_dose'][idx])
    # 2nd dose two weeks before (but with no 3rd dose)
    idx = dateVacc < (date1-14+3)
    if np.sum(idx) == 0:
        vacc2 = 0
    else:
        vc3 = np.sum(vaccX['third_dose'][idx])
        vacc2 = np.sum(vaccX['second_dose'][idx]) - vc3
    ve2[ii] = 100*(1-(np.nansum(dose2[caseRow])/vacc2)/(np.nansum(unvacc[caseRow])/(pop-vacc1)))
    ve3[ii] = 100 * (1 - (np.nansum(dose3[caseRow]) / vacc3) / (np.nansum(unvacc[caseRow]) / (pop - vacc1)))

fig = px.line(x=weekEnd, y=[ve2, ve3])
fig.show()


# date2 = pd.to_datetime(df2['day_date'].str.slice(0,10))
# date = pd.concat([date1, date2])
# date = np.unique(date)
# date = np.sort(date)

# url3 = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate'
# df3 = pd.read_json(url3)
# # df3['date'] = pd.to_datetime(df3['date'].dt.strftime('%Y-%m-%d'))
# date3 = list(pd.to_datetime(df3['date'].dt.strftime('%Y-%m-%d')))
# # date3 = list(date3.dt.strftime('%Y-%m-%d'))
# # datee3 = np.datetime64(date3)
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
# dfAge = pd.DataFrame(date,columns=['date'])
# dfAge['% unvaccinated of 60+ cases'] = cases
# dfAge['% unvaccinated of mild hospitalizations'] = mild
# dfAge['cases'] = casesAll
#
# ##
# # dfVax = df2[['verified_amount_vaccinated','verified_amount_expired','verified_not_vaccinated_normalized']]
# # dfVax['NvaxCases'] = dfVax['verified_amount_vaccinated']+dfVax['verified_amount_expired']
# Nvax = np.asarray(df2['verified_amount_vaccinated']/df2['verified_vaccinated_normalized']*10**5)
# Nexp = np.asarray(df2['verified_amount_expired']/df2['verified_expired_normalized']*10**5)
# # dfVax['date'] = date2
# sm = Nvax.copy()
# sm[65:160+5] = np.linspace(sm[65],sm[159+5],95+5)
# sm = movmean(sm, win, False)
# sm[-3] = sm[-4]
# sm[-2] = sm[-4]
# sm[-1] = sm[-4]
#
# smExp = Nexp.copy()
# smExp[0:185] = 0
# smExp[300] = smExp[301]
# smExp = movmean(smExp, win, False)
# smExp[-3] = smExp[-4]
# smExp[-2] = smExp[-4]
# smExp[-1] = smExp[-4]
# ratioVax =  ((np.asarray(df2['verified_amount_vaccinated']) + \
#             np.asarray(df2['verified_amount_expired'])) / \
#             (sm + smExp))
# # ratioVax = movmean(ratioVax, 7)
# # dfVax = dfVax.rolling(7, min_periods=7).mean()
# unvax = np.asarray(df2['verified_not_vaccinated_normalized'])
# VE = 100*(1-ratioVax/(movmean(unvax, win, nanTail=False)/10**5))
#
# idx = [np.where(date == date2[0])[0][0], np.where(date == date2.loc[len(date2)-1])[0][0]+1]
# ve[idx[0]:idx[1]] = movmean(VE, win, nanTail=False)
#
#
# # dfAge['VE'] = ve
# ##
# df7 = dfAge.rolling(win, min_periods=3).mean().round(1)
# df7['VE for 60+ cases (2 doses or more)'] = ve
# # df7['cases (normalized)'] = np.round(100*df7['cases (normalized)']/np.max(df7['cases (normalized)']))
# xl = [str(np.datetime_as_string(date[288]))[0:10], str(np.datetime_as_string(date[-1]))[0:10]]
# df7['date'] = date
# layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', xaxis_range=xl)
# ##
# fig = px.line(df7, x='date', y=['VE for 60+ cases (2 doses or more)',  '% unvaccinated of mild hospitalizations', '% unvaccinated of 60+ cases'])
# fig.layout = layout
# fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray', range=[0, 100],
#                  tickfont=dict(color="#cc3333"), titlefont=dict(color="#cc3333"), title='% unvaccinated')
# fig.add_trace(go.Scatter(x=df7['date'], y=df7['cases'], yaxis='y2', name='Cases', line_color='black'))
# fig.update_layout(
#     title_text="Looking for signs of waning immunity, Israel", font_size=15,
#     yaxis2=dict(
#         title="Cases",
#         anchor="free",
#         overlaying="y",
#         side="right",
#         position=1,
#         zerolinecolor='lightgray',
#         gridcolor='lightgray',
#         range=[0, 10000]
#     ),)
# fig['data'][0]['line']['color'] = '#cc3333'
# fig['data'][1]['line']['color'] = '#cc3333'
# fig['data'][1]['line']['dash'] = 'dashdot'
# fig['data'][2]['line']['color'] = '#cc3333'
# fig['data'][2]['line']['dash'] = 'dot'
# fig.layout['yaxis']['titlefont']['color'] = "#cc3333"
# # fig.layout['xaxis']['range'] = xl
# # fig.update_layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
# fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', dtick="M1", tickformat="%m\n%Y", range=xl)
# fig.layout['xaxis']['title'] = 'Month'
# fig.layout['yaxis']['dtick'] = 10
# fig.show()
#
#
