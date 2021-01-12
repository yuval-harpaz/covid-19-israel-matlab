cd ~/covid-19-israel-matlab/data/Israel
ecmo = readtable('ECMO.csv');
ecmo(isnan(ecmo.ecmo),:) = [];
listD = readtable('dashboard_timeseries.csv');
figure;
h(2) = plot(listD.date(188:end),listD.CountCriticalStatus(188:end));
hold on
h(1) = plot(listD.date,listD.CountBreath);
h(4) = plot(listD.date(1:end-1),listD.CountDeath(1:end-1),'k');
h(3) = plot(ecmo.date,ecmo.ecmo,'Color',[0.4660    0.6740    0.1880],'Marker','.');

legend('קריטיים','מונשמים','נפטרים','אקמו','location','northwest')
title('חוסר בעמדות אקמו ובהנשמה מלאכותית בשיא העומס')
set(gcf,'Color','w')
box off
grid on
xtickformat('MMM')
xlim([datetime(2020,6,1) datetime('tomorrow')])
grid minor