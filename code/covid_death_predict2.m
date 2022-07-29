
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
death = listD.CountDeath;
death(end) = nan;
death = movmean(death,[3 3],'omitnan');

json = urlread('https://datadashboardapi.health.gov.il/api/queries/newHospitalizationDaily');
json = jsondecode(json);
hosp = struct2table(json);
hosp.dayDate = datetime(strrep(hosp.dayDate,'T00:00:00.000Z',''));
hosp.Properties.VariableNames{1} = 'date';
hdx = ismember(hosp.ageGroup,'מעל גיל 60');
sevOld = hosp.seriousCriticalNewStatus(hdx);
hdx = find(ismember(hosp.ageGroup,'מתחת לגיל 60'));
sevYoung = hosp.seriousCriticalNewStatus(hdx);
sevDate = hosp.date(hdx);

facSev = [0.08,0.37];
predSev = round(sum(movmean([sevYoung,sevOld],[3 3]).*facSev,2));

figure('position',[100,100,900,700]);
plot(listD.date,death,'k','linewidth',2)
hold on
plot(sevDate+8,predSev,'r')
hl = legend('deaths','old severe*0.37 + young severe*0.08, 8 days later','location','northwest');
hl.Box = 'off';
grid on
title('predict deaths by cases or new severe patients')
set(gcf,'Color','w')
set(gca,'FontSize',17)
ylabel('deaths')
%%
facSev = [0.04,0.22];
predSev = round(sum(movmean([sevYoung,sevOld],[3 3]).*facSev,2));

figure('position',[100,100,900,700]);
plot(listD.date,death,'k','linewidth',2)
hold on
plot(sevDate+3,predSev,'r')
hl = legend('deaths','old severe*0.22 + young severe*0.04, 3 days later','location','northwest');
hl.Box = 'off';
grid on
title('predict deaths by cases or new severe patients')
set(gcf,'Color','w')
set(gca,'FontSize',17)
ylabel('deaths')

