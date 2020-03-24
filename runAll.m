
type = 'confirmed'; % 'confirmed','deaths'

[dataMatrix] = readCoronaData(type);

[dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);

plotCoronaData(timeVector,mergedData,{'Denmark','US','Germany','China'},type);

