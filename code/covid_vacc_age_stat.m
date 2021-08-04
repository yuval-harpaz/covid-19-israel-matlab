json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedDaily');
json = jsondecode(json);
date = cellfun(@(x) datetime(x(1:10)),{json.day_date}');
tt = struct2table(json);
idx60 = find(ismember(tt.age_group,'מעל גיל 60'));
idxy = find(ismember(tt.age_group,'מתחת לגיל 60'));


figure;
for ii = 15:17
    plot(date(idx60),tt{idx60,ii})
	hold on
end
legend(strrep(tt.Properties.VariableNames(15:17),'_',' '))
if isequal(date(idxy),unique(date))
    date = date(idxy);
else
    error('bad dates')
end
old_60_vacc = round(tt.verified_amount_vaccinated(idx60)./tt.vaccinated_amount_cum(idx60)*10^6,1);
old_60_unvacc = round(tt.verified_amount_not_vaccinated(idx60)./tt.not_vaccinated_amount_cum(idx60)*10^6,1);
old_60_inProccess = round(tt.verified_amount_vaccinated_procces(idx60)./tt.vaccinated_procces_amount_cum(idx60)*10^6,1);
young_60_vacc = round(tt.verified_amount_vaccinated(idxy)./tt.vaccinated_amount_cum(idxy)*10^6,1);
young_60_unvacc = round(tt.verified_amount_not_vaccinated(idxy)./tt.not_vaccinated_amount_cum(idxy)*10^6,1);
young_60_inProcess = round(tt.verified_amount_vaccinated_procces(idxy)./tt.vaccinated_procces_amount_cum(idxy)*10^6,1);
yy = [old_60_unvacc,old_60_vacc,young_60_unvacc,young_60_vacc];
yy(yy == 0) = nan;
yy = movmean(yy,[3 3]);
figure;
plot(date,yy)
legend('vacc 60+','unvacc 60+','vacc <60','unvacc <60')
ylabel('cases per million')
title('chances for positive by vaccination status and age group')

cases = table(date,old_60_unvacc,old_60_inProccess,young_60_vacc,young_60_unvacc,young_60_inProcess,young_60_vacc);
writetable(cases,'~/covid-19-israel-matlab/data/Israel/cases_by_vacc_age.csv','Delimiter',',','WriteVariableNames',true);



%% severe
clear old* young*
old_60_vacc = round(tt.Serious_amount_vaccinated(idx60)./tt.vaccinated_amount_cum(idx60)*10^6,1);
old_60_unvacc = round(tt.Serious_amount_not_vaccinated(idx60)./tt.not_vaccinated_amount_cum(idx60)*10^6,1);
old_60_inProccess = round(tt.Serious_amount_vaccinated_procces(idx60)./tt.vaccinated_procces_amount_cum(idx60)*10^6,1);
young_60_vacc = round(tt.Serious_amount_vaccinated(idxy)./tt.vaccinated_amount_cum(idxy)*10^6,1);
young_60_unvacc = round(tt.Serious_amount_not_vaccinated(idxy)./tt.not_vaccinated_amount_cum(idxy)*10^6,1);
young_60_inProcess = round(tt.Serious_amount_vaccinated_procces(idxy)./tt.vaccinated_procces_amount_cum(idxy)*10^6,1);
yy = [old_60_unvacc,old_60_vacc,young_60_unvacc,young_60_vacc];
yy(yy == 0) = nan;
yy = movmean(yy,[3 3]);
figure;
plot(date,yy)
legend('vacc 60+','unvacc 60+','vacc <60','unvacc <60')
ylabel('severe per million')
title('ratio of severe by vaccination status and age group')

severe = table(date,old_60_unvacc,old_60_inProccess,young_60_vacc,young_60_unvacc,young_60_inProcess,young_60_vacc);
writetable(cases,'~/covid-19-israel-matlab/data/Israel/cases_by_vacc_age.csv','Delimiter',',','WriteVariableNames',true);