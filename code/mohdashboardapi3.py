import os
import requests
import pandas as pd

GIT_DIR = '/home/innereye/Downloads'
if os.path.isdir(r'C:\Users\User\Documents\Corona'):
    GIT_DIR = r'C:\Users\User\Documents\Corona'

api_query = {'requests': [
    {'id': '0', 'queryName': 'lastUpdate', 'single': True, 'parameters': {}},
    {'id': '1', 'queryName': 'patientsPerDate', 'single': False, 'parameters': {}},
    {'id': '2', 'queryName': 'testResultsPerDate', 'single': False, 'parameters': {}},
    {'id': '3', 'queryName': 'contagionDataPerCityPublic', 'single': False, 'parameters': {}},
    {'id': '4', 'queryName': 'infectedByPeriodAndAgeAndGender',
     'single': False,  'parameters': {}},
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
     'queryName': 'deadByPeriodAndAgeAndGender',
      'single': False,  'parameters': {}},
    {'id': '17',
     'queryName': 'breatheByPeriodAndAgeAndGender',
     'single': False,  'parameters': {}},
    {'id': '18',
     'queryName': 'severeByPeriodAndAgeAndGender',
     'single': False,  'parameters': {}},
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
    {'id': '32', 'queryName': 'infectionFactor', 'single': False, 'parameters': {}},
    {'id': '33', 'queryName': 'vaccinatedVerifiedDaily', 'single': False, 'parameters': {'days': 0}},
    {'id': '34', 'queryName': 'vaccinatedVerifiedByAge', 'single': False, 'parameters': {}},
    {'id': '35', 'queryName': 'researchGraph', 'single': False, 'parameters': {}},
    ]}
api_address = 'https://datadashboardapi.health.gov.il/api/queries/_batch'
def get_api_data():
    data = requests.post(api_address, json=api_query).json()
    data_dict = {r['queryName']:data[int(r['id'])]['data'] for r in api_query['requests']}
    return data_dict

data = get_api_data()



os.chdir(GIT_DIR)
DATA_FNAME = 'moh_dashboard_api_data.json'
COMMIT_HIST_FNAME = 'commit_history.json'
AGES_FNAME = 'ages_dists.csv'
ALL_AGES_FNAMES = {'infected':'ages_dists_v2.csv', 'dead':'deaths_ages_dists_v2.csv',
                   'severe':'severe_ages_dists_v2.csv', 'breathe':'ventilated_ages_dists_v2.csv'}
HOSP_FNAME = 'hospitalized_and_infected.csv'
VAC_FNAME = 'vaccinated.csv'
VAC_AGES_FNAME = 'vaccinated_by_age.csv'
VAC_CASES_DAILY = 'cases_by_vaccination_daily.csv'
VAC_CASES_AGES = 'cases_by_vaccination_ages.csv'
HOSPITALS_FNAME = 'hospital_occupancy.csv'
HOSP_HEB_FIELD_NAMES = [
    '\xd7\xaa\xd7\xa4\xd7\x95\xd7\xa1\xd7\x94 \xd7\x9b\xd7\x9c\xd7\x9c\xd7\x99\xd7\xaa',
    '\xd7\xaa\xd7\xa4\xd7\x95\xd7\xa1\xd7\xaa \xd7\xa7\xd7\x95\xd7\xa8\xd7\x95\xd7\xa0\xd7\x94',
    '\xd7\xa6\xd7\x95\xd7\x95\xd7\xaa \xd7\x91\xd7\x91\xd7\x99\xd7\x93\xd7\x95\xd7\x93']
ISOLATED_FNAME = 'isolated_staff.csv'

names_trans = {
    'doctors' : u'\u05e8\u05d5\u05e4\u05d0\u05d9\u05dd/\u05d5\u05ea',
    'nurses' : u'\u05d0\u05d7\u05d9\u05dd/\u05d5\u05ea',
    'others' : u'\u05de\u05e7\u05e6\u05d5\u05e2\u05d5\u05ea\n\u05d0\u05d7\u05e8\u05d9\u05dd'}


heb_map = {
    u'\u05e6\u05d4\u05d5\u05d1': 'yellow',
    u'\u05e6\u05d4\u05d5\u05d1 ': 'yellow',
    u'\u05d0\u05d3\u05d5\u05dd': 'red',
    u'\u05d0\u05d3\u05d5\u05dd ': 'red',
    u'\u05db\u05ea\u05d5\u05dd': 'orange',
    u'\u05db\u05ea\u05d5\u05dd ': 'orange',
    u'\u05d9\u05e8\u05d5\u05e7': 'green',
    u'\u05d9\u05e8\u05d5\u05e7 ': 'green',
    u'\u05d0\u05e4\u05d5\u05e8': 'gray',
    u'\u05d0\u05e4\u05d5\u05e8 ': 'gray',
    u' \u05e7\u05d8\u05df \u05de-15 ': '<15'
}

