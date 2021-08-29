
cd ~/covid-19-israel-matlab/data/Israel
% dateCheck = dir('tmp/2021_BF_Region_Mobility_Report.csv');
% if now-datenum(dateCheck.date) > 7
%     [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
%     unzip('tmp.zip','tmp')
%     !rm tmp.zip
% end
% cd tmp
% t2020 = readtable(['2020_IL_Region_Mobility_Report.csv']);
% t2021 = readtable(['2021_IL_Region_Mobility_Report.csv']);
% glob = covid_google2;
% globDate = datetime(2020,2,15:15+length(glob)-1)';
% conf = readtable('confirmed.csv');
dateSeger = datetime({'14-Mar-2020';'18-Sep-2020';'27-Dec-2020'});
json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
json = jsondecode(json);
t = struct2table(json);
date = datetime(strrep(t.Day_Date,'T00:00:00.000Z',''));
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
Bdate = [datetime(2020,12,24),datetime(2021,1,14),datetime(2021,1,7*(3:5)),datetime(2021,2,7)];
B117 = [2.5;36.1;60.0;79.5;90;91.2];
% covid_google2;
d3 = t.vaccinated_third_dose_population_perc;
d3(d3 == 0) = nan;
%%

figure('Units','Normalized','Position',[0.1 0.1 0.7 0.7]);
yyaxis left
h(1) = plot(date,t.vaccinated_seconde_dose_population_perc,'--','linewidth',1);
hold on
h(2) = plot(date,t.vaccinated_population_perc,':','linewidth',2);
h(3) = plot(date,d3,'-','linewidth',1);
% h(3) = plot(globDate,-glob(:,end),'-','Color',[0.6 0.8 0.6],'linewidth',2);
h(4) = plot(Bdate,B117,'-.','Color',[0.5 0.5 0.5],'linewidth',1);
ylim([0 100])
ylabel('מתחסנים (%)')
yyaxis right
pos = movmean(listD.tests_positive1,[3 3]);
h(5) = plot(listD.date,pos,'-','linewidth',1);
hold on
% plot(listD.date,listD.tests_positive,':')
ylabel('מקרים מאומתים')
ylim([0 10000])
% set(gca,'XTick',datetime(fliplr(datetime('yesterday'):-7:datetime(2021,1,17))))
xtickformat('MMM')
set(gca,'xtick',datetime(2020,3:30,1),'FontSize',13)
xlim([datetime(2020,6,1) datetime('today')])
grid on
% grid minor
title('מאומתים ומתחסנים בישראל')
set(gcf,'Color','w')
legend(h([2,1,3,4,5]),'מנה I','מנה II','מנה III','אלפא','מאומתים','location','northwest')
dateSeger = datetime({'18-Sep-2020';'27-Dec-2020';'29-Jun-2021'});
text(dateSeger,pos(ismember(listD.date,dateSeger)),{'סגר II','סגר III','תו ירוק'},...
    'HorizontalAlignment','right','FontSize',13)
