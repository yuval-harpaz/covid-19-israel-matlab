
type = 'Confirmed'; % 'Confirmed','Deaths','Recovered'

[dataMatrix] = readCoronaData(type);

[dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);

plotCoronaData(timeVector,mergedData,{'Denmark','US','Germany','China'},type);

