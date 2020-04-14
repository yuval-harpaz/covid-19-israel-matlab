## covid-19_data_analysis
# See main page [here](https://yuval-harpaz.github.io/covid-19_data_analysis/)

### This repository was adapted from [aahr](https://github.com/aahr/covid-19_data_analysis)<br>
### Load COVID-19 case data from John Hopkins database and plot charts with Matlab
The data is automatically read from the online repository, thus, you need a The data can be found [here](https://github.com/CSSEGISandData/COVID-19)
## How to read the data:
```matlab
[dataMatrix] = readCoronaData('deaths');
[dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);
```

