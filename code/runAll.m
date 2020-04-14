
type = 'confirmed'; % 'confirmed','deaths','recovered'

[dataMatrix] = readCoronaData(type);

[dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);

plotCoronaData(timeVector,mergedData,{'Denmark','US','Germany','China','Italy'},type);
