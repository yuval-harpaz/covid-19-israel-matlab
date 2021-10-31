json = urlread('https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily');
json = jsondecode(json);
deaths = struct2table(json);
deaths.day_date = datetime(strrep(deaths.day_date,'T00:00:00.000Z',''));
deaths.Properties.VariableNames{1} = 'date';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily');
json = jsondecode(json);
severe = struct2table(json);
severe.day_date = datetime(strrep(severe.day_date,'T00:00:00.000Z',''));
severe.Properties.VariableNames{1} = 'date';

dOld = ismember(deaths.age_group,'מעל גיל 60');
sOld = ismember(severe.age_group,'מעל גיל 60');
sYoung = ismember(deaths.age_group,'מתחת לגיל 60');
cYoung = ismember(deaths.age_group,'מתחת לגיל 60');

% date = cellfun(@(x) datetime(x(1:10)),severe.day_date(sYoung));

listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
sev60 = readtable('~/covid-19-israel-matlab/data/Israel/severe60.csv');
figure; % new severe below 60
plot(listD.date,listD{:,25})
hold on
% plot(listD.date(2:end),movmean(diff(listD{:,23}),[3 3]))
plot(severe.date(sYoung),movmean(sum(severe{sYoung,6:8},2),[3 3]))
plot(sev60.date,movmean(sev60.below60,[3 3]))
% plot(severe.date(sYoung),movmean(sum(severe{sYoung,3:5},2),[3 3]))


figure; % severe below 60
yyaxis left
plot(listD.date,movmean(listD{:,25},[3 3]))
ylabel('ECMO patients')
yyaxis right
% plot(listD.date(2:end),movmean(diff(listD{:,23}),[3 3]))
% plot(severe.date(sYoung),movmean(sum(severe{sYoung,6:8},2),[3 3]))
plot(severe.date(sYoung),movmean(sum(severe{sYoung,3:5},2),[3 3]))
ylabel('Severe patients')
legend('ECMO','Severe <60','location','north')
grid on
box off
set(gcf,'Color','w')
title('ECMO vs active severe patients <60')
ylim([0 360])
set(gca,'YTick',0:60:360)
set(gca,'xtick',datetime(2020,3:100,1),'FontSize',13)
xlim([datetime(2020,12,1) datetime('today')+7])
xtickformat('MMM')