# all-countries.ipynb
import numpy as np
import pandas as pd
import pylab as plt
import seaborn as sns
import matplotlib as mpl

from matplotlib.patches import Polygon
from sklearn.linear_model import LinearRegression
import datetime
import statsmodels.api as sm
import math
import os
import scipy
os.chdir('/home/innereye/Repos/excess-mortality')
def round_to_n(x, n, one_digit_below_100=True, three_digits_above_1mln=True):
    if x==0:
        return 0
    if np.isnan(x):
        return np.nan
    if one_digit_below_100 and np.abs(x) < 100:
        return np.round(x/10) * 10
    if three_digits_above_1mln and np.abs(x) > 1e6:
        return np.round(x/10000) * 10000
    else:
        return round(x, -int(math.floor(math.log10(abs(x)))) + (n - 1))

df = pd.read_csv('https://github.com/akarlinsky/world_mortality/blob/main/world_mortality.csv?raw=true')
# df = pd.read_csv('world_mortality.csv')

df_official_jhu = pd.read_csv('https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv?raw=true')

df_official_who = pd.read_csv('https://covid19.who.int/WHO-COVID-19-global-data.csv')

df_population_wb = pd.read_csv('https://github.com/datasets/population/blob/master/data/population.csv?raw=true')

# df_population_wpp = pd.read_csv('https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/CSV_FILES/WPP2019_TotalPopulationBySex.csv')
df_population_wpp = pd.read_csv('elife2021/frozen-data/WPP2019_TotalPopulationBySex.csv')
df_population_wpp = df_population_wpp[(df_population_wpp['Variant']=='Medium')&(df_population_wpp['Time']==2020)]
df_population = df_population_wpp.rename(columns={'Location':'Country Name', 'PopTotal':'Value'})
df_population['Value'] = df_population['Value'] * 1000

renames = {'The United Kingdom': 'United Kingdom',
           'United States of America': 'United States',
           'Bosnia and Herzegovina': 'Bosnia',
           'Republic of Korea': 'South Korea',
           'Bolivia (Plurinational State of)': 'Bolivia',
           'Iran (Islamic Republic of)': 'Iran',
           'Kosovo[1]': 'Kosovo',
           'Republic of Moldova': 'Moldova',
           'Russian Federation': 'Russia',
           'Brunei Darussalam': 'Brunei',
           'State of Palestine': 'Palestine',
           'occupied Palestinian territory, including east Jerusalem': 'Palestine',

           'Korea, Rep.': 'South Korea',
           'Slovak Republic': 'Slovakia',
           'Iran, Islamic Rep.': 'Iran',
           'Czech Republic': 'Czechia',
           'Egypt, Arab Rep.': 'Egypt',
           'Hong Kong SAR, China': 'Hong Kong',
           'Kyrgyz Republic': 'Kyrgyzstan',
           'Macao SAR, China': 'Macao',

           'China, Hong Kong SAR': 'Hong Kong',
           'China, Macao SAR': 'Macao',
           'China, Taiwan Province of China': 'Taiwan',

           'Türkiye': 'Turkey'}

for c in renames:
    df_official_who.loc[df_official_who['Country'] == c, 'Country'] = renames[c]
    df_official_jhu.loc[df_official_jhu['location'] == c, 'location'] = renames[c]
    df_population.loc[df_population['Country Name'] == c, 'Country Name'] = renames[c]
    df_population_wb.loc[df_population_wb['Country Name'] == c, 'Country Name'] = renames[c]


def get_excess_begin(country, datapoints_per_year=53):
    if datapoints_per_year > 12:
        beg = 9  # week 10

    elif datapoints_per_year > 4 and datapoints_per_year <= 12:
        beg = 2  # March

    elif datapoints_per_year == 4:
        beg = 0

    return beg


