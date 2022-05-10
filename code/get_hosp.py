#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb  3 19:14:55 2022

author: @yuvharpaz
"""
import os
import pandas as pd
api = 'https://datadashboardapi.health.gov.il/api/queries/'
GIT_DIR = "/home/innereye/Repos/israel_moh_covid_dashboard_data"
if os.path.isdir(r'C:\Users\User\Documents\Corona'):
    GIT_DIR = r'C:\Users\User\Documents\Corona'
os.chdir(GIT_DIR)
dfTS = pd.read_json(api+'hospitalizationStatus')
dfTS.columns =['date', 'newHospitalized', 'countHospitalized',
               'countHospitalizedWithoutRelease', 'countHardStatus',
               'countMediumStatus', 'countEasyStatus', 'countBreath', 'countDeath',
               'totalBeds', 'standardOccupancy', 'numVisits', 'patientsHome',
               'patientsHotel', 'countBreathCum', 'countDeathCum',
               'countCriticalStatus', 'countSeriousCriticalCum', 'seriousCriticalNew',
               'countEcmo', 'countDeadAvg7days', 'mediumNew', 'easyNew']
dfTS = dfTS.drop_duplicates(subset=['date'], keep='first')
dfTS.sort_values('date')
dfTS['date'] = dfTS['date'].str.slice(start=None, stop=10)
dfTS.to_excel('hospitalizationStatus.xlsx', index=False)