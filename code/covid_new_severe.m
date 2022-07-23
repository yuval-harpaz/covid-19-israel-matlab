
cd ~/covid-19-israel-matlab/data/Israel
listD = readtable('dashboard_timeseries.csv');

json = urlread('https://datadashboardapi.health.gov.il/api/queries/newHospitalizationDaily');
json = jsondecode(json);
hosp = struct2table(json);
hosp.dayDate = datetime(strrep(hosp.dayDate,'T00:00:00.000Z',''));
hosp.Properties.VariableNames{1} = 'date';
hdx = find(ismember(hosp.ageGroup,'כלל האוכלוסיה'));
sevHosp = hosp.seriousCriticalNewStatus(hdx);

json = urlread('https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily');
json = jsondecode(json);
severe = struct2table(json);
severe.day_date = datetime(strrep(severe.day_date,'T00:00:00.000Z',''));
severe.Properties.VariableNames{1} = 'date';
idx = find(ismember(severe.age_group,'כלל האוכלוסיה'));
sevAll = sum(severe{idx,6:8},2);
%%
figure;
plot(severe.date(idx),sevAll,'k.')
% plot(listD.date,listD.CountDeath,'.k')
hold on
hn(1) = plot(severe.date(idx(1:end-1)),movmean(sevAll(1:end-1),[3 3]),'k');
% hn(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3],'omitnan'),'k');
plot(hosp.date(hdx),sevHosp,'g.')
hn(2) = plot(hosp.date(hdx(1:end-1)),movmean(sevHosp(1:end-1),[3 3]),'g');

plot(listD.date,listD.serious_critical_new,'.r')
hn(3) = plot(listD.date(1:end-1),movmean(listD.serious_critical_new(1:end-1),[3 3],'omitnan'),'r');

plot(listD.date(2:end),diff(listD.CountSeriousCriticalCum),'.b')
dif = diff(listD.CountSeriousCriticalCum(1:end-1));
% dif(187) = nan;
hold on
hn(4) = plot(listD.date(2:end-1),movmean(dif,[3 3],'omitnan'),'b');

% ylim([0 1.1*nanmax(dif)])
grid on
box off
xtickformat('MMM')
set(gca,'xtick',datetime(2020,3:50,1))
set(gcf,'Color','w')
title('תמותה מול קשים+קריטיים חדשים')
legend(hn,'vax + expired + unvax','seriousCriticalNewStatus','serious critical new','diff(CountSeriousCriticalCum)','location','northwest')
xlim([datetime(2020,3,1) datetime('today')+7])