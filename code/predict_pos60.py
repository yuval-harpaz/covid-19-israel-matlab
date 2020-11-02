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
pos60 = np.convolve(tests.pos_m_60+tests.pos_f_60, np.ones((N,))/N, mode='valid')
dead = np.convolve(dashboard.CountDeath, np.ones((N,))/N, mode='valid')
numpy.convolve(a, v, mode='full')[source]
