% show the worst countries by different criteria
cd ~/covid-19_data_analysis/
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
deaths = nan(length(timeVector),length(mergedData));
for iCou = 1:length(mergedData)
    deaths(1:length(timeVector),iCou) = mergedData{iCou,2};
end
%%
[~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
mil = pop.Population_2020_(idx)'/10^6;
stillZero = mergedData(deaths(end,:) == 0,1);
newDeaths = mergedData(deaths(end-1,:) == 0 & deaths(end,:) > 0,1);
% newDeathPerMil = mergedData(deaths(end-1,:)./mil < 1 & deaths(end,:)./mil >= 1,1);
% deaths(end,:)./mil-deaths(end-1,:)./mil
newDeathPerMil = [zeros(1,length(mergedData));diff(deaths./mil)];
smallAll = find(mil < 1);
newDeathPerMil(:,smallAll) = movmean(newDeathPerMil(:,smallAll),5);

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
[~,order{4}] = sort(newDeathPerMil(end,:),'descend'); % largest increase per million
%titles{4,1} = 'Daily deaths per million';
y(1:size(deaths,1),1:nCountries,4) = newDeathPerMil(:,order{4}(1:nCountries));
%     diff(deaths(:,order{4}(1:nCountries))./mil(order{4}(1:nCountries)))];
iXtick = fliplr(length(timeVector):-showDateEvery:1);
%% plot
fig1 = figure('units','normalized','position',[0,0,1,1]);
for iPlot = 1:4
    small = find(mil(order{iPlot}(1:size(y,2))) < 1);
    subplot(2,2,iPlot)
    h = plot(y(:,:,iPlot),'linewidth',1,'marker','.','MarkerSize',8);
    ax = ancestor(h, 'axes');
    ax{1}.YAxis.Exponent = 0;
    xlim([0 size(deaths,1)+20])
    box off
    grid on
    xlabel('Weeks')
    set(gca,'XTick',iXtick,'XTickLabel',datestr(timeVector(iXtick),'dd.mm'))
    xlim([42 length(timeVector)])
    for iSmall = 1:length(small)
        h(small(iSmall)).LineStyle = ':';
    end
    switch iPlot
        case 1
            title('Deaths')
            ylabel('Deaths')
            ymax = max(y(end,:,iPlot))*1.1;
            yt = fliplr(ymax/nCountries:ymax/nCountries:ymax);
        case 2
            title('Deaths per million')
            ylabel('Deaths per million')
            ymax = sort(y(end,:,iPlot));
            ymax = ymax(end-1)*1.1;
            yt = fliplr(ymax/nCountries:ymax/nCountries:ymax);
            text(x,mean(yt(1:2)),str(round(max(max(y(:,:,iPlot))))),...
            'FontSize',10,'Color',h(1).Color,'FontWeight','bold');
        case 3
            title('Daily deaths')
            ylabel('Deaths')
            %ymax = max(max(y(:,:,iPlot)))*1.1;
            ymax = sort(y(end,:,iPlot));
            ymax = ymax(end)*1.5;
            yt = fliplr(ymax/nCountries:ymax/nCountries:ymax);
        case 4
            title('Daily deaths per million')
            ymax = max(y(end,:,iPlot))*1.5;
            yt = fliplr(ymax/nCountries:ymax/nCountries:ymax);
            ylabel('Deaths per million')
    end
    ylim([0 ymax])
    ytickformat('%,d')
    [~,yOrd] = sort(y(end,:,iPlot),'descend');
    for iAnn = 1:nCountries
        x = size(deaths,1);
        txt = text(x,yt(iAnn),mergedData{order{iPlot}(iAnn)},...
            'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
    end
    set(gca,'FontSize',11)
end
%% most active
fig3 = figure('units','normalized','position',[0,0,0.5,0.5]);
h = plot(y(:,:,iPlot),'linewidth',1,'marker','.','MarkerSize',8);
ax = ancestor(h, 'axes');
ax{1}.YAxis.Exponent = 0;
xlim([0 size(deaths,1)+20])
box off
grid on
xlabel('Weeks')
set(gca,'XTick',iXtick,'XTickLabel',datestr(timeVector(iXtick),'dd.mm'))
xlim([42 length(timeVector)])
title('Daily deaths per million')
ymax = max(y(end,:,iPlot))*1.5;
ylabel('Deaths per million')
ylim([0 ymax])
ytickformat('%,d')
yt = fliplr(ymax/nCountries:ymax/nCountries:ymax);
[~,yOrd] = sort(y(end,:,iPlot),'descend');
for iAnn = 1:nCountries
    x = size(deaths,1);
    txt = text(x,yt(iAnn),mergedData{order{iPlot}(iAnn)},...
        'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
end
set(gca,'FontSize',11)
for iSmall = 1:length(small)
    h(small(iSmall)).LineStyle = ':';
end
%%
saveas(fig3,'docs/active.png')
saveas(fig1,['archive/highest_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
saveas(fig1,'docs/highest.png')

