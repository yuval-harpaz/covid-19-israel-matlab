## 
## Israel data
# Israel ministry of health data
[Israel_ministry_of_health.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/Israel_ministry_of_health.csv) is a merged data for official reports. These are realtime counts published on Telegram, and regularly get pushed up in the next 3-4 days. <br>In addition to Telegram a history sheet is published in [csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/covid19-data-israel.csv) format (saved here as covid19-data-israel.csv, see a link on the [web page](https://govextra.gov.il/ministry-of-health/corona/corona-virus/)) and a similar [json](https://data.gov.il/api/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd) report can be downloaded from the big-data team (Timna) [resources](https://data.gov.il/dataset/covid-19). These data are issued in delay and are inconsistent with the real-time reports, but they are more accurate. The ministries [dashboard](https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral) has the most accurate and recent data, but the data there can only be accessed with a program, no download buttons (see curl example [here](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/covid_Israel_moh_dashboard.m)). The data collected from the dashboard is held in [dashboard_timeseries.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/dashboard_timeseries.csv). Tests by result (pos / neg), gender(m / f) symptoms (any / none) and age (above / below 60) are downloaded from [Timna resources](https://data.gov.il/dataset/covid-19) into [tests.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/tests.csv)
# נתוני משרד הבריאות
הנתונים מהדאשבורד של משרד הבריאות נשמרים בקובץ [dashboard_timeseries.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/dashboard_timeseries.csv).<br> נתוני בדיקות לפי גיל, מין, וסימפטומים מרוכזים בקובץ [tests.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/tests.csv)<br>
* ניבוי תמותה לפי תוצאות חיוביות לגילאי 60+ מתואר בקובץ [Predict_Deaths_by_tests60.md](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/Predict_Deaths_by_tests60.m/)<br>

# dashboard_timeseries.csv
[dashboard_timeseries.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/dashboard_timeseries.csv) contains the following fields. Field names are kept as they were in the database. Note that Severe condition is defined by low blood saturation. Only some of severe patients are critical, and only some critical patients are ventilated.
| Field                              | details                                 |
|-------------------------------------|------------------------------------------|
| date                              | date                                     |
| tests                             | number of tests collected                |
| tests_result                      | number of test results received          |
| tests_positive                    | number of positive test results received |
| tests_cumulative                  | cumulative sum of tests                  |
| new_hospitalized                  | newely hospitalized                      |
| Counthospitalized                 | all hospitalized today                   |
| Counthospitalized_without_release | ?                                        |
| CountHardStatus                   | all sever patients today                 |
| CountMediumStatus                 | all mild patients today                  |
| CountEasyStatus                   | all easy patients today                  |
| CountBreath                       | all ventilated patients today            |
| CountDeath                        | new deaths                               |
| total_beds                        | total beds                               |
| StandardOccupancy                 | ?                                        |
| num_visits                        | number of visits                         |
| patients_home                     | patients staying at home                 |
| patients_hotel                    | patients staying at corona hotels        |
| CountBreathCum                    | cumulative ventilated patients           |
| CountDeathCum                     | cumulative deaths                        |
| CountCriticalStatus               | all critical patients today              |
| CountSeriousCriticalCum           | cumulative critical status               |
| recovered                         | recovered patients today                 |