def predict_old(X, country, verbose=False):
    # Fit regression model on pre-2020 data
    ind = (X[:, 0] < 2020) & (X[:, 1] < 53)
    m = np.max(X[ind, 1])
    onehot = np.zeros((np.sum(ind), m))
    for i, k in enumerate(X[ind, 1]):
        onehot[i, k - 1] = 1
    predictors = np.concatenate((X[ind, :1], onehot), axis=1)
    reg = LinearRegression(fit_intercept=False).fit(predictors, X[ind, 2])

    if verbose:
        est = sm.OLS(X[ind, 2], predictors).fit()
        print(est.summary())

    # Compute 2020 baseline
    ind2 = X[:, 0] == 2020
    predictors2020 = np.concatenate((np.ones((m, 1)) * 2020, np.eye(m)), axis=1)
    baseline = reg.predict(predictors2020)

    # Week 53 usually does not have enough data, so we'll use
    # the same baseline value as for week 52
    if np.max(X[:, 1]) == 53:
        baseline = np.concatenate((baseline, [baseline[-1]]))

    # Excess mortality
    ind2 = X[:, 0] == 2020
    diff2020 = X[ind2, 2] - baseline[X[ind2, 1] - 1]
    ind3 = X[:, 0] == 2021
    diff2021 = X[ind3, 2] - baseline[X[ind3, 1] - 1]
    excess_begin = get_excess_begin(country, baseline.size)
    total_excess = np.sum(diff2020[excess_begin:]) + np.sum(diff2021)

    # Manual fit for uncertainty computation
    if np.unique(X[ind, 0]).size > 1:
        y = X[ind, 2][:, np.newaxis]
        beta = np.linalg.pinv(predictors.T @ predictors) @ predictors.T @ y
        yhat = predictors @ beta
        sigma2 = np.sum((y - yhat) ** 2) / (y.size - predictors.shape[1])

        S = np.linalg.pinv(predictors.T @ predictors)
        w = np.zeros((m, 1))
        w[X[(X[:, 0] == 2020) & (X[:, 1] < 53), 1] - 1] = 1
        #         if np.max(X[:,1])==53:
        if np.sum((X[:, 0] == 2020) & (X[:, 1] == 53)) > 0:
            w[52 - 1] += 1
        w[:excess_begin] = 0
        w[X[ind3, 1] - 1] += 1

        p = 0
        for i, ww in enumerate(w):
            p += predictors2020[i] * ww
        p = p[:, np.newaxis]

        predictive_var = sigma2 * np.sum(w) + sigma2 * p.T @ S @ p
        total_excess_std = np.sqrt(predictive_var)[0][0]
    else:
        total_excess_std = np.nan

    return baseline, total_excess, excess_begin, total_excess_std