heb_translit = {
    u'\u05d0': 'a',
    u'\u05d1': 'b',
    u'\u05d2': 'g',
    u'\u05d3': 'd',
    u'\u05d4': 'h',
    u'\u05d5': 'v',
    u'\u05d6': 'z',
    u'\u05d7': 'j',
    u'\u05d8': 't',
    u'\u05d9': 'y',
    u'\u05da': 'C',
    u'\u05db': 'c',
    u'\u05dc': 'l',
    u'\u05dd': 'M',
    u'\u05de': 'm',
    u'\u05df': 'N',
    u'\u05e0': 'n',
    u'\u05e1': 's',
    u'\u05e2': 'e',
    u'\u05e3': 'f',
    u'\u05e4': 'p',
    u'\u05e5': 'X',
    u'\u05e6': 'x',
    u'\u05e7': 'q',
    u'\u05e8': 'r',
    u'\u05e9': 'SH',
    u'\u05ea': 'T',
    '"' : '', 
    ' ': '_'
}

def safe_str(s):
    return '%s'%(heb_map.get(s, s))


def safe_int(x):
    # converts possible None returned by API to 0
    return x if x else 0

def add_line_to_file(fname, new_line):
    prev_file = file(fname, 'r').read()
    new_file = prev_file + new_line + '\n'
    file(fname, 'w').write(new_file)
    assert os.system('git add ' + fname) == 0

def ages_csv_line(data, prefix='infected'):
    date = data['lastUpdate']['lastUpdate']
    ages_dicts = data[prefix + 'ByPeriodAndAgeAndGender']
    period = u'\u05de\u05ea\u05d7\u05d9\u05dc\u05ea \u05e7\u05d5\u05e8\u05d5\u05e0\u05d4'
    secs = [ent for ent in ages_dicts if ent['period'] == period]
    ##    assert ''.join([s['section'][0] for s in secs]) == '0123456789'
    assert [s['section'] for s in secs] == [
        '0-9', '10-11', '12-15', '16-19', '20-29', '30-39',
        '40-49', '50-59', '60-69', '70-74', '75+']
    males = [safe_int(sec['male']['amount']) for sec in secs]
    females = [safe_int(sec['female']['amount']) for sec in secs]
    totals = [m+f for m,f in zip(males, females)]
    return ','.join([date]+map(str,totals) + map(str, males) + map(str,females))


def update_ages_csv(data):
    ages_line = ages_csv_line(data)
    add_line_to_file(AGES_FNAME, ages_line)

def update_specific_ages_csv(data, prefix):
    fname = ALL_AGES_FNAMES[prefix]
    ages_line = ages_csv_line(data, prefix)
    add_line_to_file(fname, ages_line)
    
def update_all_ages_csvs(data):
    for prefix in ALL_AGES_FNAMES.keys():
        update_specific_ages_csv(data, prefix)

def update_age_vaccinations_csv(data):
    vac_ages = data['vaccinationsPerAge']
    # Check for surprising age group
    assert len(vac_ages) == 9
    new_line = data['lastUpdate']['lastUpdate']+',' + ','.join(['%d,%d,%d'%(
        g['age_group_population'],g['vaccinated_first_dose'],g['vaccinated_second_dose'])
                                                  for g in vac_ages])
    add_line_to_file(VAC_AGES_FNAME, new_line)

def patients_to_csv_line(pat):
    keys = ['Counthospitalized', 'Counthospitalized_without_release',
            'CountEasyStatus', 'CountMediumStatus', 'CountHardStatus',
            'CountCriticalStatus' ,'CountBreath', 'CountDeath',
            'CountSeriousCriticalCum', 'CountBreathCum', 'CountDeathCum',
            'new_hospitalized', 'serious_critical_new',
            'patients_hotel', 'patients_home',
            ]
    return ','.join([pat['date'][:10]]+[str(pat[key]) for key in keys])


