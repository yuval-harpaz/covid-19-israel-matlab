function covid_Israel(figs)
% plot 20 most active countries
if ~exist('figs','var')
    figs = false;
end
%listName = 'data/Israel/Israel_ministry_of_health.csv';
listName = 'data/Israel/dashboard_timeseries.csv';
cd ~/covid-19-israel-matlab/
myCountry = 'Israel';
nCountries = 20;

% [dataMatrix] = readCoronaData('deaths');
% [~,timeVector,mergedData] = processCoronaData(dataMatrix);
% fig6 = covid_plot(mergedData,timeVector,nCountries,'dpm',1,myCountry);
% fig7 = covid_plot(mergedData,timeVector,nCountries,'ddpm',7,myCountry,10);
try
    fig7 = covid_plot_who;
    fig6 = covid_plot_who(1,1,1);
catch
    disp('no WHO, try later')
end
% showDateEvery = 7; % days
% zer = 1; % how many deaths per million to count as day zero
% warning off
% 
% for iCou = 1:length(mergedData)
%     mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
%     mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
% end
% iXtick = [1,showDateEvery:showDateEvery:length(timeVector)];
% pop = readtable('data/population.csv','delimiter',',');
list = readtable(listName);

list.Properties.VariableNames([7,9:12]) = {'hospitalized','critical','severe','mild','on_ventilator'};
list.deceased = nan(height(list),1);
%     list.deceased(~isnan(list.CountDeath)) = cumsum(list.CountDeath(~isnan(list.CountDeath)));
list.deceased =list.CountDeath;
i1 = find(~isnan(list.hospitalized),1);
list = list(i1:end,:);
fid = fopen('data/Israel/dashboard.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
json = jsondecode(txt);
% list.date(end) = datetime([json(1).data.lastUpdate(1:10),' ',json(1).data.lastUpdate(12:16)])+2/24;
listE = list;
list = listE(1:end-1,:);

%% plot israel only
% desiredDates = fliplr(dateshift(list.date(end),'end','day'):-7:dateshift(list.date(1),'end','day'));
% for iD = 1:length(desiredDates)
%     ixt(iD,1) = find(list.date < desiredDates(iD),1,'last'); %#ok<AGROW>
% end
% ixt = unique([1,fliplr(length(isr.Date):-showDateEvery:1)]);
fig8 = figure('units','normalized','position',[0,0.25,0.8,0.6]);
subplot(1,2,1)
yyaxis right
idx = ~isnan(list.hospitalized);
% plot(list.date(idx),list.hospitalized(idx),'color',[0.9 0.9 0.1],'linewidth',1);
hh(1) = plot(list.date(idx),list.hospitalized(idx)-list.critical(idx)-list.severe(idx),...
    'color',[0 1 0],'linewidth',1);
hold on
idx = ~isnan(list.severe);
hh(2) = plot(list.date(idx),list.severe(idx),'b','linewidth',1,'linestyle','-');
idx = ~isnan(list.critical);
hh(3) = plot(list.date(idx),list.critical(idx),'color',[0.7 0 0.7],'linewidth',1,'linestyle','-');
idx = ~isnan(list.on_ventilator);
hh(4) = plot(list.date(idx),list.on_ventilator(idx),'r','linewidth',1,'linestyle','-');
idx = ~isnan(list.deceased);
deceased = movmean(list.deceased(idx(1:end-1)),[3 3],'omitnan');
ylim([0 1000])
ylabel('חולים')
yyaxis left
hh(5) = plot(list.date(idx(1:end-1)),deceased,'k','linewidth',1);
ylim([0 100])
set(gca,'FontSize',13)
xlim([list.date(1)-1 list.date(end)+1])
ax = gca;
ax.YAxis(2).Color = 'r';
ax.YAxis(1).Color = 'k';
% ylim([0 max(list.hospitalized)+20])
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
    str(round(deceased(end)))};
legend(hh,[legHeb{2},' (',legNum{2},')'],[legHeb{3},' (',legNum{3},')'],...
    [legHeb{4},' (',legNum{4},')'],[legHeb{5},' (',legNum{5},')'],[legHeb{6},' (',legNum{6},')'],'location','north')
ylabel('נפטרים')
title({['המצב בבתי החולים עד ה- ',datestr(list.date(end),'dd/mm')],...
    ['נפטרו במצטבר ',str(nansum(list.deceased)),', הנפטרים בגרף לפי ממוצע נע']})
xtickangle(30)

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
fill([list.date;flipud(list.date)],[list.deceased;zeros(height(list),1)],[0,0,0],'LineStyle','none')
legend('mild                קל','severe          בינוני','critical          קשה',...
    'on vent    מונשמים','deceased  נפטרים','location','north')
box off
% xTick = fliplr(dateshift(list.date(end),'start','day'):-7:list.date(1));
set(gca,'fontsize',13,'YTick',100:100:max(list.hospitalized)+20)
xtickangle(30)
grid on
xlim([list.date(1) list.date(end)])
ylim([0 max(list.hospitalized)+20])
title({'מאושפזים לפי חומרה במצטבר','הקו העליון מציין את סך הכל מאושפזים'})
ylabel('חולים')
set(gcf,'Color','w')
%% save
if figs == 1
    if exist('fig6','var')
        saveas(fig6,'docs/dpmMyCountry.png')
        saveas(fig7,'docs/ddpmMyCountry.png')
    end
    saveas(fig8,'docs/myCountry.png')
