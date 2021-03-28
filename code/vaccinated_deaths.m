cd ~/covid-19-israel-matlab/data/Israel/
deaths = readtable('deaths by vaccination status.xlsx');
severe = readtable('severe by vaccination status.xlsx');
old = readtable('crit_by_age.csv');
dPer = 100*deaths{:,3:4}./deaths{:,5};
sPer = 100*severe{:,3:4}./severe{:,5};
oPer = 100*old.over60vacc./old.over60;

figure;
subplot(2,1,2)
hd = plot(deaths.date,movmean(dPer(:,2),[3 3]));
hold on
hs = plot(deaths.date,movmean(sPer(:,2),[3 3]));
% ho = plot(old.date,movmean(oPer,[3 3]));
legend('deaths','new severe','location','northwest')
grid on
box off
title('Ratio of vaccinated deaths and new severe cases')
set(gca,'XTick',datetime(fliplr(datetime('yesterday'):-7:datetime(2021,1,17))))
ylabel('%')
subplot(2,1,1)
hd = plot(deaths.date,movmean(deaths{:,4},[3 3]));
hold on
hs = plot(deaths.date,movmean(severe{:,4},[3 3]));
% ho = plot(old.date,movmean(oPer,[3 3]));
legend('deaths','new severe','location','northwest')
grid on
box off
title('Vaccinated deaths and new severe cases')
ylabel('Patients')
set(gca,'XTick',datetime(fliplr(datetime('yesterday'):-7:datetime(2021,1,17))))
set(gcf,'Color','w')
