function covid_Israel
% plot 20 most active countries
% if ~exist('figs','var')
figs = 0;
% end
listName = 'data/Israel/dashboard_timeseries.csv';
cd ~/covid-19-israel-matlab/

% try
%     fig7 = covid_plot_who;
%     fig6 = covid_plot_who(1,1,1);
% catch
%     disp('no WHO, try later')
% end

list = readtable(listName);
% colm = [13,15,9,8,]
% coml = 1+[7,9:12]
% list.Properties.VariableNames(colm) = {'hospitalized','critical','severe','mild','on_ventilator'};
list.deceased = nan(height(list),1);
list.deceased =list.CountDeath;
i1 = find(~isnan(list.CountHospitalized),1);
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
fig8 = figure('units','normalized','position',[0,0.25,0.8,1]);
subplot(2,1,1)
hh = plot(list.date,[list.CountEasyStatus,list.CountMediumStatus,list.CountHardStatus],'linewidth',2);
hh(1).Color = [0.055,0.49,0.49];
hh(2).Color = [0.725,0.788,0.357];
hh(3).Color = [0.184,0.804,0.984];
legend('mild             קל','medium    בינוני','severe       קשה','location','northwest')
ylabel('patients   חולים')
set(gca,'FontSize',13)
grid on
box off
title('Currently hospitalized patients, by condition   סך הכל מאושפזים לפי מצב')
xlim([datetime(2020,3,1) datetime('today')+3])
set(gcf,'Color','w')
set(gca,'XTick',datetime(2020,1:300,1))
xtickformat('MM/yy')
xtickangle(90)

subplot(2,1,2)
hh = plot(list.date,[list.easy_new,list.medium_new,list.serious_critical_new],'linewidth',2);
hh(1).Color = [0.055,0.49,0.49];
hh(2).Color = [0.725,0.788,0.357];
hh(3).Color = [0.184,0.804,0.984];
legend('mild             קל','medium    בינוני','severe       קשה','location','northwest')
ylabel('patients   חולים')
set(gca,'FontSize',13)
grid on
box off
title({'New patients by condition   מאושפזים חדשים לפי מצב',...
    'Including patients that got better   כולל חולים שמצבם השתפר'})
xlim([datetime(2020,3,1) datetime('today')+3])
set(gcf,'Color','w')
set(gca,'XTick',datetime(2020,1:300,1))
xtickformat('MM/yy')
xtickangle(90)

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

