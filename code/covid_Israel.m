function covid_Israel(saveFigs,listName)
% plot 20 most active countries
if ~exist('saveFigs','var')
    saveFigs = false;
end
if ~exist('listName','var')
    %listName = 'data/Israel/Israel_ministry_of_health.csv';
    listName = 'data/Israel/dashboard_timeseries.csv';
end
cd ~/covid-19-israel-matlab/
myCountry = 'Israel';
nCountries = 20;

[dataMatrix] = readCoronaData('deaths');
[~,timeVector,mergedData] = processCoronaData(dataMatrix);
fig = covid_plot(mergedData,timeVector,nCountries,'d',1,myCountry);

showDateEvery = 7; % days
zer = 1; % how many deaths per million to count as day zero
warning off

for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
iXtick = [1,showDateEvery:showDateEvery:length(timeVector)];
pop = readtable('data/population.csv','delimiter',',');
list = readtable(listName);
if contains(listName,'dashboard_timeseries')
    list.Properties.VariableNames([7,9:12]) = {'hospitalized','critical','severe','mild','on_ventilator'};
    list.deceased = nan(height(list),1);
    list.deceased(~isnan(list.CountDeath)) = cumsum(list.CountDeath(~isnan(list.CountDeath)));
    i1 = find(~isnan(list.hospitalized),1);
    list = list(i1:end,:);
    fid = fopen('data/Israel/dashboard.json','r');
    txt = fread(fid)';
    fclose(fid);
    txt = native2unicode(txt);
    json = jsondecode(txt);
    list.date(end) = datetime([json(1).data.lastUpdate(1:10),' ',json(1).data.lastUpdate(12:16)])+3/24;
end

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
ylim([0 max(list.hospitalized)+20])
% xtickangle(45)
grid on
box off
legHeb = {'מאושפזים','קל','בינוני','קשה','מונשמים','נפטרים'};
iLast = find(idx,1,'last');
legNum = {str(list.hospitalized(iLast)),...
    str(list.hospitalized(iLast)-list.critical(iLast)-list.severe(iLast)),...
    str(list.severe(iLast)),...
    str(list.critical(iLast)),...
    str(list.on_ventilator(iLast)),...
    str(list.deceased(iLast))};
legend([legHeb{1},' (',legNum{1},')'],[legHeb{2},' (',legNum{2},')'],[legHeb{3},' (',legNum{3},')'],...
    [legHeb{4},' (',legNum{4},')'],[legHeb{5},' (',legNum{5},')'],[legHeb{6},' (',legNum{6},')'],'location','north')
ylabel('מספר החולים')
title(['המצב בבתי החולים עד ה- ',datestr(list.date(end),'dd/mm hh:MM')])
xtickangle(90)

yy = list.critical;
y = movmean(yy,7,'omitnan');
y(end-1:end) = yy(end-1:end);
y(end-2) = mean(yy(end-3:end-1));
y(end-3) = mean(yy(end-5:end-1));
crit = y;
yy = list.hospitalized;
y = movmean(yy,7,'omitnan');
y(end-1:end) = yy(end-1:end);
y(end-2) = mean(yy(end-3:end-1));
y(end-3) = mean(yy(end-5:end-1));
hosp = y;
yy = list.severe;
y = movmean(yy,7,'omitnan');
y(end-1:end) = yy(end-1:end);
y(end-2) = mean(yy(end-3:end-1));
y(end-3) = mean(yy(end-5:end-1));
seve = y;
mild = hosp-crit-seve;
yy = list.on_ventilator;
y = movmean(yy,7,'omitnan');
y(end-1:end) = yy(end-1:end);
y(end-2) = mean(yy(end-3:end-1));
y(end-3) = mean(yy(end-5:end-1));
vent = y;
subplot(1,2,2)
fill([list.date;flipud(list.date)],[crit+seve+mild;flipud(crit+seve)],[0.9 0.9 0.9],'LineStyle','none')
hold on
fill([list.date;flipud(list.date)],[crit+seve;flipud(crit)],[0.7 0.7 0.7],'LineStyle','none')
fill([list.date;flipud(list.date)],[crit;zeros(size(crit))],[0.5 0.5 0.5],'LineStyle','none')
fill([list.date;flipud(list.date)],[vent;zeros(size(crit))],[0.3 0.3 0.3],'LineStyle','none')
plot(list.date,list.deceased,'k')
legend('mild                קל','severe          בינוני','critical          קשה',...
    'on vent    מונשמים','deceased  נפטרים','location','north')
box off
xTick = fliplr(dateshift(list.date(end),'start','day'):-7:list.date(1));
set(gca,'XTick',xTick,'fontsize',13,'YTick',100:100:max(list.hospitalized)+20)
xtickangle(90)
grid on
xlim([list.date(1) list.date(end)])
ylim([0 max(list.hospitalized)+20])
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
    error('missing country')
end
mil = pop.Population_2020_(idxc)/10^6;
norm = cases./mil'; %#ok<NASGU>

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
[yTo,order] = sort(yT,'descend'); %#ok<ASGLU>
yToNan = yTo;
yToNan(yTo ~= yMy) = nan; %#ok<NASGU>

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
        'FontSize',10,'Color',h(find(farther == iChina)).Color,'FontWeight','bold'); %#ok<FNDSB>
    hold on
    plot(aligned(:,iCol),'k','linewidth',2,'marker','.','MarkerSize',12)
    text(tMy,yMy,myCountry,'color','k','FontSize',16,'FontWeight','bold'); % 'BackgroundColor','y'
    set(gca,'FontSize',11)
end

%% save
if saveFigs
    saveas(fig6,'docs/realignedMyCountry.png')
    saveas(fig8,'docs/myCountry.png')
end
%%
covid_israel_percent_positive(saveFigs);


