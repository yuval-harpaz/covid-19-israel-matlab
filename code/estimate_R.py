'''
Estimate R from dashboard data
in the resulting data frame, R_dashboard is the published R while R_estimate is 
computed from positive tests.
'''
import numpy as np
import pandas as pd
positive = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/infectedPerDate')
factor = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/infectionFactor')
R = []
for ii in range(len(positive)-13):
    R.append((np.sum(positive['amount'][ii+7:ii+14])/np.sum(positive['amount'][ii:ii+7]))**0.685)

positive['R_estimate'] = factor.loc[len(factor)-1][1]
for jj in range(len(positive)-13):
    positive.at[jj+7-4,'R_estimate'] = R[jj]

positive['R_dashboard'] = factor.loc[len(factor)-1][1]
for kk in range(len(factor)):
    positive.loc[kk+140,'R_dashboard'] = factor.loc[kk][1]
    
positive.plot('date',['R_estimate','R_dashboard'])
print(positive[len(positive)-20:len(positive)-8])