def create_patients_csv(data):
    start_date = u'2020-03-02T00:00:00.000Z'
    patients = data['patientsPerDate']
    assert patients[0]['date'] == start_date
    N = len(patients)
    # Sometimes the json contains multiple entires... argh
    if len(set([p['date'] for p in patients])) != N:
        rev_pat_dates = [p['date'] for p in patients[::-1]]
        pat_dates_fil = sorted(set(rev_pat_dates))
        patients = [patients[N-1-rev_pat_dates.index(date)] for date in pat_dates_fil]
        N = len(patients)       
    
    pat_lines = map(patients_to_csv_line, patients)
    
    recs = data['recoveredPerDay'][-N:]
    inf = data['infectedPerDate'][-N:]
    assert recs[0]['date'] == inf[0]['date'] == start_date
    # assert recs[0]['date'] == start_date

    tests = [t for t in data['testResultsPerDate'] if t['positiveAmount']!=-1][-N:]
    tests2 = data['testsPerDate'][-N:]
    assert tests[0]['date'] == tests2[0]['date'] == start_date
    epi_lines = [','.join(map(str, [t['positiveAmount'], i['sum'],
                                    i['amount'], r['amount'],
                                    t['amount'], t['amountVirusDiagnosis'],
                                    t['amountPersonTested'], t['amountMagen'],
                                    t2['amountSurvey']])) for \
                 i, r, t, t2 in zip(inf, recs, tests, tests2)]

    inff = data['infectionFactor']
    def repr_if_not_none(x):
        if x is None: return ''
        return repr(x)
    inff_dict = {i['day_date']:repr_if_not_none(i['R']) for i in inff}
    inff_lines = [inff_dict.get(p['date'], '') for p in patients]
    
    title_line = ','.join(['Date', 'Hospitalized', 'Hospitalized without release',
                            'Easy', 'Medium', 'Hard', 'Critical', 'Ventilated', 'New deaths',
                            'Serious (cumu)', 'Ventilated (cumu)', 'Dead (cumu)',
                            'New hosptialized', 'New serious', 'In hotels', 'At home',
                            
                           'Positive results', 'Total infected', 'New infected',
                           'New receovered', 'Total tests', 'Tests for idenitifaction',
                           'People tested', 'Tests for Magen', 'Survey tests',
                            'Official R'])
    csv_data = '\n'.join([title_line] + [
        ','.join([p,e,i]) for p,e,i in zip(pat_lines, epi_lines, inff_lines)])
    opf = open(HOSP_FNAME,'w')
    opf.write(csv_data+'\n')




def create_vaccinated_csv(data):
    vac = data['vaccinated']
    title_line = ','.join([
        'Date', 'Vaccinated (daily)','Vaccinated (cumu)','Vaccinated population percentage',
        'Second dose (daily)','Second dose (cumu)','Second dose population precentage'])
    data_lines = [','.join([d['Day_Date'][:10]]+list(map(str, [
        d['vaccinated'], d['vaccinated_cum'], d['vaccinated_population_perc'],
        d['vaccinated_seconde_dose'], d['vaccinated_seconde_dose_cum'],
        d['vaccinated_seconde_dose_population_perc']]))) for d in vac]
    csv_data = '\n'.join([title_line]+data_lines)
    # file(VAC_FNAME, 'w').write(csv_data+'\n')
    # assert os.system('git add '+VAC_FNAME) == 0
    opf = open(VAC_FNAME,'w')
    opf.write(csv_data+'\n')


def extend_hospital_csv(data):
    csv_prev_lines = file(HOSPITALS_FNAME).read().splitlines()
    keys = [k.split(':')[0] for k in csv_prev_lines[0].split(',')[1::3]]
    hosp_dict = dict([(z['name'].encode('utf8').replace('"','').replace("'",""),
                        (z['normalOccupancy'], z['coronaOccupancy'], z['isolatedTeam']))
                      for z in data['hospitalStatus']])
    new_line = [data['lastUpdate']['lastUpdate'].encode('utf8')]
    for k in keys:
        if k in hosp_dict.keys():
            no, co, it = hosp_dict[k]
            if no is None:
                no = 'None'
            else:
                no = '%.2f'%(no)
            new_line.append('%s,%.2f,%d'%(no,co,it))
        else:
                new_line.append(',,')
    a,b,c = HOSP_HEB_FIELD_NAMES
    for k in sorted(list(set(hosp_dict.keys()).difference(set(keys)))):
        csv_prev_lines[0] += ',%s: %s,%s: %s,%s :%s'%(k,a,k,b,k,c)
        for j in range(1,len(csv_prev_lines)):
            csv_prev_lines[j] += ',,,'
        no, co, it = hosp_dict[k]
        if no is None:
            no = 'None'
        else:
            no = '%.2f'%(no)
        new_line.append('%s,%.2f,%d'%(no,co,it))
    csv_prev_lines.append(','.join(new_line))
    file(HOSPITALS_FNAME, 'w').write('\n'.join(csv_prev_lines))
    assert os.system('git add '+HOSPITALS_FNAME) == 0    


