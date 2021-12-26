## COVID19 dashboards
By [@yuvharpaz](https://twitter.com/yuvharpaz)
The dashboards were written in python, using plotly and dash. The python engine is hosted by [heroku](https://www.heroku.com/)
# [Israel](https://covid-israel.herokuapp.com/)
My dashboard is based on Israel's ministry of health's [dashboard](https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral), some data is taken from [Data Gov](https://data.gov.il/dataset/covid-19)
# [South Afrika](https://sa-covid.herokuapp.com/)
The data is from [NICD](https://www.nicd.ac.za/diseases-a-z-index/disease-index-covid-19/surveillance-reports/daily-hospital-surveillance-datcov-report/), as collected by [DSfSI (Uni Pretoria)](https://github.com/dsfsi/covid19za)
# England
Data for london and England (not UK) is taken from [GOV.UK](https://coronavirus.data.gov.uk/details/download) using API queries such as this: 
<br>
https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaName=England&metric=maleCases&release=2021-12-24
<br>
with the following options:
<br>
areaName=England or London<br>
when London, areaType=region, and not nation as in the example<br>
for cases, run seperate queries using metrics maleCases and femaleCases<br>
for deaths use metric=newDeaths28DaysByDeathDate<br>
use yesterday's date for release, or no release field.
