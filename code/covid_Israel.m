function covid_Israel(saveFigs)
% plot 20 most active countries
if ~exist('saveFigs','var')
    saveFigs = false;
end
cd ~/covid-19_data_analysis/
myCountry = 'Israel';
nCountries = 20;
showDateEvery = 7; % days
zer = 1; % how many deaths per million to count as day zero
warning off
disp('Reading tables...')
type = 'deaths';
[dataMatrix] = readCoronaData(type);
[~,timeVector,mergedData] = processCoronaData(dataMatrix);
for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
iXtick = [1,showDateEvery:showDateEvery:length(timeVector)];
pop = readtable('data/population.csv','delimiter',',');
list = readtable('data/Israel/Israel_ministry_of_health.csv');
% Vent = list.on_ventilator;
% Deceased = list.deceased;
% Critical = list.severe;
% Date = list.date;
% isr = table(Date,Deceased,Vent,Critical);
%% plot israel only
desiredDates = fliplr(dateshift(list.date(end),'end','day'):-7:dateshift(list.date(1),'end','day'));
for iD = 1:length(desiredDates)
    ixt(iD,1) = find(list.date < desiredDates(iD),1,'last'); %#ok<AGROW>
end
% ixt = unique([1,fliplr(length(isr.Date):-showDateEvery:1)]);
fig8 = figure('units','normalized','position',[0,0.25,0.8,0.6]);
subplot(1,2,1)
idx = ~isnan(list.hospitalized);
plot(list.date(idx),list.hospitalized(idx),'color',[0.9 0.9 0.1],'linewidth',1);
hold on
plot(list.date(idx),list.hospitalized(idx)-list.critical(idx)-list.severe(idx),...
    'color',[0 1 0],'linewidth',1);
idx = ~isnan(list.severe);
plot(list.date(idx),list.severe(idx),'color',[0.7 0.7 0.3],'linewidth',1);
idx = ~isnan(list.critical);
plot(list.date(idx),list.critical(idx),'b','linewidth',1);
idx = ~isnan(list.on_ventilator);
plot(list.date(idx),list.on_ventilator(idx),'r','linewidth',1);
idx = ~isnan(list.deceased);
plot(list.date(idx),list.deceased(idx),'k','linewidth',1);

set(gca,'XTick',dateshift(list.date(ixt),'start','day'),'FontSize',13)
xlim([list.date(1)-1 list.date(end)+1])
% xtickangle(45)
grid on
box off
legend('מאושפזים','קל','בינוני','קשה','מונשמים','נפטרים','location','northeast')
ylabel('מספר החולים')
title(['המצב בבתי החולים עד ה- ',datestr(list.date(end),'dd/mm hh:MM')])
xtickangle(30)

subplot(1,2,2)
crit = movmean(list.critical,7,'omitnan');
hosp = movmean(list.hospitalized,7,'omitnan');
seve = movmean(list.severe,7,'omitnan');
mild = hosp-crit-seve;
vent = movmean(list.on_ventilator,7,'omitnan');

fill([list.date;flipud(list.date)],[crit+seve+mild;flipud(crit+seve)],[0.9 0.9 0.9],'LineStyle','none')
hold on
fill([list.date;flipud(list.date)],[crit+seve;flipud(crit)],[0.7 0.7 0.7],'LineStyle','none')
fill([list.date;flipud(list.date)],[crit;zeros(size(crit))],[0.5 0.5 0.5],'LineStyle','none')
fill([list.date;flipud(list.date)],[vent;zeros(size(crit))],[0.3 0.3 0.3],'LineStyle','none')
plot(list.date,list.deceased,'k')
legend('mild                קל','severe          בינוני','critical          קשה',...
    'on vent    מונשמים','deceased  נפטרים','location','northeast')
box off
xTick = fliplr(dateshift(list.date(end),'start','day'):-7:list.date(1));
set(gca,'XTick',xTick,'fontsize',13,'YTick',100:100:max(hosp))
xtickangle(30)
grid on
xlim([list.date(1) list.date(end)])
title('Hospitalized by severity מאושפזים לפי חומרה')
%%
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
    %country(~ismember(country,pop.Country_orDependency_));
    error('missing country')
end
mil = pop.Population_2020_(idxc)/10^6;
norm = cases./mil';

%% plot bars

