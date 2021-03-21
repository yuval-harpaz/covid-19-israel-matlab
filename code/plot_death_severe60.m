cd ~/covid-19-israel-matlab/data/Israel/
crit = readtable('crit_by_age.csv');
death = readtable('deaths by vaccination status.xlsx');
critOld = [crit.over60-crit.over60vacc,crit.over60vacc];
deaths = [death.notVaccinated+death.vaccinationInProgress,death.fullyVaccinated];
figure
h1 = plot(crit.date,critOld);
hold on
h2 = plot(death.date,deaths);
h = [h1(1),h2(1),h1(2),h2(2)];
legend(h,'new severe 60+ not vaccinated','deaths not vaccinated','new severe 60+ vaccinated','deaths vaccinated')
title('deaths and new old severe cases, by vaccination status')
set(gcf,'Color','w')
grid on
set(gca,'YTick',0:10:120,'XTick',datetime(fliplr(datetime('today'):-7:datetime(2021,1,17))))
