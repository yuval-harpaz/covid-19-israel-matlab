## How to get the data from the dashboard
The dashboard has an API. to send queries and get the data in json format you can use a curl command, or just use a url with the query.
### curl query
Here are two examples for downloading data with curl.<br>1. Calling curl on linux via a [Matlab](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/code/covid_Israel_moh_dashboard.m) function on Linux<br>2. To call curl with Python you can use dancarmoz's [code](https://github.com/dancarmoz/israel_moh_covid_dashboard_data/blob/master/mohdashboardapi.py)
### URL
You can use this [address](https://datadashboardapi.health.gov.il/api/queries/patientsPerDate) and download the json with your favorite method.
### Get my table
[Here](https://github.com/yuval-harpaz/covid-19-israel-matlab/blob/master/data/Israel/dashboard_timeseries.csv) I collect the data in a csv table. Click on [Raw](https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/dashboard_timeseries.csv) button, copy all the content (Ctrl+A -> Ctrl+C) and paste it in a plain text file, call it something.csv. Then MS Excel or LibreOffice Calc should be able to open it.<br>command line options:<br>**Windows 10**<br>curl.exe -o Downloads\dashboard_timeseries.csv https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/dashboard_timeseries.csv
<br>
**Linux**<br>
curl -o Downloads/dashboard_timeseries.csv https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/dashboard_timeseries.csv


