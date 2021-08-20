#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 19 22:49:03 2021

@author: @yuvharpaz
"""
# !pip install xlrd
fname = '/home/innereye/Downloads/bidudim.xlsx'
import pandas as pd
import numpy as np
t = pd.read_excel(fname)
# t.to_excel('test.xlsx')
for count, col in enumerate(t.columns):
    if count > 3:
        dat = t[col]
        if type(dat[0]) == str:
            dat[0] = dat[0].replace('Total','0')
        if type(dat[0]) == str or dat.dtype == np.dtype(object):
            t[col] = [np.int64(str(x).replace('\xa0','').replace('nan','0')) for x in dat]
            t[col] = t[col].astype(float)
            t[col].plot.hist()

# [t[col][t[col]>0].plot() for col in t.columns if type(t[col].values[0]) != str]
# plt.legend()

t.to_excel('/home/innereye/Downloads/test.xlsx')
t.to_csv('/home/innereye/Downloads/test.csv')

