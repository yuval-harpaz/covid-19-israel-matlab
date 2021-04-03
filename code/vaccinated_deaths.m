cd ~/covid-19-israel-matlab/data/Israel/
deaths = readtable('deaths by vaccination status.xlsx');
severe = readtable('severe by vaccination status.xlsx');
old = readtable('crit_by_age.csv');
dPer = 100*deaths{:,3:4}./deaths{:,5};
sPer = 100*severe{:,3:4}./severe{:,5};
oPer = 100*old.over60vacc./old.over60;
%%
figure;
subplot(2,1,2)
hs1 = plot(deaths.date,movmean(sPer(:,2),[3 3]),'Color',[0    0.4470    0.7410]);
hold on
hd1 = plot(deaths.date,movmean(dPer(:,2),[3 3]),'Color',[0.8500    0.3250    0.0980]);
% ho = plot(old.date,movmean(oPer,[3 3]));
legend('vaccinated severe','vaccinated deaths','location','north')
grid on
box off
title('Ratio of vaccinated deaths and new severe cases')
set(gca,'XTick',datetime(fliplr(datetime('yesterday'):-7:datetime(2021,1,17))),...
    'ytick',0:10:100)
ylabel('%')
ylim([0 100])
subplot(2,1,1)
hs = plot(deaths.date,movmean(severe.total,[3 3]),'Color',[0.9290    0.6940    0.1250]);
hold on
hd = plot(deaths.date,movmean(deaths.total,[3 3]),'k');
hsvv = plot(deaths.date,movmean(severe{:,4},[3 3]),'Color',[0    0.4470    0.7410]);
hdv = plot(deaths.date,movmean(deaths{:,4},[3 3]),'Color',[0.8500    0.3250    0.0980]);

% ho = plot(old.date,movmean(oPer,[3 3]));
legend('severe','deaths','vaccinated severe','vaccinated deaths','location','north')
grid on
box off
title('Deaths and new severe cases by vaccination status')
ylabel('Patients')
set(gca,'XTick',datetime(fliplr(datetime('yesterday'):-7:datetime(2021,1,17))),...
    'ytick',0:10:140)
set(gcf,'Color','w')
