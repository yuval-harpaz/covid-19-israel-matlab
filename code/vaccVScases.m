json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
json = jsondecode(json);
t = struct2table(json);
date = datetime(strrep(t.Day_Date,'T00:00:00.000Z',''));
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
% covid_google2;
figure;
yyaxis left
plot(date,t.vaccinated_seconde_dose_population_perc)
ylabel('2nd dose vaccination (%)')
yyaxis right
plot(listD.date,movmean(listD.tests_positive,[3 3]),'-')
hold on
plot(listD.date,listD.tests_positive,':')
ylabel('Positive cases')
% set(gca,'XTick',datetime(fliplr(datetime('yesterday'):-7:datetime(2021,1,17))))
xtickformat('MMM')
set(gca,'xtick',datetime(2020,3:30,1),'FontSize',13)
xlim([datetime(2020,5,1) datetime('today')])
grid on
grid minor
title({'אחוז ההתחסנות מול מאומתים','percent vaccinited vs cases'})
set(gcf,'Color','w')
legend('vaccinated    מתחסנים','cases            מאומתים','location','north')