[y, iy] = sort(cellfun(@max, mergedData(:,2)),'descend');
%KOMP = mergedData(iy,1);
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
h2 = bar(yNan,'r');
plot(find(isMy),yNan(isMy),'or','MarkerSize',10)
set(gca,'YTick',10.^yt(2:end),'YTickLabel',10.^yt(2:end),'ygrid','on','XTickLabel',[],'FontSize',13)
legend([h1(1),h2(1)],'העולם','ישראל')
title(['מספר מתים למדינה',',',' ישראל במקום ה ',str(find(isMy))])
ylim([0 max(y)*1.05])
ylabel('מתים')
box off
text(2,y(1)*1.05,[mergedData{iy(1),1},' - ',str(y(1))],'FontSize',12)

subplot(3,1,2)
bar(yLog)
hold on
bar(yLogNan,'r')
set(gca,'YTick',[0.1,yt],'YTickLabel',[0,10.^yt],'ygrid','on','XTickLabel',[],'FontSize',13)
title('מספר מתים למדינה (אותם הנתונים בסולם לוגריתמי)')
ylim([0 max(yLog)*1.05])
ylabel('מתים')
box off
text(2,yLog(1)*1.05,[mergedData{iy(1),1},' - ',str(y(1))],'FontSize',12)

[y, iy] = sort(cellfun(@max, mergedData(:,2))./pop.Population_2020_(idx)*10^6,'descend');
%KOMP(:,2) = mergedData(iy,1);
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
title(['מתים למליון (סולם לוגריתמי)',',',' ישראל במקום ה ',str(find(isMy))])
box
text(2,yLog(1)*1.05,[mergedData{iy(1),1},' - ',str(round(y(1)))],'FontSize',12)
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
fig5 = figure('units','normalized','position',[0,0.25,1,0.7]);
bar(yTo)
hold on
bar(yToNan,'r')
cou = mergedData(farther(order));
set(gca,'XTick',1:length(yTo),'XTickLabel',cou,'ygrid','on')
xtickangle(90)
box off
title({'מצב המדינות שהיו במקום של ישראל היום',[str(tMy), ' יום מנפטר אחד למליון']})
ylabel('מתים למליון')
set(gca,'FontSize',13)
% [~,order] = sort(nanmax(nrm),'descend');
%% plot lines
fig6 = figure('units','normalized','position',[0,0,0.5,1]);
annot = [20;length(farther)];
[yo,order] = sort(max(aligned(:,farther)),'descend');
yl = 1.05*yo([1,annot(1)]);
for iPlot = 1:2
    subplot(2,1,iPlot)
    h = plot(aligned(:,farther(order)),'linewidth',1,'marker','.','MarkerSize',8);
    xl = find(~any(~isnan(aligned),2),1)-14;
    xlim([0 xl])
    box off
    grid on
    ylabel('מתים למליון')
    xlabel('מספר ימים מיום האפס של כל מדינה (מת אחד למליון)')
    set(gca,'XTick',iXtick,'XTickLabel',iXtick)
    ylim([0 yl(iPlot)])
    if iPlot == 1
        jj = 1:annot(iPlot);
        title({'מתים למליון, מיושר'})
    else
        jj = annot(1):annot(2);
        title({'מתים למליון, מיושר (זום-אין)'})
    end
    for iAnn = jj
        x = find(~isnan(aligned(:,farther(order(iAnn)))),1,'last');
        text(x,yo(iAnn),mergedData{farther(order(iAnn)),1},...
            'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
    end
    iChina = find(ismember(mergedData(:,1),'China'));
    text(xl,max(aligned(:,iChina)),'China',...
        'FontSize',10,'Color',h(find(farther == iChina)).Color,'FontWeight','bold');
    hold on
    plot(aligned(:,iCol),'k','linewidth',2,'marker','.','MarkerSize',12)
    text(tMy,yMy,myCountry,'color','k','FontSize',16,'FontWeight','bold'); % 'BackgroundColor','y'
    set(gca,'FontSize',11)
end

%% save
if saveFigs
    % saveas(fig6,['archive/realignedMyCountry_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
    saveas(fig6,'docs/realignedMyCountry.png')
    % saveas(fig5,['archive/realignedTodayMyCountry_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
    saveas(fig5,'docs/realignedTodayMyCountry.png')
    % saveas(fig4,['archive/barsMyCountry_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
    saveas(fig4,'docs/barsMyCountry.png')
    % saveas(fig8,['archive/myCountry_',datestr(vent.date(end),'dd_mm_yyyy'),'.png'])
    saveas(fig8,'docs/myCountry.png')
end
%%
covid_israel_timna_hosp;


