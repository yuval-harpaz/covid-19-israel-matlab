import pandas as pd
import io
import requests
import numpy as np
from matplotlib import pyplot as plt
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

fig, axs = plt.subplots()
plt.plot(pred/10)
plt.plot(dead)
plt.show()
