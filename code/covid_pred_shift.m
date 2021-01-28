cd ~/covid-19-israel-matlab/data/Israel
tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
newc = readtable('new_critical.csv');

%%
figPred = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
scatter(listD.date,listD.CountDeath,'.','MarkerEdgeAlpha',0.5,'MarkerEdgeColor',[0 0 1]);
hold on;
h(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
h(2) = plot(tests.date+12,movmean(tests.pos60,[3 3])/10,'r');
h(3) = plot(listD.date(1:end-1)+12,movmean(listD.tests_positive(1:end-1),[3 3])/140,'k','linewidth',1);
y = listD.tests_positive(1:end-1)./listD.tests_result(1:end-1)*100;
y(108) = mean(y([107,106]));
h(4) = plot(listD.date(1:end-1)+12,movmean(y,[3 3])*4,'g','linewidth',1);
y = diff(listD.CountSeriousCriticalCum(1:end-1));
y(187) = mean(y([186,188]));
h(5) = plot(listD.date(2:end-1)+7,movmean(y,[3 3])/3,'c','linewidth',1);
y = diff(listD.CountBreathCum(1:end-2));
h(6) = plot(listD.date(2:end-2)+3,movmean(y,[3 3])*2,'m','linewidth',1);
%
grid on
grid minor
ylabel('נפטרים ליום')
legend(h,'נפטרים','חיוביים מעל גיל 60 (בדיקה ראשונה)','חיוביים','אחוז החיוביים','קשים+קריטיים חדשים','מונשמים חדשים','location','northwest')
title('העליה הצפויה בתמותה לפי מנבאים שונים')
box off
set(gca,'fontsize',13)
set(gca,'XTick',datetime(2020,3:30,1))
xtickformat('MMM')
xtickangle(45)
xlim([datetime(2020,3,15) tests.date(end)+30]);
set(gcf,'color','w')
xlim([datetime(2020,6,1) datetime('today')+20])
% saveas(figPred,'Oct1prediction.png')
%% 