def predict(X, country, verbose=False, excess_begin=None):
    # Fit regression model on pre-2020 data
    ind = (X[:, 0] < 2020) & (X[:, 1] < 53)
    m = np.max(X[ind, 1])
    onehot = np.zeros((np.sum(ind), m))
    for i, k in enumerate(X[ind, 1]):
        onehot[i, k - 1] = 1
    predictors = np.concatenate((X[ind, :1], onehot), axis=1)
    reg = LinearRegression(fit_intercept=False).fit(predictors, X[ind, 2])

    if verbose:
        est = sm.OLS(X[ind, 2], predictors).fit()
        print(est.summary())

    # Compute 2020 baseline
    ind2 = X[:, 0] == 2020
    predictors2020 = np.concatenate((np.ones((m, 1)) * 2020, np.eye(m)), axis=1)
    baseline = reg.predict(predictors2020)

    # Week 53 usually does not have enough data, so we'll use
    # the same baseline value as for week 52
    if np.max(X[:, 1]) == 53:
        baseline = np.concatenate((baseline, [baseline[-1]]))

    # Compute 2021 baseline
    predictors2021 = np.concatenate((np.ones((m, 1)) * 2021, np.eye(m)), axis=1)
    baseline2021 = reg.predict(predictors2021)

    # Compute 2022 baseline
    predictors2022 = np.concatenate((np.ones((m, 1)) * 2022, np.eye(m)), axis=1)
    baseline2022 = reg.predict(predictors2022)

    # Excess mortality
    ind2 = X[:, 0] == 2020
    diff2020 = X[ind2, 2] - baseline[X[ind2, 1] - 1]
    ind3 = X[:, 0] == 2021
    diff2021 = X[ind3, 2] - baseline2021[X[ind3, 1] - 1]
    ind4 = X[:, 0] == 2022
    diff2022 = X[ind4, 2] - baseline2022[X[ind4, 1] - 1]
    if excess_begin is None:
        excess_begin = get_excess_begin(country, baseline.size)
    total_excess = np.sum(diff2020[excess_begin:]) + np.sum(diff2021) + np.sum(diff2022)

    # Manual fit for uncertainty computation
    if np.unique(X[ind, 0]).size > 1:
        y = X[ind, 2][:, np.newaxis]
        beta = np.linalg.pinv(predictors.T @ predictors) @ predictors.T @ y
        yhat = predictors @ beta
        sigma2 = np.sum((y - yhat) ** 2) / (y.size - predictors.shape[1])

        S = np.linalg.pinv(predictors.T @ predictors)
        w = np.zeros((m, 1))
        w[X[(X[:, 0] == 2020) & (X[:, 1] < 53), 1] - 1] = 1
        #         if np.max(X[:,1])==53:
        if np.sum((X[:, 0] == 2020) & (X[:, 1] == 53)) > 0:
            w[52 - 1] += 1
        w[:excess_begin] = 0
        #         w[X[ind3,1]-1] += 1

        p = 0
        for i, ww in enumerate(w):
            p += predictors2020[i] * ww

        w2021 = np.zeros((m, 1))
        w2021[X[ind3, 1] - 1] = 1
        for i, ww in enumerate(w2021):
            p += predictors2021[i] * ww

        w2022 = np.zeros((m, 1))
        w2022[X[ind4, 1] - 1] = 1
        for i, ww in enumerate(w2022):
            p += predictors2022[i] * ww

        p = p[:, np.newaxis]

        predictive_var = sigma2 * (np.sum(w) + np.sum(w2021) + np.sum(w2022)) + sigma2 * p.T @ S @ p
        total_excess_std = np.sqrt(predictive_var)[0][0]
    else:
        total_excess_std = np.nan

    return (baseline, baseline2021, baseline2022), total_excess, excess_begin, total_excess_std


countries = np.unique(df['country_name'])
print(f'Total countries: {countries.size}')

allcountries = {}
allcountries_new = {}

heatwave_excess = np.zeros(countries.size)

for i, country in enumerate(countries):
    print('.', end='')

    assert (np.unique(df[(df['country_name'] == country)]['time_unit']).size == 1)

    X = df[(df['country_name'] == country)][['year', 'time', 'deaths']].values
    X = X[~np.isnan(X[:, 2]), :]
    X = X.astype(int)

    #     if country == 'Peru':
    #         bla = np.concatenate((np.ones((30,1))*2022, np.arange(3,33).reshape((30,1)), np.random.normal(3600, 50, size=(30,1))), axis=1).astype(int)
    #         X = np.concatenate((X, bla), axis=0)

    baselines, total_excess, excess_begin, total_excess_std = predict(X, country)
    #     baseline_new, total_excess_new, excess_begin, total_excess_std_new = predict_new(X, country)

    # https://en.wikipedia.org/wiki/Casualties_of_the_2020_Nagorno-Karabakh_war
    if country == 'Armenia':
        total_excess -= 4000  # 3360
    if country == 'Azerbaijan':
        total_excess -= 4000  # (2854+50)

    # August 2020 heatwave, weeks 32-34
    if country in ['Belgium', 'France', 'Luxembourg', 'Netherlands', 'Germany']:
        heatwave = np.sum(X[(X[:, 0] == 2020) & (X[:, 1] >= 32) & (X[:, 1] <= 34), 2])
        heatwave -= np.sum(baselines[0][32 - 1:34 + 1 - 1])
        total_excess -= heatwave
        heatwave_excess[i] = heatwave

    allcountries[country] = [X, baselines, total_excess, excess_begin, total_excess_std]
