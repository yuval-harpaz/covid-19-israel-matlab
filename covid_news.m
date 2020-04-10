% % plot 30 largest countries + Israel
% alwaysShow = {'China','Korea, South','Japan','Singapore','Israel'};
%  %'largest' 'most_deaths' 'most_deaths_daily' 'most_deaths_norm' 'most_deaths_daily_norm'
%   method = 'most_deaths_norm';      
%         
% nCountries = 31;
% 
% zer = 1; % how many deaths per million to count as day zero
nCountries = 10;
showDateEvery = 7; % days
warning off
disp('Reading tables...')
pop = readtable('population.csv','delimiter',',');

type = 'deaths';
[dataMatrix] = readCoronaData(type);
[dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);
for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
warning on
mergedData(~ismember(mergedData(:,1),pop.Country_orDependency_),:) = [];
% plotCoronaData(timeVector,mergedData,{alwaysShow,'US','Germany','China'},type);
%covid = readtable('covid.csv');


deaths = nan(length(timeVector),length(mergedData));
for iCou = 1:length(mergedData)
    deaths(1:length(timeVector),iCou) = mergedData{iCou,2};
end
%%
[~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
mil = pop.Population_2020_(idx)'/10^6;
stillZero = mergedData(deaths(end,:) == 0,1);
newDeaths = mergedData(deaths(end-1,:) == 0 & deaths(end,:) > 0,1);
newDeathPerMil = mergedData(deaths(end-1,:)./mil < 1 & deaths(end,:)./mil >= 1,1);
order = cell(4,1);
y = nan(length(timeVector),nCountries,4);
[~,order{1}] = sort(deaths(end,:),'descend'); % most deaths
%titles{1,1} = 'Deaths';
y(1:size(deaths,1),1:nCountries,1) = deaths(:,order{1}(1:nCountries));
[~,order{2}] = sort(deaths(end,:)./mil,'descend'); % most deaths per million
%titles{2,1} = 'Deaths per million';
y(1:size(deaths,1),1:nCountries,2) = deaths(:,order{2}(1:nCountries))...
    ./mil(order{2}(1:nCountries));
[~,order{3}] = sort(deaths(end,:)-deaths(end-1,:),'descend'); % largest increase
%titles{3,1} = 'Daily deaths';
y(1:size(deaths,1),1:nCountries,3) = [zeros(1,nCountries);diff(deaths(:,order{3}(1:nCountries)))];
[~,order{4}] = sort(deaths(end,:)./mil-deaths(end-1,:)./mil,'descend'); % largest increase per million
%titles{4,1} = 'Daily deaths per million';
y(1:size(deaths,1),1:nCountries,4) = [zeros(1,nCountries);...
    diff(deaths(:,order{4}(1:nCountries))./mil(order{4}(1:nCountries)))];
iXtick = fliplr(length(timeVector):-showDateEvery:1);
%% plot
figure('units','normalized','position',[0,0,1,1])
for iPlot = 1:4
    subplot(2,2,iPlot)
    h = plot(y(:,:,iPlot),'linewidth',1.5,'marker','.');
    ax = ancestor(h, 'axes');
    ax{1}.YAxis.Exponent = 0;
    % ann = [order(1:9);nCountries];
    for iAnn = 1:nCountries
        %     if nanmax(aligned(:,iAnn)) > 1
        x = size(deaths,1);
        txt = text(x,y(end,iAnn,iPlot),mergedData{order{iPlot}(iAnn)},...
            'Color',h(iAnn).Color);
        %     end
    end
    xlim([0 size(deaths,1)+20])
    box off
    grid on
    
    xlabel('Weeks')
    % title(['Deaths up to ',datestr(timeVector(end))])
    set(gca,'XTick',iXtick,'XTickLabel',datestr(timeVector(iXtick),'dd.mm'))
    xlim([42 length(timeVector)])
    %title(titles{iPlot});
    switch iPlot
        case 1
            title('Deaths')
            ylabel('Deaths')
        case 2
            title('Deaths per million')
            ylabel('Deaths per million')
            ymax = sort(y(end,:,iPlot));
            ymax = ymax(end-1)*1.1;
            ylim([0 ymax])
            text(x,ymax,[mergedData{order{iPlot}(1)},' (',str(round(y(end,1,iPlot))),')'],...
                'Color',h(1).Color);
        case 3
            title('Daily deaths')
            ylabel('Deaths')
        case 4
            title('Daily deaths per million')
            ymax = max(y(end,:,iPlot))*1.1;
            ylim([0 ymax])
            ylabel('Deaths per million')
    end
    ytickformat('%,d')
end


%% old

% 
% switch method % which nCOuntries to take
%     case 'most_deaths_daily' % worst yesterday
%         lastDay = cellfun(@(x) x(end)-x(end-1), mergedData(:,2));
%         [~, iworst] = sort(lastDay,'descend');
%         country = mergedData(iworst(1:nCountries),1);
%     case 'most_deaths'
%         [~, iworst] = sort(cellfun(@max, mergedData(:,2)),'descend');
%         country = mergedData(iworst(1:nCountries),1);
%     case 'largest' % most populus countries
%         country = pop.Country_orDependency_(1:nCountries);
%     case 'most_deaths_norm' % most deatsh per million
%         [~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
%         [~, iworst] = sort(cellfun(@max, mergedData(:,2))./pop.Population_2020_(idx),'descend');
%         country = mergedData(iworst(1:nCountries),1);
%     case 'most_deaths_daily_norm' % worst yesterday per million
%         [~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
%         lastDay = cellfun(@(x) x(end)-x(end-1), mergedData(:,2));
%         [~, iworst] = sort(lastDay./pop.Population_2020_(idx),'descend');
%         country = mergedData(iworst(1:nCountries),1);
%         
% end
% 
% 
% 
% leftOut = alwaysShow(~ismember(alwaysShow,country));
% if ~isempty(leftOut)
%     country(end-length(leftOut)+1:end) = leftOut;
% end
% % ismember(country,mergedData(:,1))
% 
% 
% norm = cases./mil';
% % figure;
% % plot(norm)
% 
% aligned = nan(size(norm));
% for iState = 1:nCountries
%     start = find(norm(:,iState) > zer,1);
%     aligned(1:size(norm,1)-start+1,iState) = norm(start:end,iState);
% end
% 
% % selected = ismember(country,{alwaysShow,'Italy','Spain','France','United Kingdom','Iran','Germany','China','Korea, South','US'});
% % iSel = find(selected);
% [~,order] = sort(nanmax(norm),'descend');
% iMy = find(ismember(country,alwaysShow));
% if any(norm(end,iMy) < zer)
%     warning(['countries with less than ',num2str(zer),' deaths per million will not be visible:']) 
%     disp(alwaysShow(norm(end,iMy) < zer));
% end
% %% plot
% figure;
% subplot(2,2,1)
% plot(cases(:,order),'linewidth',1,'marker','.');
% hold on
% plot(cases(:,iMy),'linewidth',1.5,'marker','.');
% % ann = [order(1:9);nCountries];
% for iAnn = 1:nCountries
% %     if nanmax(aligned(:,iAnn)) > 1
%     x = size(cases,1);
%     text(x,cases(x,iAnn),country{iAnn});
% %     end
% end
% xlim([0 size(cases,1)+20])
% box off
% grid on
% ylabel('Deaths')
% xlabel(['Days from ',datestr(timeVector(1))])
% title(['Deaths up to ',datestr(timeVector(end))])
% set(gca,'XTick',iXtick,'XTickLabel',datestr(timeVector(iXtick),'dd.mm'))
% %plot(cases(:,iSel(order)),'linestyle','none','marker','.');
% subplot(2,2,2)
% plot(aligned(:,order),'linewidth',1,'marker','.');
% hold on
% plot(aligned(:,iMy),'linewidth',1.5,'marker','.');
% for iAnn = 1:length(country)
%     x = find(~isnan(aligned(:,order(iAnn))),1,'last');
%     text(x,aligned(x,order(iAnn)),country{order(iAnn)});
% end
% 
% xlim([0 find(~any(~isnan(aligned),2),1)+5])
% box off
% grid on
% ylabel('Deaths per million')
% xlabel('Days from country day zero (day zero = 1 death per million)')
% title({'Deaths per million, alligned','time zero set to 1 death per million'})
% set(gca,'XTick',iXtick,'XTickLabel',iXtick)
% subplot(2,2,3)
% y = diff(cases(:,order));
% plot(y,'linewidth',1,'marker','.');
% hold on
% plot(y(:,iMy),'linewidth',1.5,'marker','.');
% for iAnn = 1:length(country)
%     x = size(y,1);
%     text(x,y(x,iAnn),country{order(iAnn)});
% end
% xlim([0 size(cases,1)+20])
% box off
% grid on
% ylabel('Deaths')
% xlabel(['Days from ',datestr(timeVector(1))])
% title(['Daily deaths up to ',datestr(timeVector(end))])
% set(gca,'XTick',iXtick,'XTickLabel',datestr(timeVector(iXtick),'dd.mm'))
% 
% subplot(2,2,4)
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
% 
% % 
% % pop.Country_orDependency_(ismember(pop.Country_orDependency_,'United States')) = {'US'};
% % pop.Country_orDependency_(ismember(pop.Country_orDependency_,'South Korea')) = {'Korea, South'};
% % pop.Country_orDependency_(ismember(pop.Country_orDependency_,'DR Congo')) = {'Congo (Kinshasa)'};
% % pop.Country_orDependency_(ismember(pop.Country_orDependency_,'Congo')) = {'Congo (Brazzaville)'};
% % pop.Country_orDependency_(ismember(pop.Country_orDependency_,'Myanmar')) = {'Burma'};
% % pop.Country_orDependency_(ismember(pop.Country_orDependency_,'Czech Republic (Czechia)')) = {'Czechia'};
% % pop.Country_orDependency_(ismember(pop.Country_orDependency_,'Taiwan')) = {'Taiwan*'};
% % pop.Country_orDependency_(ismember(pop.Country_orDependency_,'State of Palestine')) = {'West Bank and Gaza'};
% % pop.Country_orDependency_(contains(pop.Country_orDependency_,'voi')) = {['Cote d''','Ivoire']};
% % pop(~ismember(pop.Country_orDependency_,mergedData(:,1)),:) = [];
% % pop = pop(:,[2,3,6]);
% % pop.Country_orDependency_{end+1,1} = 'Kosovo';
% % pop.Population_2020_(end) = 1831463;
% % pop.Density_P_Km__(end) = 159;
% % writetable(pop,'population.csv','Delimiter',',','WriteVariableNames',true);