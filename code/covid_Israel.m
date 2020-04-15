function isr = covid_Israel
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
vent = readtable('Israel_ventilators.csv');
yest = datetime('yesterday');
if ~ismember(yest,vent.date)
    mako = urlread('https://corona.mako.co.il/');
    iBar = strfind(mako,'var _barGraphValues');
    mako = mako(iBar:end);
    iBrac{1} = strfind(mako,'[');
    iBrac{2} = strfind(mako,']');
    makoNum = str2num(mako(iBrac{1}(1)+1:iBrac{2}(1)-1));
    makoDateCell = regexp(mako(iBrac{1}(2)+1:iBrac{2}(2)-1),'\d*','match');
    makoDateCell = reshape(makoDateCell,2,length(makoDateCell)/2)';
    for ii = 1:length(makoDateCell)
        makoDate(ii,1) = datetime(str2num(datestr(datetime('today'),'yyyy')),... % year
            str2num(makoDateCell{ii,2}),str2num(makoDateCell{ii,1}));
    end
    error('ignore today')
    if ~ismember(yest,makoDate)
        error('yesterday isnt in Mako bar')
    end
    lastOkay = find(ismember(makoDate,vent.date),1,'last');
    h = height(vent);
    vent.vent_used(h+1:h+length(makoDate)-lastOkay) = makoNum(lastOkay+1:end);
    vent.date(h+1:h+length(makoDate)-lastOkay) = makoDate(lastOkay+1:end);
    writetable(vent,'Israel_ventilators.csv','delimiter',',','WriteVariableNames',true);
end
rutIdan = urlread('https://raw.githubusercontent.com/idandrd/israel-covid19-data/master/IsraelCOVID19.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,unicode2native(rutIdan));
fclose(fid);
ri = readtable('tmp.csv');
!rm tmp.csv
ri = ri(ismember(ri.x_Date,vent.date),:);
Date = vent.date;
Vent = vent.vent_used;
Deceased = ri.x_____Deceased;
Sever = ri.x___Severe;
isr = table(Date,Deceased,Vent,Sever);
%% plot israel only
ixt = unique([1,fliplr(length(vent.date):-showDateEvery:1)]);
fig8 = figure('units','normalized','position',[0,0.25,0.4,0.6]);
h1 = plot(vent.date,ri.x___Severe,'b','linewidth',1,'marker','.','MarkerSize',8);
hold on
h2 = plot(vent.date,vent.vent_used,'r','linewidth',1,'marker','.','MarkerSize',8);
h3 = plot(vent.date,ri.x_____Deceased,'k','linewidth',1,'marker','.','MarkerSize',8);
set(gca,'XTick',vent.date(ixt),'FontSize',13)
grid on
box off
legend('חולים במצב קשה','מונשמים','מתים','location','northwest')
ylabel('מספר החולים')
title(['מתים, מונשמים וחולים קשה עד ה ',datestr(vent.date(end),'dd.mm')])
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
h2 = bar(yNan,'r')
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
        jj = annot(1):annot(2)
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
saveas(fig6,['archive/realignedMyCountry_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
saveas(fig6,'docs/realignedMyCountry.png')
saveas(fig5,['archive/realignedTodayMyCountry_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
saveas(fig5,'docs/realignedTodayMyCountry.png')
saveas(fig4,['archive/barsMyCountry_',datestr(timeVector(end),'dd_mm_yyyy'),'.png'])
saveas(fig4,'docs/barsMyCountry.png')
saveas(fig8,['archive/myCountry_',datestr(vent.date(end),'dd_mm_yyyy'),'.png'])
saveas(fig8,'docs/myCountry.png')
%
