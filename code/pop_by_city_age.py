'''
Read population per age per city from https://data.gov.il/dataset/residents_in_israel_by_communities_and_age_groups/resource/64edd0ee-3d5d-43ce-8562-c336c24dbc1f
See also here for other lists https://data.gov.il/dataset/residents_in_israel_by_communities_and_age_groups
@yuvharpaz on twitter
'''
import numpy as np
import pandas as pd

pop = pd.read_json('https://data.gov.il/api/3/action/datastore_search?resource_id=64edd0ee-3d5d-43ce-8562-c336c24dbc1f&limit=5000')
# R = []
# for ii in range(len(positive)-13):
#     R.append((np.sum(positive['amount'][ii+7:ii+14])/np.sum(positive['amount'][ii:ii+7]))**0.685)

# positive['R_estimate'] = factor.loc[len(factor)-1][1]
# for jj in range(len(positive)-13):
#     positive.at[jj+7-4,'R_estimate'] = R[jj]

# positive['R_dashboard'] = factor.loc[len(factor)-1][1]
# for kk in range(len(factor)):
#     positive.loc[kk+140,'R_dashboard'] = factor.loc[kk][1]
    
# positive.plot('date',['R_estimate','R_dashboard'])
# print(positive[len(positive)-20:len(positive)-8])