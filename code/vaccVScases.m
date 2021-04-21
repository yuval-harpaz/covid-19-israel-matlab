glob = covid_google2;
globDate = datetime(2020,2,15:15+length(glob)-1)';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
json = jsondecode(json);
t = struct2table(json);
date = datetime(strrep(t.Day_Date,'T00:00:00.000Z',''));
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
Bdate = [datetime(2020,12,24),datetime(2021,1,14),datetime(2021,1,7*(3:5)),datetime(2021,2,7)];
B117 = [2.5;36.1;60.0;79.5;90;91.2];
% covid_google2;
figure;
yyaxis left
h(1) = plot(date,t.vaccinated_seconde_dose_population_perc);
hold on
h(2) = plot(date,t.vaccinated_population_perc);
h(3) = plot(globDate,-glob(:,end),'-','Color',[0.6 0.8 0.6],'linewidth',2);
h(4) = plot(Bdate,B117,'Color',[0.5 0.5 0.5],'linewidth',2);
ylim([0 100])
ylabel({'% percents','(vaccination, restrictions, B.1.1.7)'})
yyaxis right
h(5) = plot(listD.date,movmean(listD.tests_positive,[3 3]),'-');
hold on
% plot(listD.date,listD.tests_positive,':')
ylabel('Positive cases')
ylim([0 10000])
% set(gca,'XTick',datetime(fliplr(datetime('yesterday'):-7:datetime(2021,1,17))))
xtickformat('MMM')
set(gca,'xtick',datetime(2020,3:30,1),'FontSize',13)
xlim([datetime(2020,6,1) datetime('today')])
grid on
grid minor
title({'נפילת הקורונה בישראל','The fall of COVID19 in Israel'})
set(gcf,'Color','w')
legend(h([2,1,3,4,5]),'vaccinated  I   מתחסנים','vaccinated  II  מתחסנים',...
    'restrictions        מגבלות','B.1.1.7','cases               מאומתים','location','northwest')