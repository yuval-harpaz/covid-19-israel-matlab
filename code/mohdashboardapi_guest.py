import os
import sys
import pandas as pd

GIT_DIR = "/home/innereye/Repos/israel_moh_covid_dashboard_data"
if os.path.isdir(r'C:\Users\User\Documents\Corona'):
    GIT_DIR = r'C:\Users\User\Documents\Corona'
os.chdir(GIT_DIR)
sys.path += GIT_DIR
from mohdashboardapi import get_api_data, create_patients_csv, create_vaccinated_csv, update_age_vaccinations_csv,\
    create_cases_by_vaccinations_normalized, create_cases_by_vaccinations_absolute, create_kids_ages_daily

data = get_api_data()
create_patients_csv(data)
create_vaccinated_csv(data)
update_age_vaccinations_csv(data)
research = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/researchGraph")
research.to_csv("researchGraph.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/vaccinationsPerAge")
vacc.to_csv("vaccinationsPerAge.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily")
vacc.to_csv("deathVaccinationStatusDaily.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily")
vacc.to_csv("SeriousVaccinationStatusDaily.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily")
vacc.to_csv("VerfiiedVaccinationStatusDaily.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/VaccinationStatusAgg")
vacc.to_csv("VaccinationStatusAgg.csv")
create_cases_by_vaccinations_normalized(data)
create_cases_by_vaccinations_absolute(data)
create_kids_ages_daily(data)
tmp = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/testedByAge")
tmp.to_csv("testedByAge.csv")
