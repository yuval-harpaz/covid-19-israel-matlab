'''
a short version of dancarmoz mohdashboardapi.py (https://github.com/dancarmoz/israel_moh_covid_dashboard_data/)
pulls the current API data. to get backed-up  information use the csv files in that repo
'''

import requests

api_query = {'requests': [
    {'id': '0', 'queryName': 'lastUpdate', 'single': True, 'parameters': {}},
    {'id': '1', 'queryName': 'patientsPerDate', 'single': False, 'parameters': {}},
    {'id': '2', 'queryName': 'testResultsPerDate', 'single': False, 'parameters': {}},
    {'id': '3', 'queryName': 'contagionDataPerCityPublic', 'single': False, 'parameters': {}},
    {'id': '4',
     'queryName': 'infectedByAgeAndGenderPublic',
     'single': False,
     'parameters': {'ageSections': [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]}},
    {'id': '5', 'queryName': 'hospitalStatus', 'single': False, 'parameters': {}},
    {'id': '6', 'queryName': 'isolatedDoctorsAndNurses', 'single': False, 'parameters': {}},
    {'id': '7', 'queryName': 'otherHospitalizedStaff', 'single': False, 'parameters': {}},
    {'id': '8', 'queryName': 'infectedPerDate', 'single': False, 'parameters': {}},
    {'id': '9', 'queryName': 'updatedPatientsOverallStatus', 'single': False, 'parameters': {}},
    {'id': '10', 'queryName': 'sickPerDateTwoDays', 'single': False, 'parameters': {}},
    {'id': '11', 'queryName': 'sickPerLocation', 'single': False, 'parameters': {}},
    {'id': '12', 'queryName': 'deadPatientsPerDate', 'single': False, 'parameters': {}},
    {'id': '13', 'queryName': 'recoveredPerDay', 'single': False, 'parameters': {}},
    {'id': '14', 'queryName': 'doublingRate', 'single': False, 'parameters': {}},
    {'id': '15', 'queryName': 'CalculatedVerified', 'single': False, 'parameters': {}},
    {'id': '16',
     'queryName': 'deadByAgeAndGenderPublic',
     'single': False,
     'parameters': {'ageSections': [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]}},
    {'id': '17',
     'queryName': 'breatheByAgeAndGenderPublic',
     'single': False,
     'parameters': {'ageSections': [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]}},
    {'id': '18',
     'queryName': 'severeByAgeAndGenderPublic',
     'single': False,
     'parameters': {'ageSections': [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]}},
    {'id': '19', 'queryName': 'spotlightLastupdate', 'single': False, 'parameters': {}},
    {'id': '20', 'queryName': 'patientsStatus', 'single': False, 'parameters': {}},
    {'id': '21', 'queryName': 'cumSeriusAndBreath', 'single': False, 'parameters': {}},
    {'id': '22', 'queryName': 'LastWeekLabResults', 'single': False, 'parameters': {}},
    {'id': '23', 'queryName': 'verifiedDoctorsAndNurses', 'single': False, 'parameters': {}},
    {'id': '24', 'queryName': 'isolatedVerifiedDoctorsAndNurses', 'single': False, 'parameters': {}},
    {'id': '25', 'queryName': 'spotlightPublic', 'single': False, 'parameters': {}},
    {'id': '26', 'queryName': 'vaccinated', 'single': False, 'parameters': {}},
    {'id': '27', 'queryName': 'vaccinationsPerAge', 'single': False, 'parameters': {}},
    {'id': '28', 'queryName': 'testsPerDate', 'single': False, 'parameters': {}},
    {'id': '29', 'queryName': 'averageInfectedPerWeek', 'single': False, 'parameters': {}},
    {'id': '30', 'queryName': 'spotlightAggregatedPublic', 'single': True, 'parameters': {}},
    {'id': '31', 'queryName': 'HospitalBedStatusSegmentation', 'single': False, 'parameters': {}},
    ]}
api_address = 'https://datadashboardapi.health.gov.il/api/queries/_batch'
def get_api_data():
    data = requests.post(api_address, json=api_query).json()
    data_dict = {r['queryName']:data[int(r['id'])]['data'] for r in api_query['requests']}
    return data_dict

data = get_api_data()