#     allcountries_old[country] = [X, baseline, total_excess_new, excess_begin, total_excess_std_new]

with open('baselines.csv', 'w') as f:
    for c in allcountries:
        X, baselines, total_excess, excess_begin, total_excess_std = allcountries[c]
        for i, b in enumerate(baselines[0]):
            f.write(f'{c}, {i + 1}, {b:.1f}\n')

with open('baselines-per-year.csv', 'w') as f:
    for c in allcountries:
        X, baselines, total_excess, excess_begin, total_excess_std = allcountries[c]
        for j, y in enumerate([2020, 2021, 2022]):
            for i, b in enumerate(baselines[j]):
                f.write(f'{c}, {y}, {i + 1}, {b:.1f}\n')

with open('excess-mortality-timeseries.csv', 'w') as f:
    f.write('country_name,year,time,time_unit,excess deaths\n')

    for c in allcountries:
        X, baselines, total_excess, excess_begin, total_excess_std = allcountries[c]
        if baselines[0].size == 4:
            units = 'quarterly'
        elif baselines[0].size == 12:
            units = 'monthly'
        else:
            units = 'weekly'

        ind = X[:, 0] == 2020
        for num, Xrow in enumerate(X[ind]):
            f.write(f'{c},2020,{Xrow[1]},{units},{Xrow[2] - baselines[0][num]:.1f}\n')

        ind = X[:, 0] == 2021
        for num, Xrow in enumerate(X[ind]):
            f.write(f'{c},2021,{Xrow[1]},{units},{Xrow[2] - baselines[1][num]:.1f}\n')

        ind = X[:, 0] == 2022
        for num, Xrow in enumerate(X[ind]):
            f.write(f'{c},2022,{Xrow[1]},{units},{Xrow[2] - baselines[2][num]:.1f}\n')

pops = np.zeros(len(allcountries.keys()))
for i, m in enumerate(allcountries.keys()):
    # Russia's population should include Crimea because mortality figures do
    # Ukraine's population should *not* include Crimea
    if m == 'Russia':
        pops[i] = 146748590  # Rosstat, estimate for 1 Jan 2020
    elif m == 'Ukraine':
        pops[i] = 41762138  # Ukrstat 2020, according to Wikipedia (this does not include Crimea)
        pops[i] -= 2_300_000  # Donetsk People's Republic population, according to Wikipedia
        pops[i] -= 1_500_000  # Luhansk People's Republic population, according to Wikipedia
    elif m == 'Transnistria':
        pops[i] = 465200  # NSO
    elif m == 'Kosovo':
        pops[i] = df_population_wb[df_population_wb['Country Name'] == m]['Value'].values[-1]
    else:
        pops[i] = df_population[df_population['Country Name'] == m]['Value'].values[-1]

pops[countries == 'Serbia'] = pops[countries == 'Serbia'] - pops[countries == 'Kosovo']

official = np.zeros(len(allcountries.keys()))


def stairs(x, y):
    xx = []
    yy = []
    for i in range(x.size):
        if i>0 and x[i]-x[i-1] > 1:
            skip = (x[i]-x[i-1]) - 1
            xx = xx + [np.nan, np.nan] * skip
            yy = yy + [np.nan, np.nan] * skip
        xx = xx + [x[i]-.5, x[i]+.5]
        yy = yy + [y[i], y[i]]
    return xx, yy


def percent_increase(country, zero_not_signif=False):
    X, baselines, total_excess, excess_begin, total_excess_std = allcountries[country]
    d = total_excess / np.sum(baselines[0]) * 100

    if zero_not_signif and np.abs(total_excess) / total_excess_std < 2:
        d = 0 - ord(country[0]) / 100 - ord(country[1]) / 1000  # for alphabetical sorting
    return d


undercounts = np.zeros(countries.size)
for i,country in enumerate(countries):
    if allcountries[country][2]/np.sum(allcountries[country][1][0])*100 < 1:
        undercounts[i] = np.nan
    else:
        if official[i] == 0:
            undercounts[i] = np.nan
        else:
            undercounts[i] = allcountries[country][2] / official[i]

