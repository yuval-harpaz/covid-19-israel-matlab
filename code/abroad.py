import pandas as pd
import os
DIR = "/home/innereye/covid-19-israel-matlab/data/Israel"
if os.path.isdir(r'C:\Users\User\Documents\Corona'):
    DIR = r'C:\Users\User\Documents\Corona'
os.chdir(DIR)

vacc = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/arrivingAboardCountry')
vacc.to_csv("arrivingAbroadCountry.csv")
vacc = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/arrivingAboardDaily')
vacc.to_csv("arrivingAbroadDaily.csv")
vacc = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/positiveArrivingAboardDaily')
vacc.to_csv("positiveArrivingAbroadDaily.csv")

