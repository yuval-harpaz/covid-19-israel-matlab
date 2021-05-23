json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectionFactor');
json = jsondecode(json);
t = struct2table(json);
date = datetime(strrep(t.day_date,'T00:00:00.000Z',''));
ful = ~cellfun(@isempty ,t.R);
R = nan(length(date),1);
R(ful,1) = cellfun(@(x) x,t.R(ful));


listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
mm = movmean(listD.tests_positive,[6 0]);
days = 7;
rr = mm(days+1:end)./mm(1:end-days);
%%
pow = 0.685;
shift = 3;
figure;
yyaxis left
plot(date,R,'LineWidth',2)
hold on;
plot(listD.date(1)-shift:listD.date(end)-days-shift,rr.^pow,':k','LineWidth',1.5)
ylim([0 2])
ylabel('R')
yyaxis right
plot(listD.date,movmean(listD.tests_positive,[3 3]))
hold on
plot(listD.date,listD.tests_positive,':')
ylim([0 10000])
xtickformat('MMM')
set(gca,'xtick',datetime(2020,4:30,1))
set(gcf,'Color','w')
title('cases vs R מאומתים מול')
ylabel('Cases')
xlim([datetime(2020,6,1) datetime('tomorrow')])
legend('R','R estimate','cases','location','north')
grid on
% title(pow)

% figure;plot([rr(end-10:end).^pow,R(end-10:end)])
% rme = rr(end-114:end-4); rdb = R(end-120:end-10);
% n = log10(rdb)./log10(rme);