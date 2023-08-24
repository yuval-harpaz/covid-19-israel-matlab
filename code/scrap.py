import os
import pandas as pd
import numpy as np
# import numpy as np
# import dash
# from dash import dcc
# from dash import html
# import plotly.express as px
# import plotly.graph_objects as go
# from dash.dependencies import Input, Output
# import dash_bootstrap_components as dbc
# import urllib.request
# import json



api = 'https://datadashboard.health.gov.il/api'
sheets = ['/corona/chul/arrivingAboardCountry',
       '/corona/chul/arrivingAboardDaily',
       '/corona/chul/positiveArrivingAboardDaily',
       '/corona/general/activeKidsSickCityPublic',
       '/corona/general/averageInfectedPerWeek',
       '/corona/general/dailyReturnSick',
       '/corona/general/infectedPerDate',
       '/corona/general/infectionFactor',
       '/corona/general/ocuppancies',
       '/corona/general/ocuppanciesDaily',
       '/corona/general/researchGraph',
       '/corona/general/summaryLast7Days',
       '/corona/general/testResultsPerDate',
       '/corona/general/testedByAge', '/corona/general/testsPerDate',
       '/corona/general/verifiedKidsAgeDaily',
       '/corona/general/verifiedKpi',
       '/corona/hospitalization/deadPatientsPerDate',
       '/corona/hospitalization/hardPatient',
       '/corona/hospitalization/hospitalizationStatusDaily',
       '/corona/hospitalization/hospitalizedKidsAgeDaily',
       '/corona/spotlight/spotlightAggregatedPublic',
       '/corona/vaccinations/SeriousVaccinationStatusDaily',
       '/corona/vaccinations/VaccinationStatusAgg',
       '/corona/vaccinations/VerfiiedVaccinationStatusDaily',
       '/corona/vaccinations/deathVaccinationStatusDaily',
       '/corona/vaccinations/sickReturnsAgeVaccination',
       '/corona/vaccinations/vaccinated',
       '/corona/vaccinations/vaccinationsPerAge']

for sheet in sheets:
    # sheet = 'hospitalizationStatusDaily'
    os.system(f'wget --no-check-certificate -O {sheet.replace("/", "_")}.json {api}'+sheet)
    df = pd.read_json(f'{sheet.replace("/", "_")}.json')
    df.to_csv(f'{sheet.replace("/", "_")}.csv')

sheet = '/corona/hospitalization/deadPatientsPerDate'
df = pd.read_json(f'{sheet.replace("/", "_")}.json')

year = pd.DatetimeIndex(df['date']).year
month = pd.DatetimeIndex(df['date']).month
death = []
for ii in range(1,13):
    death.append(np.sum(df['amount'][(month == ii) & (year == 2023)]))

death_month = pd.DataFrame(death, columns = ['2023'])
#
# sheet = 'deadPatientsPerDate'
# os.system(f'wget --no-check-certificate -O {sheet}.json {api}corona/hospitalization/'+sheet)
# df = pd.read_json(f'{sheet}.json')

    #'https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/cases_by_age.csv')

# https://datadashboard.health.gov.il/api/corona/hospitalization/hospitalizationStatusDaily
