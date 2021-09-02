import pandas as pd
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedByAge")
vacc.to_csv("vaccinatedVerifiedByAge.csv")
vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedDaily")
vacc.to_csv("vaccinatedVerifiedDaily.csv")