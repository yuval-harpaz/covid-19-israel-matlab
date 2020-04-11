% plot 20 most active countries
cd ~/covid-19_data_analysis/
myCountry = 'Israel';
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
[~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
[~, iworst] = sort(cellfun(@max, mergedData(:,2))./pop.Population_2020_(idx),'descend');

country = mergedData(iworst(1:nCountries),1);
iMy = find(ismember(country,myCountry));
if ~isempty(iMy)
    country(iMy) = [];
end
country{end} = myCountry;
cases = nan(length(timeVector),nCountries);
for iCou = 1:length(country)
    cases(1:length(timeVector),iCou) = mergedData{ismember(mergedData(:,1),country{iCou}),2};
end
[isx,idxc] = ismember(country,pop.Country_orDependency_);
if any(isx == 0)
    country(~ismember(country,pop.Country_orDependency_))
    error('missing country')
end
mil = pop.Population_2020_(idxc)/10^6;
norm = cases./mil';
% figure;
% plot(norm)
% 
% aligned = nan(size(norm));
% for iState = 1:nCountries
%     start = find(norm(:,iState) > zer,1);
%     aligned(1:size(norm,1)-start+1,iState) = norm(start:end,iState);
% end
% [~,order] = sort(nanmax(norm),'descend');
%% plot bars

[y, iy] = sort(cellfun(@max, mergedData(:,2)),'descend');
KOMP = mergedData(iy,1);
[~,isMy] = ismember(myCountry,mergedData(:,1));
isMy = iy == isMy;
yLog = log10(y);
yLog(yLog <= 0.1) = 0.1;
yt = 1:floor(max(yLog));
yLogNan = yLog;
yLogNan(~isMy) = nan;
yNan = y;
yNan(~isMy) = nan;


fig4 = figure('units','normalized','position',[0,0,1,1]);
subplot(3,1,1)
h1 = bar(y);
hold on
h2 = bar(yNan,'r')
plot(find(isMy),yNan(isMy),'or','MarkerSize',10)
set(gca,'YTick',10.^yt(2:end),'YTickLabel',10.^yt(2:end),'ygrid','on','XTickLabel',[],'FontSize',13)
legend([h1(1),h2(1)],'העולם','ישראל')
title('מספר מתים למדינה')
ylim([0 max(y)*1.05])
ylabel('מתים')
box off

subplot(3,1,2)
bar(yLog)
hold on
bar(yLogNan,'r')
set(gca,'YTick',[0.1,yt],'YTickLabel',[0,10.^yt],'ygrid','on','XTickLabel',[],'FontSize',13)
title('מספר מתים למדינה (סולם לוגריתמי)')
ylim([0 max(yLog)*1.05])
ylabel('מתים')
box off


[y, iy] = sort(cellfun(@max, mergedData(:,2))./pop.Population_2020_(idx)*10^6,'descend');
KOMP(:,2) = mergedData(iy,1);
[~,isMy] = ismember(myCountry,mergedData(:,1));
isMy = iy == isMy;
yLog = log10(y);
yLog(yLog <= 0.1) = 0.1;
yt = 1:floor(max(yLog));
yLogNan = yLog;
yLogNan(~isMy) = nan;
subplot(3,1,3)
bar(yLog);
hold on
bar(yLogNan,'r')
set(gca,'YTick',[0.1,yt],'YTickLabel',[0,10.^yt],'ygrid','on','XTickLabel',[],'FontSize',13)
ylabel('מתים למליון')
ylim([0 max(yLog)*1.05])
title('מתים למליון (סולם לוגריתמי)');
box off
%% align

aligned = nan(length(timeVector),length(mergedData));
for iState = 1:size(aligned,2)
    [~,idx1] = ismember(mergedData(iState,1),pop.Country_orDependency_);
    nrm = mergedData{iState,2}./pop.Population_2020_(idx1)*10^6;
    start = find(nrm > zer,1);
    if ~isempty(start)
        aligned(1:size(aligned,1)-start+1,iState) = nrm(start:end);
    end
end
iCol = find(ismember(mergedData(:,1),myCountry));
tMy = find(isnan(aligned(:,iCol)),1)-1;
farther = find(~isnan(aligned(tMy,:)));
yT = aligned(tMy,farther);
yMy = aligned(tMy,iCol);
[yTo,order] = sort(yT,'descend');
yToNan = yTo;
yToNan(yTo ~= yMy) = nan;
figure;
bar(yTo)
hold on
bar(yToNan,'r')
cou = mergedData(farther(order));
set(gca,'XTick',1:length(yTo),'XTickLabel',cou,'ygrid','on')
xtickangle(90)
box off
% [~,order] = sort(nanmax(nrm),'descend');
%% plot lines
fig4 = figure('units','normalized','position',[0,0,0.5,1]);
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
% saveas(fig4,['archive/realigned_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
% saveas(fig4,'docs/realigned.png')
% 
