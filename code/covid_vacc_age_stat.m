json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedDaily');
json = jsondecode(json);
date = cellfun(@(x) datetime(x(1:10)),{json.day_date}');
tt = struct2table(json);
idx60 = find(ismember(tt.age_group,'מעל גיל 60'));
idxy = find(ismember(tt.age_group,'מתחת לגיל 60'));
old_60_vacc = round(tt.verified_amount_vaccinated(idx60)./tt.vaccinated_amount_cum(idx60)*10^6,1);
old_60_unvacc = round(tt.verified_amount_not_vaccinated(idx60)./tt.not_vaccinated_amount_cum(idx60)*10^6,1);
young_60_vacc = round(tt.verified_amount_vaccinated(idxy)./tt.vaccinated_amount_cum(idxy)*10^6,1);
young_60_unvacc = round(tt.verified_amount_not_vaccinated(idxy)./tt.not_vaccinated_amount_cum(idxy)*10^6,1);
yy = [old_60_unvacc,old_60_vacc,young_60_unvacc,young_60_vacc];
yy(yy == 0) = nan;
yy = movmean(yy,[3 3]);
figure;
plot(date(idx60),yy)
legend('vacc 60+','unvacc 60+','vacc <60','unvacc <60')