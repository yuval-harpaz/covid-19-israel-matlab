% plot 20 most active countries
cd ~/covid-19_data_analysis/
nCountries = 20;
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


[~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
[~, iworst] = sort(cellfun(@max, mergedData(:,2))./pop.Population_2020_(idx),'descend');
country = mergedData(iworst(1:nCountries),1);

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
% iMy = find(ismember(country,alwaysShow));
% if any(norm(end,iMy) < zer)
%     warning(['countries with less than ',num2str(zer),' deaths per million will not be visible:'])
%     disp(alwaysShow(norm(end,iMy) < zer));
% end
%% plot
fig2 = figure('units','normalized','position',[0,0,0.5,1]);
for iPlot = 1:2
    subplot(2,1,iPlot)
    h = plot(aligned(:,order),'linewidth',1,'marker','.','MarkerSize',8);
    xlim([0 find(~any(~isnan(aligned),2),1)+5])
    box off
    grid on
    ylabel('Deaths per million')
    xlabel('Days from country day zero (1 death per million)')
    
    set(gca,'XTick',iXtick,'XTickLabel',iXtick)
    if iPlot == 1
        for iAnn = 1:length(country)
            x = find(~isnan(aligned(:,order(iAnn))),1,'last');
            text(x,aligned(x,order(iAnn)),country{order(iAnn)},...
                'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
        end
        title({'Deaths per million, realigned'})
    else
        ymax = median(nanmax(aligned))*1.1;
        ylim([0 ymax])
        for iAnn = 1:length(country)
            x = find(~isnan(aligned(:,order(iAnn))),1,'last');
            if aligned(x,order(iAnn)) > ymax
                x = find(aligned(:,order(iAnn)) < ymax,1,'last')
            end
            y = aligned(x,order(iAnn));
            text(x,y,country{order(iAnn)},...
                'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
        end
        title({'Deaths per million, realigned (zoomed-in)'})
    end
     set(gca,'FontSize',11)
end
%% save
saveas(fig2,['archive/realigned_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
saveas(fig2,'docs/realigned.png')
% subplot(2,1,2)
% maxy = 50;
% plot(aligned(:,order),'linewidth',1,'marker','.');
% hold on
% plot(aligned(:,iMy),'linewidth',1.5,'marker','.');
% for iAnn = 1:length(country)
%     x = find(~isnan(aligned(:,order(iAnn))),1,'last');
%     if aligned(x,order(iAnn)) < maxy
%         text(x,aligned(x,order(iAnn)),country{order(iAnn)});
%     end
% end
% disp('done')
% xlim([0 find(~any(~isnan(aligned),2),1)+5])
% ylim([0 maxy])
% box off
% grid on
% ylabel('Deaths per million')
% xlabel('Days from country day zero (day zero = 1 death per million)')
% title({'Deaths per million, alligned (zoomed in)','time zero set to 1 death per million'})
% set(gcf,'Color',[0.8 0.95 1])
% set(gca,'XTick',iXtick,'XTickLabel',iXtick)


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