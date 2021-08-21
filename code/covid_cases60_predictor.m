function covid_cases60_predictor
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

% figure;
% plot(date,tt.Serious_not_vaccinated_normalized(idx60))
% hold on
% plot(date,tt.Serious_vaccinated_procces_normalized(idx60))
% plot(date,tt.Serious_vaccinated_normalized(idx60))
% legend('no vacc','vacc in proccess','vacc')
% title('Severe')
% 
% fac = 1.6;
% lag = 4;
% figure;
% plot(date+lag,movmean(fac*tt.verified_not_vaccinated_normalized(idxy),[3 3]))
% hold on
% plot(listD.date,movmean(listD.serious_critical_new,[3 3]))
% plot(date,movmean(fac*tt.verified_not_vaccinated_normalized(idx60),[3 3]))


%old_60_vacc = round(tt.verified_amount_vaccinated(idx60)./tt.vaccinated_amount_cum(idx60)*10^6,1);
% old_60_unvacc = round(tt.verified_amount_not_vaccinated(idx60)./tt.not_vaccinated_amount_cum(idx60)*10^6,1);
% old_60_inProccess = round(tt.verified_amount_vaccinated_procces(idx60)./tt.vaccinated_procces_amount_cum(idx60)*10^6,1);
% young_60_vacc = round(tt.verified_amount_vaccinated(idxy)./tt.vaccinated_amount_cum(idxy)*10^6,1);
% young_60_unvacc = round(tt.verified_amount_not_vaccinated(idxy)./tt.not_vaccinated_amount_cum(idxy)*10^6,1);
% young_60_inProcess = round(tt.verified_amount_vaccinated_procces(idxy)./tt.vaccinated_procces_amount_cum(idxy)*10^6,1);
% cases = table(date,old_60_unvacc,old_60_inProccess,old_60_vacc,young_60_unvacc,young_60_inProcess,young_60_vacc);
% % writetable(cases,'~/covid-19-israel-matlab/data/Israel/cases_by_vacc_age.csv','Delimiter',',','WriteVariableNames',true);

% delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);
% listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');

% figure;
% yyaxis left
% plot(cases.date,movmean(cases{:,[2,4,5,7]},[3 3]))
% yyaxis right
% plot(listD.date,movmean(listD.serious_critical_new,[3 3]))
% 
% legend('old 60 unvacc','young 60 vacc','young 60 unvacc','young 60 vacc','new severe')
[pos60w, dateW] = getTimna60;
old_60_unvacc = movmean(tt.verified_amount_not_vaccinated(idx60),[3 3]);
% figure;
% plot(date,old_60_unvacc);
% hold on
% plot(dateW-3,pos60w/7)
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');


old_60_unvacc_norm = old_60_unvacc./tt.not_vaccinated_amount_cum(idx60)*10^6;
w = ones(size(pos60w_norm))*tt.not_vaccinated_amount_cum(idx60(1));
wtmp = tt.not_vaccinated_amount_cum(idx60(3:7:end));
w(41:end) = wtmp(1:length(w)-40);
pos60w_norm = pos60w/7./w*10^6;  % /tt.not_vaccinated_amount_cum(idx60(1))*10^6;

figure;
plot(date,movmean(old_60_unvacc_norm,[3 3])/20);
hold on
% plot(dateW-3,pos60w_norm)
plot(listD.date-14,movmean(listD.CountDeath,[3 3]),'k')

function [pos60w, dateW] = getTimna60
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=89f61e3a-4866-4bbf-bcc1-9734e5fee58e&limit=10000');
json = jsondecode(json);
week = struct2table(json.result.records);
% week.weekly_newly_tested(ismember(week.weekly_newly_tested,'<15')) = {''};
week.weekly_cases(ismember(week.weekly_cases,'<15')) = {'2'};
week.weekly_deceased(ismember(week.weekly_deceased,'<15')) = {'2'};
week.weekly_tests_num(ismember(week.weekly_tests_num,'<15')) = {'2'};
writetable(week,'tmp.csv','Delimiter',',','WriteVariableNames',true);
week = readtable('tmp.csv');
% week0(ismember(week0.last_week_day,week.last_week_day),:) = [];
% week = [week0;week];
dateW = unique(week.last_week_day);
ages = unique(week.age_group);
for ii = 1:length(dateW)
    for iAge = 1:14
        tests(ii,iAge) = nansum(week.weekly_tests_num(week.last_week_day == dateW(ii) &...
            ismember(week.age_group,ages(iAge))));%,nansum(week.weekly_newly_tested(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))]
        pos(ii,iAge) = nansum(week.weekly_cases(week.last_week_day == dateW(ii) &...
            ismember(week.age_group,ages(iAge))));
    end
end
pos60w = sum(pos(:,12:14),2);
