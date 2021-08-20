#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 19 22:49:03 2021

@author: @yuvharpaz
"""
# !pip install xlrd
fname = '/home/innereye/Downloads/bidudim.xlsx'
import pandas as pd
t = pd.read_excel(fname)
# t.to_excel('test.xlsx')
count = 0
for col in t.columns:
    if count > 3:
        dat = t[col]
        if type(dat[0]) == str:
            t[col] = dat.str.replace(u'\xa0', '')
    count += 1
t.to_excel('/home/innereye/Downloads/test.xlsx')