undercounts[np.isin(countries, ['Bermuda', 'Macao'])] = np.nan


#################
ds = np.zeros(len(allcountries))
for i, country in enumerate(allcountries.keys()):
    X, baselines, total_excess, excess_begin, total_excess_std = allcountries[country]
    ds[i] = percent_increase(country, zero_not_signif=False)
ind = np.argsort(ds)[::-1]

thresh = 0

# fig = plt.figure(figsize=(80, 20))
tocorr = np.zeros((len(allcountries),3))
fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(80, 60), dpi=100)
plt.subplots_adjust(right=0.95, left=0.05, top=0.9, bottom=0.3)
col2020 = '#e41a1c'
col2021 = '#386cb0'
col2022 = '#ff7f00'  # '#33a02c'
alpha = .4
width = 0.25
for i, country in enumerate(np.array(list(allcountries.keys()))[ind]):
    #     ax = plt.axes([.032+(i%20)*.0485, .75-np.floor(i/20)*.14, .039, .1])
    X, baselines, total_excess, excess_begin, total_excess_std = allcountries[country]
    baseline = baselines[0]
    #     for year in np.arange(X[0,0],2020):
    #         plt.plot(X[X[:,0]==year, 1], X[X[:,0]==year, 2], color='#aaaaaa', lw=1, clip_on=False)
    yh_2020 = np.nan
    yh_2021 = np.nan
    yh_2022 = np.nan
    if baseline.size < 50:  # months
        xx2, yy2 = stairs(np.arange(baseline.size) + 1, baseline)
        yh_baseline = np.nansum(yy2)

        xx1, yy1 = stairs(X[X[:, 0] == 2020, 1], X[X[:, 0] == 2020, 2])
        yh_2020 = np.nansum(yy1) / yh_baseline
        if np.sum(X[:, 0] == 2021) > 0:
            xx3, yy3 = stairs(X[X[:, 0] == 2021, 1], X[X[:, 0] == 2021, 2])
            yh_2021 = np.nansum(yy3) / yh_baseline
        if np.sum(X[:, 0] == 2022) > 0:
            xx4, yy4 = stairs(X[X[:, 0] == 2022, 1], X[X[:, 0] == 2022, 2])
            yh_2022 = np.nansum(yy4) / yh_baseline
    else:  # weeks
        xx2, yy2 = np.arange(baseline.size) + 1, baseline
        yh_baseline = np.nansum(yy2)

        xx1, yy1 = X[X[:, 0] == 2020, 1], X[X[:, 0] == 2020, 2]
        yh_2020 = np.nansum(yy1) / yh_baseline
        if np.sum(X[:, 0] == 2021) > 1:
            xx3, yy3 = X[X[:, 0] == 2021, 1], X[X[:, 0] == 2021, 2]
            yh_2021 = np.nansum(yy3) / yh_baseline
        elif np.sum(X[:, 0] == 2021) == 1:
            yy3 = X[X[:, 0] == 2021, 2]
            yh_2021 = np.nansum(yy3) / yh_baseline
        if np.sum(X[:, 0] == 2022) > 1:
            xx4, yy4 = X[X[:, 0] == 2022, 1], X[X[:, 0] == 2022, 2]
            yh_2022 = np.nansum(yy4) / yh_baseline
        #             plt.plot(xx4, yy4, color=col2022, lw=1.5, clip_on=False)
        elif np.sum(X[:, 0] == 2022) == 1:
            yy4 = X[X[:, 0] == 2022, 2]
            yh_2022 = np.nansum(yy4) / yh_baseline
    #             plt.plot(X[X[:,0]==2022, 1], X[X[:,0]==2022, 2], '.', color=col2022, markersize=3, clip_on=False)
    #         plt.plot(xx2, yy2, color='k', lw=1, clip_on=False)
    plt.bar(i - width, 100 * yh_2020, color=col2020, width=width)
    plt.bar(i, 100 * yh_2021, color=col2021, width=width)
    plt.bar(i + width, 100 * yh_2022, color=col2022, width=width)
    tocorr[i, 0] = yh_2020
    tocorr[i, 1] = yh_2021
    tocorr[i, 2] = yh_2022
