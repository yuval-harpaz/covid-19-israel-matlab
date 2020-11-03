import pandas as pd
import io
import requests
import numpy as np
from matplotlib import pyplot as plt
import datetime
url="https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/dashboard_timeseries.csv"
s = requests.get(url).content
dashboard = pd.read_csv(io.StringIO(s.decode('utf-8')))
url="https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/positive_to_death.txt"
s = requests.get(url).content
probability = pd.read_csv(io.StringIO(s.decode('utf-8')))
url="https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/tests.csv"
s = requests.get(url).content
tests = pd.read_csv(io.StringIO(s.decode('utf-8')))
#  Moving average smoothiong
N = 7
fm = tests.pos_f_60+tests.pos_m_60
pos60 = np.convolve(fm, np.ones((N,))/N, mode='valid')
pos60 = np.concatenate(([0,0,0],pos60))
for i_end in [6,5,4]:
    pos60 = np.concatenate((pos60,[np.mean(fm[-i_end:])]))

dead = np.convolve(dashboard.CountDeath, np.ones((N,))/N, mode='valid')
dead[0:19] = 0
dead = np.concatenate(([0,0,0],dead))

for i_end in [6,5,4]:
    dead = np.concatenate((dead,[np.mean(dashboard.CountDeath[-i_end:])]))

# predict
pred = np.convolve(pos60, probability['all'], mode='full')
# plot
date_test = [datetime.datetime.strptime(tests['date'][0], '%d-%b-%Y')]
for iDate in range(len(pred)-1):
    date_test.append(date_test[-1] + datetime.timedelta(days=1))
date_dash = [datetime.datetime.strptime(dashboard['date'][0], '%d-%b-%Y')]
for iDate in range(len(dead)-1):
    date_dash.append(date_dash[-1] + datetime.timedelta(days=1))

                                            
fig, axs = plt.subplots()
plt.plot(date_test,pred/10, label='predicted deaths')
plt.plot(date_dash,dead, label='deaths (7 day smoothing)')
plt.xticks(rotation=45)
plt.legend()
plt.suptitle('Daily deaths prediction in Israel by positive tests for over 60y')
plt.ylabel('Deaths')
plt.grid()
plt.show()
