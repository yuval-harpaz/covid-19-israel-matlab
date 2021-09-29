function covid_Israel(figs)
% plot 20 most active countries
if ~exist('figs','var')
    figs = 3;
end
listName = 'data/Israel/dashboard_timeseries.csv';
cd ~/covid-19-israel-matlab/

try
    fig7 = covid_plot_who;
    fig6 = covid_plot_who(1,1,1);
catch
    disp('no WHO, try later')
end

list = readtable(listName);

list.Properties.VariableNames(1+[7,9:12]) = {'hospitalized','critical','severe','mild','on_ventilator'};
list.deceased = nan(height(list),1);
list.deceased =list.CountDeath;
i1 = find(~isnan(list.hospitalized),1);
list = list(i1:end,:);
fid = fopen('data/Israel/dashboard.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
json = jsondecode(txt);
listE = list;
list = listE(1:end-1,:);

dateSeger = datetime({'14-Mar-2020';'18-Sep-2020';'27-Dec-2020'});

%% plot israel only
fig8 = figure('units','normalized','position',[0,0.25,0.8,0.6]);
subplot(1,2,1)
yyaxis right
idx = ~isnan(list.hospitalized);
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

grid on
box off
legHeb = {['מאושפזים',''],'קל','בינוני','קשה','מונשמים','נפטרים'};
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

%%
covid_israel_percent_positive(figs);
%%
% covid_death_list2;
%% 
% covid_crit_old1
%%
newc = readtable('~/covid-19-israel-matlab/data/Israel/new_critical.csv');
ccc = [0,0.4470,0.7410;0.8500,0.3250,0.09800;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.07800,0.1840];
alf = 0.5;
isLog = false;
% fig10 = figure('units','normalized','position',[0,0,1,1]);
newFig = true;
covid_hosp;
isLog = true;
newFig = true;
% fig12 = figure('units','normalized','position',[0,0,1,1]);
covid_hosp;

if figs == 1
    if exist('fig6','var')
        saveas(fig6,'~/covid-19-israel-matlab/docs/dpmMyCountry.png')
        saveas(fig7,'~/covid-19-israel-matlab/docs/ddpmMyCountry.png')
    end
    saveas(fig10,'~/covid-19-israel-matlab/docs/myCountry.png')
end

%%
% fig11 = figure('units','normalized','position',[0,0,1,1]);
% subplot(1,2,1)
% hh(9) = scatter(list.date(list.CountDeath > 0),list.CountDeath(list.CountDeath > 0),'k.','MarkerEdgeAlpha',alf);
% hold on
% hh(10) = plot(list.date(1:end-1),movmean(list.CountDeath(1:end-1),[3 3]),'k','linewidth',1.5);
% hh(1) = scatter(list.date(2:end),diff(list.CountBreathCum(1:end)),'.','MarkerEdgeAlpha',alf);
% hh(1).MarkerEdgeColor = ccc(1,:);
% hh(2) = plot(list.date(2:end-1),movmean(diff(list.CountBreathCum(1:end-1)),[3 3]),'linewidth',1.5);
% hh(2).Color = ccc(1,:);
% commonDate = datetime(2020,8,18):newc.date(end);
% crit = list.serious_critical_new(2:end) - diff(list.CountSeriousCriticalCum);
% hh(3) = scatter(list.date(2:end),crit,'.','MarkerEdgeAlpha',alf);
% hh(3).MarkerEdgeColor = ccc(2,:);
% hh(4) = plot(list.date(2:end),movmean(crit,[3 3]),'linewidth',1.5);
% hh(4).Color = ccc(2,:);
% hh(5) = scatter(list.date,list.serious_critical_new,'.','MarkerEdgeAlpha',alf);
% hh(5).MarkerEdgeColor = ccc(3,:);
% hh(6) = plot(list.date(1:end-1),movmean(list.serious_critical_new(1:end-1),[3 3]),'linewidth',1.5);
% hh(6).Color = ccc(3,:);
% hh(7) = scatter(list.date,list.new_hospitalized,'.','MarkerEdgeAlpha',alf);
% hh(7).MarkerEdgeColor = ccc(4,:);
% hh(8) = plot(list.date(1:end-1),movmean(list.new_hospitalized(1:end-1),[3 3]),'linewidth',1.5);
% hh(8).Color = ccc(4,:);
% % if figs <= 1
% %     legend(hh([8,6,4,2,10]),'מאושפזים','קשים','קריטיים','מונשמים','נפטרים','location','northwest')
% %     title('חולים חדשים')
% % elseif figs == 2
% %     legend(hh([8,6,4,2,10]),'hospitalized','severe','critical','ventilated','deceased','location','northwest')
% %     title('New Patients')
% % elseif figs == 3
% title('New Patients    חולים חדשים')
% legend(hh([8,6,4,2,10]),'hospitalized מאושפזים','severe                קשה','critical               קריטי',...
%     'on vent          מונשמים','deceased        נפטרים','location','northwest')
% % end  
% grid on
% box off
% set(gcf,'Color','w')
% grid minor
% set(gca,'fontsize',13,'XTick',datetime(2020,3:20,1))
% ylim([0 150])
% xlim([datetime(2020,11,15) datetime('tomorrow')])
% xtickformat('MMM')
% subplot(1,2,2)
% hh1(1) = scatter(listE.date,listE.on_ventilator,'.','MarkerEdgeAlpha',alf);
% hold on
% hh1(2) = plot(listE.date(1:end-1),movmean(listE.on_ventilator(1:end-1),[3 3]),'linewidth',1.5);
% hh1(2).Color = ccc(1,:);
% listE.CountCriticalStatus(1:find(listE.CountCriticalStatus > 10,1)-1) = nan;
% hh1(3) = scatter(listE.date,listE.CountCriticalStatus,'.','MarkerEdgeAlpha',alf);
% hh1(3).MarkerEdgeColor = ccc(2,:);
% hh1(4) = plot(listE.date(1:end-1),movmean(listE.CountCriticalStatus(1:end-1),[3 3]),'linewidth',1.5);
% hh1(4).Color = ccc(2,:);
% hh1(5) = scatter(listE.date,listE.critical,'.','MarkerEdgeAlpha',alf);
% hh1(5).MarkerEdgeColor = ccc(3,:);
% hh1(6) = plot(listE.date(1:end-1),movmean(listE.critical(1:end-1),[3 3]),'linewidth',1.5);
% hh1(6).Color = ccc(3,:);
% hh1(7) = scatter(listE.date,listE.hospitalized,'.','MarkerEdgeAlpha',alf);
% hh1(7).MarkerEdgeColor = ccc(4,:);
% hh1(8) = plot(listE.date(1:end-1),movmean(listE.hospitalized(1:end-1),[3 3]),'linewidth',1.5);
% hh1(8).Color = ccc(4,:);
% 
% % if figs <= 1
% %     legend(hh([8,6,4,2,10]),'מאושפזים','קשים','קריטיים','מונשמים','נפטרים','location','northwest')
% %     title('חולים')
% % elseif figs == 2
% %     legend(hh([8,6,4,2,10]),'hospitalized','severe','critical','ventilated','deceased','location','northwest')
% %     title('Patients')
% % elseif figs == 3
% title('Patients    חולים')
% legend(hh1([8,6,4,2]),'hospitalized מאושפזים','severe                קשה','critical               קריטי',...
%     'on vent          מונשמים','location','northwest')
% % end  
% grid on
% box off
% set(gcf,'Color','w')
% set(gca,'fontsize',13)
% 
% grid minor
% ylim([0 1300])
% xlim([datetime(2020,11,15) datetime('tomorrow')])
% xtickformat('MMM')
% set(gca,'fontsize',13,'XTick',datetime(2020,3:20,1))