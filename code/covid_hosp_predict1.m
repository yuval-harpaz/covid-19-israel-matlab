
json = urlread('https://datadashboardapi.health.gov.il/api/queries/patientsPerDate');
json = jsondecode(json);
tt = struct2table(json);
tt.date = datetime(strrep(tt.date,'T00:00:00.000Z',''));

json = urlread('https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily');
json = jsondecode(json);
cases = struct2table(json);
cases.day_date = datetime(strrep(cases.day_date,'T00:00:00.000Z',''));
cases.Properties.VariableNames{1} = 'date';

cOld = ismember(cases.age_group,'מעל גיל 60');
cYoung = ismember(cases.age_group,'מתחת לגיל 60');

cd6 = [cases{cYoung,3:5},cases{cOld,3:5}];
cd6(end,:) = nan;
cd6 = movmean(cd6,[3 3],'omitnan');
% fac = [0.0002,0.0003,0.0005,0.025,0.035,0.1];
% fac = fac * 7.8;
fac = [0.0016, 0.0023, 0.0039, 0.1950, 0.2730, 0.7800];

predCases = sum(cd6.*fac,2);
predOmi = cd6.*fac*(1-0.42);
% predOmi(:,[1,2,4,5]) = predOmi(:,[1,2,4,5])*0.3;
predOmi = sum(predOmi,2);
hosp = tt.new_hospitalized;
hosp(end) = nan;
hosp = movmean(hosp, [3 3]);
%%
figure('position',[100,100,900,700]);
plot(tt.date,hosp,'k','linewidth',2)
hold on
plot(cases.date(cOld)+5,predCases,'b')
plot(cases.date(cOld)+5,predOmi,'g')
% plot(severe.date(ages{1,1})+11,predCases,'b')
legend('hospital admissions','predicttion for Δ','prediction for  O')
grid on
title({'predict hospitalizations by cases','assumes 100% Δ or 100% O'})
set(gcf,'Color','w')
set(gca,'FontSize',13)
ylabel('new patients')
xlim([datetime(2021,6,1) datetime('today')+14])