def update_isolated_csv(data):
    csv_lines = file(ISOLATED_FNAME).read().splitlines()
    isols = {item['name'] : item['amount'] for item in data['isolatedDoctorsAndNurses']}
    veris = {item['name'] : item['amount'] for item in data['verifiedDoctorsAndNurses']}
    new_line = [data['lastUpdate']['lastUpdate']] + [str(dic[names_trans[k]]) for dic,k in
                  [(isols, 'doctors'),(veris, 'doctors'),
                  (isols, 'nurses'), (veris, 'nurses'),
                  (isols, 'others'), (veris, 'others')]]
    if new_line[1:] == csv_lines[-1].split(',')[1:]: return
    file(ISOLATED_FNAME, 'w').write('\n'.join(csv_lines + [','.join(new_line)]))
    assert os.system('git add '+ISOLATED_FNAME) == 0    


city_title_line = ','.join(['Date']+[
    'sickCount', 'actualSick', 'patientDiffPopulationForTenThousands', 'testLast7Days',
    'verifiedLast7Days'] + [
    u'activeSick', u'activeSickTo1000',u'sickTo10000', u'growthLastWeek', u'positiveTests',
    u'score', u'color', u'governmentColor', u'firstDose', u'secondDose'
])

def create_city_line(cpp_ent, spp_ent, date):
    cpp_keys = ['sickCount', 'actualSick', 'patientDiffPopulationForTenThousands', 'testLast7Days',
                'verifiedLast7Days']
    spp_keys = [u'activeSick', u'activeSickTo1000',u'sickTo10000', u'growthLastWeek', u'positiveTests',
                u'score', u'color', u'governmentColor', u'firstDose', u'secondDose']
    line = ','.join([date]+[safe_str(cpp_ent.get(key, '')) for key in cpp_keys] + \
                    [safe_str(spp_ent.get(key, '')) for key in spp_keys])
    return line


def strip_name(name):
    return ''.join([heb_translit.get(c,c) for c in name])

    
def update_cities(new_data):
    date = new_data['lastUpdate']['lastUpdate']
    cd_dict = {a['city'] : a for a in new_data['contagionDataPerCityPublic']}
    sp_dict = {a['name'] : a for a in new_data['spotlightPublic']}
    for n in set(sp_dict.keys())|set(cd_dict.keys()):
        line = create_city_line(cd_dict.get(n, {}), sp_dict.get(n, {}), date)
        fname = 'cities/%s.csv'%(strip_name(n))
        try:
            add_line_to_file(fname, line)
        except IOError:
            # file didn't exist - new city name encountered
            print('New city!')
            print (fname)
            file(fname, 'w').write(city_title_line+'\n'+line+'\n')
            assert os.system('git add ' + fname) == 0
            add_line_to_file('cities_transliteration.csv', ('%s,%s'%(n, strip_name(n))).encode('utf-8'))


def create_cases_by_vaccinations_daily(data):
##    res = ',' + (','*9).join(['All ages', 'Above 60', 'Below 60']) + ','*8 + '\n'
    res = ',' + ',,,'.join([pre+' - '+suf
                            for pre in ['All ages', 'Above 60', 'Below 60']
                            for suf in ['fully vaccinated', 'partially vaccinated', 'not vaccinated']
                            ]) + ','*2 + '\n'    
    res += 'Date' + ',Total Amount,Daily verified,Total serious'*9 + '\n'
    vvd = data['vaccinatedVerifiedDaily']
    for i in range(0, len(vvd), 3):
        s = sorted(vvd[i:i+3], key=lambda x: x['age_group'])
        assert s[0]['day_date'] == s[2]['day_date'] == s[2]['day_date']
        line = s[0]['day_date']+','
        line += ','.join([
            str(ss[case_type%vacc_type])
            for ss in s
            for vacc_type in ['vaccinated', 'vaccinated_procces', 'not_vaccinated']
            for case_type in ['%s_amount_cum', 'verified_amount_%s', 'Serious_amount_%s']])
        res += line + '\n'
    # file(VAC_CASES_DAILY, 'w').write(res)
    opf = open(VAC_CASES_DAILY,'w')
    opf.write(res+'\n')       


data = get_api_data()
create_patients_csv(data)
create_vaccinated_csv(data)
create_cases_by_vaccinations_daily(data)

# vacc = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedDaily')
# vacc.to_csv('vaccinatedVerifiedDaily.csv')

research = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/researchGraph')
research.to_csv('researchGraph.csv')