end
%%
covid_israel_percent_positive(figs);
%%
covid_death_list;

%%
newc = readtable('~/covid-19-israel-matlab/data/Israel/new_critical.csv');
ccc = [0,0.4470,0.7410;0.8500,0.3250,0.09800;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.07800,0.1840];
alf = 0.5;
figure;
subplot(1,2,1)
hh(9) = scatter(list.date(list.CountDeath > 0),list.CountDeath(list.CountDeath > 0),'k.','MarkerEdgeAlpha',alf);
hold on
hh(10) = plot(list.date(1:end-1),movmean(list.CountDeath(1:end-1),[3 3]),'k','linewidth',1.5);
hh(1) = scatter(list.date(2:end),diff(list.CountBreathCum(1:end)),'.','MarkerEdgeAlpha',alf);
hh(1).MarkerEdgeColor = ccc(1,:);
hh(2) = plot(list.date(2:end-1),movmean(diff(list.CountBreathCum(1:end-1)),[3 3]),'linewidth',1.5);
hh(2).Color = ccc(1,:);
% d = diff(list.CountSeriousCriticalCum);
% bad = find(diff(d) > 75);
% if length(bad) > 1
%     error('too many bad diffs')
% end
% d(bad+1) = mean(d([bad,bad+2]));
commonDate = datetime(2020,8,18):newc.date(end);
ser_crit = [0;diff(list.CountSeriousCriticalCum)];
ser_crit = ser_crit(ismember(list.date,commonDate));
crit = ser_crit - newc.new_critical(ismember(newc.date,commonDate));

hh(3) = scatter(commonDate,crit,'.','MarkerEdgeAlpha',alf);
hh(3).MarkerEdgeColor = ccc(2,:);
hh(4) = plot(commonDate,movmean(crit,[3 3]),'linewidth',1.5);
hh(4).Color = ccc(2,:);
hh(5) = scatter(newc.date,newc.new_critical,'.','MarkerEdgeAlpha',alf);
hh(5).MarkerEdgeColor = ccc(3,:);
hh(6) = plot(newc.date,movmean(newc.new_critical,[3 3]),'linewidth',1.5);
hh(6).Color = ccc(3,:);
hh(7) = scatter(list.date,list.new_hospitalized,'.','MarkerEdgeAlpha',alf);
hh(7).MarkerEdgeColor = ccc(4,:);
hh(8) = plot(list.date(1:end-1),movmean(list.new_hospitalized(1:end-1),[3 3]),'linewidth',1.5);
hh(8).Color = ccc(4,:);
if figs < 2
    legend(hh([8,6,4,2,10]),'מאושפזים','קשים','קריטיים','מונשמים','נפטרים','location','northwest')
    title('חולים חדשים')
else
    legend(hh([8,6,4,2,10]),'hospitalized','severe','critical','ventilated','deceased','location','northwest')
    title('New Patients')
end  
grid on
box off
set(gcf,'Color','w')
grid minor
set(gca,'fontsize',13)
ylim([0 275])
xlim([list.date(1) datetime('tomorrow')])
xtickformat('MMM')
subplot(1,2,2)
hh1(1) = scatter(listE.date,listE.on_ventilator,'.','MarkerEdgeAlpha',alf);
hold on
hh1(2) = plot(listE.date(1:end-1),movmean(listE.on_ventilator(1:end-1),[3 3]),'linewidth',1.5);
hh1(2).Color = ccc(1,:);
listE.CountCriticalStatus(1:find(listE.CountCriticalStatus > 10,1)-1) = nan;
hh1(3) = scatter(listE.date,listE.CountCriticalStatus,'.','MarkerEdgeAlpha',alf);
hh1(3).MarkerEdgeColor = ccc(2,:);
hh1(4) = plot(listE.date(1:end-1),movmean(listE.CountCriticalStatus(1:end-1),[3 3]),'linewidth',1.5);
hh1(4).Color = ccc(2,:);
hh1(5) = scatter(listE.date,listE.critical,'.','MarkerEdgeAlpha',alf);
hh1(5).MarkerEdgeColor = ccc(3,:);
hh1(6) = plot(listE.date(1:end-1),movmean(listE.critical(1:end-1),[3 3]),'linewidth',1.5);
hh1(6).Color = ccc(3,:);
hh1(7) = scatter(listE.date,listE.hospitalized,'.','MarkerEdgeAlpha',alf);
hh1(7).MarkerEdgeColor = ccc(4,:);
hh1(8) = plot(listE.date(1:end-1),movmean(listE.hospitalized(1:end-1),[3 3]),'linewidth',1.5);
hh1(8).Color = ccc(4,:);
% legend(hh1([8,6,4,2]),'מאושפזים','קשים','קריטיים','מונשמים','location','northwest')
if figs < 2
    legend(hh1([8,6,4,2]),'מאושפזים','קשים','קריטיים','מונשמים','נפטרים','location','northwest')
    title('חולים')
else
    legend(hh1([8,6,4,2]),'hospitalized','severe','critical','ventilated','location','northwest')
    title('Patients')
end
grid on
box off
set(gcf,'Color','w')
set(gca,'fontsize',13)

grid minor
ylim([0 2000])
xlim([listE.date(1) datetime('tomorrow')])
xtickformat('MMM')
