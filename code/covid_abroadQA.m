function covid_abroadQA

options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/positiveArrivingAboardDaily';
paad = webread(url, options);
paad = struct2table(paad);

paad = paad(ismember(paad.visited_country,'כלל המדינות'),:);
dateA = datetime(paad.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
ie = cellfun(@isempty,paad.sum_positive);
paad.sum_positive(ie) = {0};
abroad = cellfun(@(x) x,paad.sum_positive);



aad = struct2table(webread('https://datadashboardapi.health.gov.il/api/queries/arrivingAboardDaily'));
aad = aad(ismember(aad.visited_country,'כלל המדינות'),:);
aadDate = datetime(aad.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

abroad1 = readtable('~/covid-19-israel-matlab/data/Israel/infected_abroad.xlsx');

aac = struct2table(webread('https://datadashboardapi.health.gov.il/api/queries/arrivingAboardCountry'));
% aac = aac(ismember(aac.visited_country,'כלל המדינות'),:);
% aacDate = datetime(aac.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

figure;plot(dateA,abroad);
hold on;
% plot(aadDate,aad.sum_arrival);
plot(abroad1.date,abroad1.incoming);
legend('positiveArrivingAboardDaily','tamatz')
