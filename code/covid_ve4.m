% json = urlread('https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily');
% json = jsondecode(json);
% deaths = struct2table(json);
% deaths.day_date = datetime(strrep(deaths.day_date,'T00:00:00.000Z',''));
% deaths.Properties.VariableNames{1} = 'date';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily');
json = jsondecode(json);
severe = struct2table(json);
severe.day_date = datetime(strrep(severe.day_date,'T00:00:00.000Z',''));
severe.Properties.VariableNames{1} = 'date';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily');
json = jsondecode(json);
cases = struct2table(json);
cases.day_date = datetime(strrep(cases.day_date,'T00:00:00.000Z',''));
cases.Properties.VariableNames{1} = 'date';

dOld = ismember(severe.age_group,'מעל גיל 60');
cOld = ismember(cases.age_group,'מעל גיל 60');

cases = cases(cOld,:);
severe = severe(cOld,:);
period = find(cases.date == datetime(2022,1,10)):find(cases.date == datetime(2022,3,2));
period_severe = find(cases.date == datetime(2022,1,10)):find(cases.date == datetime(2022,2,18));
pop = cases.verified_amount_not_vaccinated./cases.verified_not_vaccinated_normalized;
persons_days = round(sum(pop(period).*10^5));
un_cases = sum(cases.verified_amount_not_vaccinated(period));
un_severe = sum(severe.new_serious_amount_not_vaccinated(period_severe));
persons_days_sev = round(sum(pop(period_severe).*10^5));
% https://www.nejm.org/doi/full/10.1056/NEJMoa2201570?query=featured_home
person_days_infected = [persons_days; 31000299;2717489;sum([4181768;4041309;3883824;3701580;3479549;3040564;1547985])];
infected = [un_cases; 111780;10531;sum([12840;8926;7225;5611;3686;2666 ;1304])];
person_days_severe = [persons_days_sev; 24857976;2673746;sum([4073168;3868314;3639393;3277662;2133014])];
severe = [un_severe; 1210; 114; sum([125; 99; 66; 47; 18])];
group = {'unvaccinated';'3 doses';'4 doses internal';'4 doses week 2 to 8'};
tt = table(group,infected,person_days_infected,severe,person_days_severe);


ve_infec = 100*(1-(tt.infected(2:end)./tt.person_days_infected(2:end))./(tt.infected(1)./tt.person_days_infected(1)));
ve_sev = 100*(1-(tt.severe(2:end)./tt.person_days_severe(2:end))./(tt.severe(1)./tt.person_days_severe(1)));
figure;
bar([ve_infec,ve_sev],'EdgeColor','none')
ylim([-10 100])
set(gca,'XTickLabel',group(2:end),'YGrid','on');
box off
title({'VE for 3 and 4 doses of COVID19 vaccine','',''})
legend('infections','severe ilness')
set(gcf,'Color','w')

% figure;
% plot((tt.infected(2)./tt.person_days_infected(2)) ./ (tt.infected(3:end)./tt.person_days_infected(3:end)))
