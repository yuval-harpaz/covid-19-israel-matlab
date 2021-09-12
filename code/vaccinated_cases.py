import pandas as pd
import os
DIR = "/home/innereye/covid-19-israel-matlab/data/Israel"
if os.path.isdir(r'C:\Users\User\Documents\Corona'):
    DIR = r'C:\Users\User\Documents\Corona'
os.chdir(DIR)
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily")
vacc.to_csv("deathVaccinationStatusDaily.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily")
vacc.to_csv("SeriousVaccinationStatusDaily.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily")
vacc.to_csv("VerfiedVaccinationStatusDaily.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/VaccinationStatusAgg")
vacc.to_csv("VaccinationStatusAgg.csv")

