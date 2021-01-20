function covid_bard_plot(olfac)
if nargin == 0
    olfac = 140;
end
cd ~/covid-19-israel-matlab/data/Israel
!wget -O tmp.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/isolated_staff.csv
staff = readtable('tmp.csv');
staffDate = datetime(cellfun(@(x) x(1:end-5),strrep(staff.Date,'T',' '),'UniformOutput',false));
yDash = staff{:,2:5};
nurse = yDash(:,1);
nurse(80:87) = nan;
doc = yDash(:,2);
bad = false(size(doc));
bad(doc == 0) = true;
badDoc = bad;
badDoc(190) = true;
agegen = readtable('dashboard_age_gen.csv');
date = unique(dateshift(agegen.date,'start','day'));
clear dash
for ii = 1:length(date)
    dash(ii,1:2) = [sum(max(agegen{agegen.date > date(ii) & agegen.date < date(ii)+1,2:13})),...
        sum(max(agegen{agegen.date > date(ii) & agegen.date < date(ii)+1,14:21}))];
end
dash(dash(:,1) < 150000,:) = nan;
in = find(isnan(dash(:,1)));
if in(end) == length(dash)
    in(end) = [];
end
for iin = 1:length(in)
    dash(in(iin),:) = (dash(in(iin)-1,:)+dash(in(iin)+1,:))/2;
end
%%
figure;
fill(datetime(2020,12,[20,20+14,20+14,20,20]),[0,0,2,2,0]/0.3,[0.9,0.9,0.9],'linestyle','none')
hold on
plot(staffDate(~badDoc),doc(~badDoc)/200/0.3)
hold on
plot(staffDate(~bad),nurse(~bad)/350/0.3)
plot(date(2:end),movmean(diff(dash(:,1))/1000,[3 3],'omitnan')) % young
plot(date(2:end),movmean(diff(dash(:,2))/olfac,[3 3],'omitnan')) % old
xtickformat('MMM')
xlim([datetime(2020,6,15) datetime('today')+5])
title('מאומתים לפי לוח הבקרה')
box off
grid on
legend('שבועיים מחיסון ראשון','רופאות\ים','אחיות\ם','צעירות\ים מ 60','מבוגרות\ים מ 60','location','northwest')
set(gcf,'Color','w')
xtickformat('MMM')
ylabel('מנורמל לפי תחילת דצמבר')
% xlabel('גרף מאומתים בישראל לכבוד בארד 2134')
xlim([datetime(2020,10,15) datetime('today')+5])
%%
figure;
plot(date(2:end),movmean(diff(dash(:,2))/olfac,[3 3],'omitnan')...
    ./movmean(diff(dash(:,1))/1000,[3 3],'omitnan'))
%%
listD = readtable('dashboard_timeseries.csv');
figure;
plot(listD.date,listD.CountDeath,'.k')
hold on
hn(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3],'omitnan'),'k');
plot(listD.date(2:end),diff(listD.CountSeriousCriticalCum),'.b')
dif = diff(listD.CountSeriousCriticalCum(1:end-1));
dif(187) = nan;
hold on
hn(2) = plot(listD.date(2:end-1),movmean(dif,[3 3],'omitnan'),'b');
ylim([0 1.1*nanmax(dif)])
grid on
box off
xtickformat('MMM')
set(gca,'xtick',datetime(2020,3:30,1))
set(gcf,'Color','w')
title('תמותה מול קשים+קריטיים חדשים')
legend(hn,'תמותה','קשים+קריטיים חדשים','location','northwest')