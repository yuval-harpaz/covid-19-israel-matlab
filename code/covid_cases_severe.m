
delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedDaily');
json = jsondecode(json);
date = cellfun(@(x) datetime(x(1:10)),{json.day_date}');
tt = struct2table(json);
json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedByAge');
json = jsondecode(json);
tAge = struct2table(json);

json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
json = jsondecode(json);
tv = struct2table(json);

idx60 = find(ismember(tt.age_group,'מעל גיל 60'));
idxy = find(ismember(tt.age_group,'מתחת לגיל 60'));
if isequal(date(idxy),unique(date))
    date = date(idxy);
else
    error('bad dates')
end

figure;
plot(date,tt.Serious_not_vaccinated_normalized(idx60))
hold on
plot(date,tt.Serious_vaccinated_procces_normalized(idx60))
plot(date,tt.Serious_vaccinated_normalized(idx60))


fac = 1.6;
lag = 4;
figure;
plot(date+lag,movmean(fac*tt.verified_not_vaccinated_normalized(idxy),[3 3]))
hold on
plot(listD.date,movmean(listD.serious_critical_new,[3 3]))
plot(date,movmean(fac*tt.verified_not_vaccinated_normalized(idx60),[3 3]))


old_60_vacc = round(tt.verified_amount_vaccinated(idx60)./tt.vaccinated_amount_cum(idx60)*10^6,1);
old_60_unvacc = round(tt.verified_amount_not_vaccinated(idx60)./tt.not_vaccinated_amount_cum(idx60)*10^6,1);
old_60_inProccess = round(tt.verified_amount_vaccinated_procces(idx60)./tt.vaccinated_procces_amount_cum(idx60)*10^6,1);
young_60_vacc = round(tt.verified_amount_vaccinated(idxy)./tt.vaccinated_amount_cum(idxy)*10^6,1);
young_60_unvacc = round(tt.verified_amount_not_vaccinated(idxy)./tt.not_vaccinated_amount_cum(idxy)*10^6,1);
young_60_inProcess = round(tt.verified_amount_vaccinated_procces(idxy)./tt.vaccinated_procces_amount_cum(idxy)*10^6,1);
cases = table(date,old_60_unvacc,old_60_inProccess,old_60_vacc,young_60_unvacc,young_60_inProcess,young_60_vacc);
% writetable(cases,'~/covid-19-israel-matlab/data/Israel/cases_by_vacc_age.csv','Delimiter',',','WriteVariableNames',true);

delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');

figure;
yyaxis left
plot(cases.date,movmean(cases{:,[2,4,5,7]},[3 3]))
yyaxis right
plot(listD.date,movmean(listD.serious_critical_new,[3 3]))

legend('old 60 unvacc','young 60 vacc','young 60 unvacc','young 60 vacc','new severe')

