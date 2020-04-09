% plot 30 largest countries + Israel
alwaysShow = {'China','Korea, South','Japan','Singapore','Israel'};
 %'largest' 'most_deaths' 'most_deaths_daily' 'most_deaths_norm' 'most_deaths_daily_norm'
  method = 'most_deaths_norm';      
        
nCountries = 31;
showDateEvery = 7; % days
zer = 1; % how many deaths per million to count as day zero

warning off
disp('Reading tables...')
type = 'deaths';
[dataMatrix] = readCoronaData(type);
[dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);
for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
iXtick = [1,showDateEvery:showDateEvery:length(timeVector)];
pop = readtable('population.csv','delimiter',',');
warning on
mergedData(~ismember(mergedData(:,1),pop.Country_orDependency_),:) = [];
% plotCoronaData(timeVector,mergedData,{alwaysShow,'US','Germany','China'},type);
%covid = readtable('covid.csv');

switch method % which nCOuntries to take
    case 'most_deaths_daily' % worst yesterday
        lastDay = cellfun(@(x) x(end)-x(end-1), mergedData(:,2));
        [~, iworst] = sort(lastDay,'descend');
        country = mergedData(iworst(1:nCountries),1);
    case 'most_deaths'
        [~, iworst] = sort(cellfun(@max, mergedData(:,2)),'descend');
        country = mergedData(iworst(1:nCountries),1);
    case 'largest' % most populus countries
        country = pop.Country_orDependency_(1:nCountries);
    case 'most_deaths_norm' % most deatsh per million
        [~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
        [~, iworst] = sort(cellfun(@max, mergedData(:,2))./pop.Population_2020_(idx),'descend');
        country = mergedData(iworst(1:nCountries),1);
    case 'most_deaths_daily_norm' % worst yesterday per million
        [~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
        lastDay = cellfun(@(x) x(end)-x(end-1), mergedData(:,2));
        [~, iworst] = sort(lastDay./pop.Population_2020_(idx),'descend');
        country = mergedData(iworst(1:nCountries),1);
        
end
leftOut = alwaysShow(~ismember(alwaysShow,country));
if ~isempty(leftOut)
    country(end-length(leftOut)+1:end) = leftOut;
end
% ismember(country,mergedData(:,1))
cases = nan(length(timeVector),nCountries);
for iCou = 1:length(country)
    cases(1:length(timeVector),iCou) = mergedData{ismember(mergedData(:,1),country{iCou}),2};
end
[isx,idx] = ismember(country,pop.Country_orDependency_);
if any(isx == 0)
    country(~ismember(country,pop.Country_orDependency_))
    error('missing country')
end
mil = pop.Population_2020_(idx)/10^6;
norm = cases./mil';
% figure;
% plot(norm)

aligned = nan(size(norm));
for iState = 1:nCountries
    start = find(norm(:,iState) > zer,1);
    aligned(1:size(norm,1)-start+1,iState) = norm(start:end,iState);
end

% selected = ismember(country,{alwaysShow,'Italy','Spain','France','United Kingdom','Iran','Germany','China','Korea, South','US'});
% iSel = find(selected);
[~,order] = sort(nanmax(norm),'descend');
iMy = find(ismember(country,alwaysShow));
if any(norm(end,iMy) < zer)
    warning(['countries with less than ',num2str(zer),' deaths per million will not be visible:']) 
    disp(alwaysShow(norm(end,iMy) < zer));
end
%% plot
figure;
subplot(2,2,1)
plot(cases(:,order),'linewidth',1,'marker','.');
hold on
plot(cases(:,iMy),'linewidth',1.5,'marker','.');
% ann = [order(1:9);nCountries];
for iAnn = 1:nCountries
%     if nanmax(aligned(:,iAnn)) > 1
    x = size(cases,1);
    text(x,cases(x,iAnn),country{iAnn});
%     end
end
xlim([0 size(cases,1)+20])
box off
grid on
ylabel('Deaths')
xlabel(['Days from ',datestr(timeVector(1))])
title(['Deaths up to ',datestr(timeVector(end))])
set(gca,'XTick',iXtick,'XTickLabel',datestr(timeVector(iXtick),'dd.mm'))
%plot(cases(:,iSel(order)),'linestyle','none','marker','.');
subplot(2,2,2)
plot(aligned(:,order),'linewidth',1,'marker','.');
hold on
plot(aligned(:,iMy),'linewidth',1.5,'marker','.');
for iAnn = 1:length(country)
    x = find(~isnan(aligned(:,order(iAnn))),1,'last');
    text(x,aligned(x,order(iAnn)),country{order(iAnn)});
end

xlim([0 find(~any(~isnan(aligned),2),1)+5])
box off
grid on
ylabel('Deaths per million')
xlabel('Days from country day zero (day zero = 1 death per million)')
title({'Deaths per million, alligned','time zero set to 1 death per million'})
set(gca,'XTick',iXtick,'XTickLabel',iXtick)
subplot(2,2,3)
y = diff(cases(:,order));
plot(y,'linewidth',1,'marker','.');
hold on
plot(y(:,iMy),'linewidth',1.5,'marker','.');
for iAnn = 1:length(country)
    x = size(y,1);
    text(x,y(x,iAnn),country{order(iAnn)});
end
xlim([0 size(cases,1)+20])
box off
grid on
ylabel('Deaths')
xlabel(['Days from ',datestr(timeVector(1))])
title(['Daily deaths up to ',datestr(timeVector(end))])
set(gca,'XTick',iXtick,'XTickLabel',datestr(timeVector(iXtick),'dd.mm'))

subplot(2,2,4)
maxy = 50;
plot(aligned(:,order),'linewidth',1,'marker','.');
hold on
plot(aligned(:,iMy),'linewidth',1.5,'marker','.');
for iAnn = 1:length(country)
    x = find(~isnan(aligned(:,order(iAnn))),1,'last');
    if aligned(x,order(iAnn)) < maxy
        text(x,aligned(x,order(iAnn)),country{order(iAnn)});
    end
end
disp('done')
xlim([0 find(~any(~isnan(aligned),2),1)+5])
ylim([0 maxy])
box off
grid on
ylabel('Deaths per million')
xlabel('Days from country day zero (day zero = 1 death per million)')
title({'Deaths per million, alligned (zoomed in)','time zero set to 1 death per million'})
set(gcf,'Color',[0.8 0.95 1])
set(gca,'XTick',iXtick,'XTickLabel',iXtick)


% 
% pop.Country_orDependency_(ismember(pop.Country_orDependency_,'United States')) = {'US'};
% pop.Country_orDependency_(ismember(pop.Country_orDependency_,'South Korea')) = {'Korea, South'};
% pop.Country_orDependency_(ismember(pop.Country_orDependency_,'DR Congo')) = {'Congo (Kinshasa)'};
% pop.Country_orDependency_(ismember(pop.Country_orDependency_,'Congo')) = {'Congo (Brazzaville)'};
% pop.Country_orDependency_(ismember(pop.Country_orDependency_,'Myanmar')) = {'Burma'};
% pop.Country_orDependency_(ismember(pop.Country_orDependency_,'Czech Republic (Czechia)')) = {'Czechia'};
% pop.Country_orDependency_(ismember(pop.Country_orDependency_,'Taiwan')) = {'Taiwan*'};
% pop.Country_orDependency_(ismember(pop.Country_orDependency_,'State of Palestine')) = {'West Bank and Gaza'};
% pop.Country_orDependency_(contains(pop.Country_orDependency_,'voi')) = {['Cote d''','Ivoire']};
% pop(~ismember(pop.Country_orDependency_,mergedData(:,1)),:) = [];
% pop = pop(:,[2,3,6]);
% pop.Country_orDependency_{end+1,1} = 'Kosovo';
% pop.Population_2020_(end) = 1831463;
% pop.Density_P_Km__(end) = 159;
% writetable(pop,'population.csv','Delimiter',',','WriteVariableNames',true);