# covid-19_data_analysis
See on github [here](https://github.com/yuval-harpaz/covid-19_data_analysis)
<br>
For most affected countries click [here](highest_countries.md)
<br>
[![View Load COVID-19 case data from John Hopkins database on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://se.mathworks.com/matlabcentral/fileexchange/74589-load-covid-19-case-data-from-john-hopkins-database)
## Load COVID-19 case data from John Hopkins database
Loading, processing and plotting the data from the John Hopkins COVID-19 database. The data is automatically read from the online repository, thus, you need a The data can be found here: https://github.com/CSSEGISandData/COVID-19.
adapted from [aahr](https://github.com/aahr/covid-19_data_analysis)
## How to (see runAll.m):
type = 'Confirmed'; % 'Confirmed','Deaths','Recovered'
[dataMatrix] = readCoronaData(type);
[dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);
plotCoronaData(timeVector,mergedData,{'Denmark','US','Germany','China'},type);
