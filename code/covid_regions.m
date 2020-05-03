cd ~/covid-19_data_analysis/
threshold = 500;
[ita,itaPop] = covid_italy;
nyc = covid_nyc;
nyc.PROBABLE_COUNT(isnan(nyc.PROBABLE_COUNT)) = 0;
nyc.CONFIRMED_COUNT(isnan(nyc.CONFIRMED_COUNT)) = 0;
[us,usPop,usDate] = covid_usa;
% us_county = urlread('https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv');
[dataMatrix] = readCoronaData('deaths');
[dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);
for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
pop = readtable('data/population.csv','delimiter',',');
mergedData(~ismember(mergedData(:,1),pop.Country_orDependency_),:) = [];
san_marino = mergedData{ismember(mergedData(:,1),'San Marino'),2}';
[~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
pop = pop(idx,:);
dpm = cellfun(@nanmax, mergedData(:,2))./pop.Population_2020_*10^6;
cou = find(dpm > threshold);
sta = find(us{:,end}./usPop{:,2}*10^6 > threshold);
reg = find(ita{end,2:end}./(itaPop{:,2}')*10^6 > threshold)';
y = nan(length(timeVector),length(cou)+length(reg)+length(sta) + 2);
y(ismember(timeVector,nyc.date_of_death),1) = cumsum(nyc.CONFIRMED_COUNT+nyc.PROBABLE_COUNT)./8.4;
y(ismember(timeVector,nyc.date_of_death),2) = cumsum(nyc.CONFIRMED_COUNT)./8.4;
y(ismember(timeVector,usDate),3:2+length(sta)) = us{sta,2:end}'./usPop{sta,2}'*10^6;
trim = find(~ismember(ita{:,1},timeVector));
ita(trim,:) = [];
y(ismember(timeVector,ita.Date),7:6+length(reg)) = ita{:,1+reg}./itaPop{reg,2}'*10^6;
for iCou = 1:length(cou)
    y(:,14+iCou) = mergedData{cou(iCou),2}./pop.Population_2020_(cou(iCou))*10^6;
end
loc = [{'NYC Probable';'NYC'};us{sta,1};itaPop{reg,1};{mergedData{cou,1}}'];

[~,order] = sort(y(end,:),'descend');
y = y(:,order);
loc = loc(order);

figure;
h = plot(timeVector,y);
xlim(timeVector([40,end]))
yt = max(max(y)):-max(max(y))/size(y,2):0;
for ii = 1:length(yt)-1
    text(timeVector(end),yt(ii),loc{ii},'color',h(ii).Color);
end

grid on
box off
title('worst COVID-19 places')
ylabel('Deaths per million')
set(gca,'fontsize',13)