ticks = np.asarray(list(allcountries.keys()))[ind]
plt.xticks(np.arange(len(ticks)), ticks, rotation=90)
plt.yticks(np.arange(0, 160, 10))
plt.grid(axis='y')
plt.xlim(-1, len(ticks) + 1)
plt.title('Excess deaths as percents of annual mortality, by year')
plt.ylabel('Excess deaths (%)')
plt.legend(['2020', '2021', '2022'], loc='upper right')
plt.savefig('img/all-countries-bars.png', dpi=200)
#################
# correlate 2020 and 2021, create a scatter plot
figcorr, axcorr = plt.subplots(nrows=1, ncols=2)
nonan = np.where(~np.isnan(tocorr[:, 0]) & ~np.isnan(tocorr[:, 1]))
nonan1 = np.where(~np.isnan(tocorr[:, 0]) & ~np.isnan(tocorr[:, 1]) & ~np.isnan(tocorr[:, 2]))

y = [tocorr[:, 1], tocorr[:, 2]]
x =  [tocorr[:, 0], tocorr[:, 0]/2+tocorr[:, 1]/2]
r, p = scipy.stats.pearsonr(np.squeeze(x[0][nonan]), np.squeeze(y[0][nonan]))

r1, p1 = scipy.stats.pearsonr(np.squeeze(x[1][nonan1]), np.squeeze(y[1][nonan1]))
R = [r, r1]
P = [p, p1]
title = ['2020 vs 2021\nr = '+str(np.round(R[0], 2))+', p = '+str(np.round(P[0], 10)),
        '(2020+2021)/2 vs 2022\nr = '+str(np.round(R[1], 2))+', p = '+str(np.round(P[1], 2))]
xl = ['2020', '2020+2021']
yl = ['2021', '2022']
for i in range(2):
    axcorr[i].scatter(x[i], y[i], color='k', s=3)
    axcorr[i].set_title(title[i])
    axcorr[i].set_xlim(0, 1.7)
    axcorr[i].set_ylim(0, 1.7)
    axcorr[i].set_aspect('equal', adjustable='box')
    axcorr[i].set_xlabel(xl[i])
    axcorr[i].set_ylabel(yl[i])
    axcorr[i].grid()
    axcorr[i].scatter(x[i][68], y[i][68], color='g', s=15)
    axcorr[i].scatter(x[i][86], y[i][86], color='r', s=15)

#################
ds = np.zeros(len(allcountries))
for i, country in enumerate(allcountries.keys()):
    X, baselines, total_excess, excess_begin, total_excess_std = allcountries[country]
    ds[i] = percent_increase(country, zero_not_signif=False)
ind = np.argsort(ds)[::-1]

thresh = 0

fig = plt.figure(figsize=(8 * 2, 4.5 * 2))

