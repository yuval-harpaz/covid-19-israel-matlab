listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
figure;
fill([datetime(2020,1,1),datetime(2020,5,31),datetime(2020,5,31),datetime(2020,1,1)],...
    [0,0,10^4,10^4],[0.9 1 0.9],'linestyle','none')
hold on
fill([datetime(2021,1,1),datetime(2021,5,31),datetime(2021,5,31),datetime(2021,1,1)],...
    [0,0,10^4,10^4],[1 0.9 0.9],'linestyle','none')
fill([datetime(2021,5,9),datetime(2021,5,9),datetime(2021,5,21),datetime(2021,5,21)],...
    [1000,9000,9000,1000],[1 0.8 0.8],'linestyle','none')
plot(listD.date(1:end-1),listD.tests_positive1(1:end-1),'k')
set(gca,'XTick',sort([datetime(2020:2021,1,1),datetime(2020:2021,5,31)]))
xtickformat('dd.MM.yy')
box off
xlim([datetime(2020,1,1) datetime('today')])
ylim([0 10^4])
legend('314 קריאות למד"א','397 קריאות למד"א','רקטות','מאומתים','location','northwest')
ylabel('מאומתים')
title('קריאות למד"א על אירועים לבביים לפי המחקר של פרופ רצף לוי')
set(gcf,'Color','w')