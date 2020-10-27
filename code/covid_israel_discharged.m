cd ~/covid-19-israel-matlab/data/Israel/
listD = readtable('dashboard_timeseries.csv');
newc = readtable('new_critical.csv');
increase = diff(listD.CountHardStatus(18:end-5));
discharged = increase+listD.CountDeath(19:end-5)-newc.new_critical;
discharged = -discharged;

figure;
plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3],'omitnan'))
hold on
plot(listD.date(1:end-1),movmean(listD.CountHardStatus(1:end-1),[3 3],'omitnan'))
plot(newc.date,movmean(newc.new_critical,[3 3],'omitnan'))
plot(newc.date,movmean(discharged,[3 3],'omitnan'))
legend('נפטרים','קשים','קשים חדשים','משוחררים')
box off
grid on
grid minor
ylim([0 900])
title('כמה חולים קשים משתחררים מהמחלקות')

newc.discharged = discharged;
newc.deceased = listD.CountDeath(19:end-5);
