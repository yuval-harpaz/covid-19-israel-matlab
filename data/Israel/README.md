## Israel data
# Israel_ministry_of_health.csv
This is a merged data for official reports. I tried to make it consistent with the tables kept by  [tsvikas](https://github.com/tsvikas/COVID-19-Israel-data/blob/master/daily_reports/total_cases.csv), while integrating data from the [xlsx](https://govextra.gov.il/media/16870/covid19-data-israel.xlsx) release from the government's [website](https://govextra.gov.il/ministry-of-health/corona/corona-virus/). You may also want to compare with [idandrd](https://github.com/idandrd/israel-covid19-data/blob/master/IsraelCOVID19.csv), although this table seems to include only the morning count.<br>
The xlsx file has daily summaries (at midnight I presume) while the rest of the data is mainly morning and evening updates. These have more info compared to the xslx file, like the number of recovered patients.<br>
In addition, a pdf file with morning reading history provided some missing readings, most importantly, the cumulative critical condition.<br>
# Issues
There are some discrepencies. For some dates, the website deceased count in the morning is lower than the daily count of the previous day as published in the xlsx file. I left the problem unresolved because I don't know which is more valid. There may be similar drops of other measures, particularly in the critically ill. I suggest you either use the last measure of the day (xlsx) or use only the other measures.<br>
There seem to be a different count of hospitalized patients on the website and in the xlsx. I keep them in different columns.
# Hotel isolation
Some mild cases are isolated in hotels. Recently I started to collect relevant info from the website, along with home-care patients. So different rows have different info.

