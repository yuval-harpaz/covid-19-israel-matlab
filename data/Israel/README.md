## 
## Israel data
# Israel_ministry_of_health.csv
[Israel_ministry_of_health.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/Israel_ministry_of_health.csv) is a merged data for official reports. These are realtime counts published on Telegram, and regularly get pushed up in the next 3-4 days. <br>In addition to Telegram a history sheet is published in [csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/covid19-data-israel.csv) format (saved here as covid19-data-israel.csv, see a link on the [web page](https://govextra.gov.il/ministry-of-health/corona/corona-virus/)) and a similar [json](https://data.gov.il/api/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd) report can be downloaded from the big-data team (Timna) [resources](https://data.gov.il/dataset/covid-19). These data are issued in delay and are inconsistent with the real-time reports, but they are more accurate. The ministrie's [dashboard](https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral) has the most accurate and recent data, but the data there can only be accessed with a program, no download buttons (see curl example [here](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/covid_Israel_moh_dashboard.m)). The data collected from the dashboard is held in [dashboard_timeseries.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/dashboard_timeseries.csv). Tests by result (pos / neg), gender(m / f) symptoms (any / none) and age (above / below 60) are downloaded from [Timna resources](https://data.gov.il/dataset/covid-19) into [tests.csv](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/tests.csv)
# יקנרק
םדשות ן עןקדד איןד ןגן .'םרלץ מם' 'שיא?

# Issues
* Hebrew translation may differ from site to site. Here:<br>
mild = קל<br>
severe = בינוני<br>
critical = קשה<br>
The definition is given in a [pdf](https://data.gov.il/dataset/f54e79b2-3e6b-4b65-a857-f93e47997d9c/resource/25343697-571b-4180-b482-61fcd08071b4/download/readme-.pdf) file, were critical (hard, literally) is defined as respiratory or circulatory failure, severe (middle, moderate) is when antibiotics or other care other than pills is required, such as inhalation, intravenous medication or non-invasive oxygen. mild (light, easy) is when the symptoms are light and require no medical attention.

