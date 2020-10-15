cd ~/covid-19-israel-matlab/data/Israel/
listD = readtable('dashboard_timeseries.csv');
deaths = movmean(listD.CountDeath(1:end-2),[3 3],'omitnan');
idx1 = ismember(listD.date,datetime(2020,3,1):datetime(2020,6,1));
x1 = datenum(listD.date(idx1)-datetime(2020,3,29));
idx2 = ismember(listD.date,datetime(2020,9,12)+x1(1):listD.date(end-2));
x2 = datenum(listD.date(idx2)-datetime(2020,9,12));
lag = 10;
idx3 = ismember(listD.date,datetime(2020,9,12)-lag+x1(1):listD.date(end-2));
x3 = datenum(listD.date(idx3)-datetime(2020,9,12)-lag);
figure;
yyaxis left
h(1) = plot(x1,deaths(idx1));
ylim([-2 max(deaths(idx1))*1.1])
yyaxis right
h(2) = plot(x2,deaths(idx2));
hold on
h(3) = plot(x3,deaths(idx3));
ylim([10 max(deaths(idx3))*1.1])
legend(h,'יום אפס הסגר הראשון 29.3','יום אפס הסגר השני 12.9','יום אפס הסגר השני בעיכוב 10 ימים')
box off
grid on
title('הירידה בתמותה בסגר השני מבוששת לבוא')





t = listD(:,[1,13]);
t.CountDeath(isnan(t.CountDeath)) = 0;
t = t(1:end-1,:);
figure;plot(t.date,t.CountDeath)

t.dif = [0;diff(t.CountDeath)];
t.death_smooth = movmean(t.CountDeath,[3 3]);
t.dif_smooth = [0;diff(t.death_smooth)];
t.change = 100*(movmean(t.dif_smooth,[3 3])./t.death_smooth);
xChosen = [datetime(2020,3,29):datetime(2020,4,29),datetime(2020,9,12):datetime(2020,9,29)];
chosen = t.change;
chosen(~ismember(t.date,xChosen)) = nan;



%figure; plot(t.date,100*(movmean(t.dif_smooth,[3 3])./t.death_smooth))


figure;
yyaxis left
h1 = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]));
ylim([-20 60])
ylabel('מתים ליום')
set(gca,'FontSize',13)
yyaxis right
h2 = plot(t.date,t.change);
line([datetime(2020,3,1) listD.date(end-1)],[0 0],'color',[0 0 0])
ylim([-20 60])
xlim([datetime(2020,3,1) listD.date(end-1)])
hold on
h3 = plot(t.date,chosen,'r-','linewidth',2);
ylabel('אחוז השינוי')
xlim([datetime(2020,3,21) t.date(end)])
set(gca,'FontSize',13,'ygrid','on')