for i, country in enumerate(np.array(list(allcountries.keys()))[ind]):
    ax = plt.axes([.032 + (i % 20) * .0485, .75 - np.floor(i / 20) * .14, .039, .1])

    col2020 = '#e41a1c'
    col2021 = '#386cb0'
    col2022 = '#ff7f00'  # '#33a02c'
    alpha = .4

    X, baselines, total_excess, excess_begin, total_excess_std = allcountries[country]
    baseline = baselines[0]

    for year in np.arange(X[0, 0], 2020):
        plt.plot(X[X[:, 0] == year, 1], X[X[:, 0] == year, 2], color='#aaaaaa', lw=1, clip_on=False)

    if baseline.size < 50:
        xx1, yy1 = stairs(X[X[:, 0] == 2020, 1], X[X[:, 0] == 2020, 2])
        plt.plot(xx1, yy1, color=col2020, lw=1.5, clip_on=False)

        if np.sum(X[:, 0] == 2021) > 0:
            xx3, yy3 = stairs(X[X[:, 0] == 2021, 1], X[X[:, 0] == 2021, 2])
            plt.plot(xx3, yy3, color=col2021, lw=1.5, clip_on=False)

        if np.sum(X[:, 0] == 2022) > 0:
            xx4, yy4 = stairs(X[X[:, 0] == 2022, 1], X[X[:, 0] == 2022, 2])
            plt.plot(xx4, yy4, color=col2022, lw=1.5, clip_on=False)

        xx2, yy2 = stairs(np.arange(baseline.size) + 1, baseline)
        plt.plot(xx2, yy2, color='k', lw=1, clip_on=False)
    else:
        xx1, yy1 = X[X[:, 0] == 2020, 1], X[X[:, 0] == 2020, 2]
        plt.plot(xx1, yy1, color=col2020, lw=1.5, clip_on=False)

        if np.sum(X[:, 0] == 2021) > 1:
            xx3, yy3 = X[X[:, 0] == 2021, 1], X[X[:, 0] == 2021, 2]
            plt.plot(xx3, yy3, color=col2021, lw=1.5, clip_on=False)
        elif np.sum(X[:, 0] == 2021) == 1:
            plt.plot(X[X[:, 0] == 2021, 1], X[X[:, 0] == 2021, 2], '.', color=col2021, markersize=3, clip_on=False)

        if np.sum(X[:, 0] == 2022) > 1:
            xx4, yy4 = X[X[:, 0] == 2022, 1], X[X[:, 0] == 2022, 2]
            plt.plot(xx4, yy4, color=col2022, lw=1.5, clip_on=False)
        elif np.sum(X[:, 0] == 2022) == 1:
            plt.plot(X[X[:, 0] == 2022, 1], X[X[:, 0] == 2022, 2], '.', color=col2022, markersize=3, clip_on=False)

        xx2, yy2 = np.arange(baseline.size) + 1, baseline
        plt.plot(xx2, yy2, color='k', lw=1, clip_on=False)

    toplabel = .3

    if country in ['Belgium', 'France', 'Luxembourg', 'Netherlands', 'Germany', 'Armenia', 'Azerbaijan']:
        star = '*'
    else:
        star = ''

    fs = 8
    z = np.abs(total_excess) / total_excess_std
    if np.isnan(z) or z > thresh:
        if np.abs(total_excess) > 10000 and np.abs(total_excess) < 1e6:
            plt.text(.0, .03, f'{round_to_n(total_excess, 2) / 1000:,.0f}K' + star, transform=plt.gca().transAxes,
                     color='r', fontsize=fs)
        elif np.abs(total_excess) > 1e6:
            plt.text(.0, .03, f'{round_to_n(total_excess, 2) / 1e6:,.2f}M' + star, transform=plt.gca().transAxes,
                     color='r', fontsize=fs)
        else:
            plt.text(.0, .03, f'{round_to_n(total_excess, 2):,.0f}' + star, transform=plt.gca().transAxes,
                     color='r', fontsize=fs)
        plt.text(1, .03, f'{percent_increase(country):.0f}%', transform=plt.gca().transAxes,
                 ha='right', color='#444444', fontsize=fs)
        plt.text(1, toplabel, f'{round_to_n(total_excess / pops[ind][i] * 100000, 2):.0f}',
                 transform=plt.gca().transAxes,
                 ha='right', va='top', color='k', fontsize=fs)
        if ~np.isnan(undercounts[ind][i]):
            plt.text(.0, toplabel, f'{undercounts[ind][i]:.1f}', transform=plt.gca().transAxes,
                     va='top', color='#0000aa', fontsize=fs)
        else:
            plt.text(.0, toplabel, '–', transform=plt.gca().transAxes,
                     va='top', color='#0000aa', fontsize=fs)
    else:
        plt.text(.0, .03, 'n.s.', transform=plt.gca().transAxes,
                 color='r', fontsize=fs)

    if baseline.size < 50:
        poly1 = np.concatenate((xx1[excess_begin * 2:], xx1[excess_begin * 2:][::-1]))
        poly2 = np.concatenate((yy1[excess_begin * 2:], yy2[:len(yy1)][excess_begin * 2:][::-1]))
    else:
        poly1 = np.concatenate((xx1[excess_begin:], xx1[excess_begin:][::-1]))
        poly2 = np.concatenate((yy1[excess_begin:], yy2[:len(yy1)][excess_begin:][::-1]))
    poly = np.concatenate((poly1[:, np.newaxis], poly2[:, np.newaxis]), axis=1)
    poly = Polygon(poly, facecolor=col2020, edgecolor=col2020, alpha=alpha, zorder=5, clip_on=False)
    plt.gca().add_patch(poly)

    if np.sum(X[:, 0] == 2021) > 1 or (baseline.size < 50 and np.sum(X[:, 0] == 2021) > 0):
        poly1 = np.concatenate((xx3, xx3[::-1]))
        poly2 = np.concatenate((yy3[:len(yy3)], yy2[:len(yy3)][::-1]))
        poly = np.concatenate((poly1[:, np.newaxis], poly2[:, np.newaxis]), axis=1)
        poly = Polygon(poly, facecolor=col2021, edgecolor=col2021, alpha=alpha, zorder=6, clip_on=False)
        plt.gca().add_patch(poly)

    if np.sum(X[:, 0] == 2022) > 1 or (baseline.size < 50 and np.sum(X[:, 0] == 2022) > 0):
        poly1 = np.concatenate((xx4, xx4[::-1]))
        poly2 = np.concatenate((yy4[:len(yy4)], yy2[:len(yy4)][::-1]))
        poly = np.concatenate((poly1[:, np.newaxis], poly2[:, np.newaxis]), axis=1)
        poly = Polygon(poly, facecolor=col2022, edgecolor=col2022, alpha=alpha, zorder=7, clip_on=False)
        plt.gca().add_patch(poly)

    plt.ylim([0, 2 * np.mean(baseline)])
    plt.xlim([.5, baseline.size + .5])
    plt.xticks([])

    shorten = {'North Macedonia': 'N. Macedonia',
               'United Kingdom': 'UK',
               'French Polynesia': 'F. Polynesia',
               'United States': 'USA',
               'French Guiana': 'F. Guaiana',
               'Antigua and Barbuda': 'Ant. & Bar.',
               'Dominican Republic': 'Dominican R.',
               'New Caledonia': 'New Cal.',
               'Saint Kitts and Nevis': 'Saint K & N'}
    plt.title(shorten[country] if country in shorten else country,
              fontsize=9, y=.9, zorder=100)

    if i % 20 > 0:
        plt.yticks([])
        sns.despine(left=True, ax=ax)
    else:
        plt.yticks([0, np.mean(baseline), np.mean(baseline) * 2], ['0', '100%', '200%'], fontsize=7)
        sns.despine(ax=ax, offset={'left': 3})
        plt.gca().set_yticklabels(['0', '100%', '200%'], fontsize=8)
        plt.gca().yaxis.set_tick_params(pad=1)

fig.text(.3, .915,
         'Data: World Mortality Dataset, github.com/akarlinsky/world_mortality. '
         'Analysis: github.com/dkobak/excess-mortality.\n'
         'Excess mortality is computed relative to the baseline extrapolated from 2015–19. '
         'Red number: excess mortality starting from March 2020.\n'
         'Gray number: as a % of baseline annual deaths. '
         'Black number: per 100,000 population. '
         'Blue number: ratio to the daily reported covid19 deaths over the same period.\n'
         'Red line and shading: 2020. Blue: 2021. Orange: 2022. Countries are sorted '
         'by the excess deaths as a % of annual deaths.',
         fontsize=8, va='bottom')

fig.text(.995, .001, f'Last update: {datetime.date.today():%b %d, %Y}. '
                     'Ariel Karlinsky, @ArielKarlinsky, Dmitry Kobak, @hippopedoid',
         fontsize=8, ha='right', va='bottom')

plt.savefig('img/all-countries-local.png', dpi=200)