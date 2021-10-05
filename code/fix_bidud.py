#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 19 22:49:03 2021

@author: @yuvharpaz
"""
# !pip install xlrd
# fname = '/home/innereye/Downloads/דוח נבדקים ובידודים 02.9.21.xlsx'
import pandas as pd
import numpy as np
from glob import glob
import os
os.chdir('/home/innereye/Downloads')
filename = glob('*בידודים*')
for fname in filename:
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
    split = fname.split()
    if not split[-1][0].isdigit():
        raise Exception('no digits')
    t.to_excel('bidud'+split[-1])
# t.to_csv('/home/innereye/Downloads/bidud.csv')

