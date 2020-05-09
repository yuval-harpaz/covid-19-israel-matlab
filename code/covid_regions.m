function covid_regions
cd ~/covid-19_data_analysis/
threshold = 750;
[ita,itaPop] = covid_italy;
nyc = covid_nyc;
nyc.PROBABLE_COUNT(isnan(nyc.PROBABLE_COUNT)) = 0;
nyc.CONFIRMED_COUNT(isnan(nyc.CONFIRMED_COUNT)) = 0;
[us,usPop,usDate] = covid_usa;
[esp,espPop,espDate] = covid_spain;
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
trim = find(~ismember(ita{:,1},timeVector));
ita(trim,:) = [];
spa = find(esp{:,end}./espPop.Var2*10^6 > threshold);
lengths = [2,length(sta),length(reg),length(spa),length(cou)];
y = nan(length(timeVector),sum(lengths));
y(ismember(timeVector,nyc.date_of_death),1) = cumsum(nyc.CONFIRMED_COUNT+nyc.PROBABLE_COUNT)./8.4;
y(ismember(timeVector,nyc.date_of_death),2) = cumsum(nyc.CONFIRMED_COUNT)./8.4;
y(ismember(timeVector,usDate),3:2+lengths(2)) = us{sta,2:end}'./usPop{sta,2}'*10^6;
y(ismember(timeVector,ita.Date),sum(lengths(1:2))+1:sum(lengths(1:3))) = ...
    ita{:,1+reg}./itaPop{reg,2}'*10^6;
y(ismember(timeVector,espDate),sum(lengths(1:3))+1:sum(lengths(1:4))) = ...
    esp{spa,2:end}'./espPop{spa,2}'*10^6;
for iCou = 1:length(cou)
    y(:,sum(lengths(1:4))+iCou) = mergedData{cou(iCou),2}./pop.Population_2020_(cou(iCou))*10^6;
end
loc = [{'NYC Probable';'NYC'};us{sta,1};itaPop{reg,1};espPop.Var1(spa);{mergedData{cou,1}}'];

[~,order] = sort(nanmax(y(end-3:end,:)),'descend');
y = y(:,order);
loc = loc(order);
loc{ismember(loc,'New York')} = 'New York Sate';
iXtick = fliplr(length(timeVector):-7:1);

fig10 = figure('units', 'normalized', 'position',[0.1,0.1,0.5,0.7]);
h = plot(timeVector,y);
xlim(10+timeVector([30,end]))
yt = max(max(y)):-max(max(y))/size(y,2):0;
for ii = 1:length(yt)-1
    text(timeVector(end),yt(ii),loc{ii},'color',h(ii).Color);
end
grid on
box off
title({'worst COVID-19 places',['regions with more than ',num2str(threshold),' deaths per million']})
ylabel('Deaths per million')
set(gca,'fontsize',13,'XTick',timeVector(iXtick))
xtickangle(30)
saveas(fig10,'docs/worst_region.png')