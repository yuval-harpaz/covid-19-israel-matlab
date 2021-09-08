function covid_age_mult
% delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);
!python ~/covid-19-israel-matlab/code/vaccinated_cases.py
ver = readtable('~/covid-19-israel-matlab/data/Israel/VerfiiedVaccinationStatusDaily.csv');
date = datetime(ver.day_date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

[posOld, posYoung, dateW] = getTimna60;
idx = find(ismember(ver.age_group,'מעל גיל 60'));
idx = idx(1:end-1);
ydx = find(ismember(ver.age_group,'מתחת לגיל 60'));
ydx = ydx(1:end-1);

figure;
plot(date(idx),movmean(sum(ver{idx,4:6},2),[3 3]))
hold on
plot(dateW-3,posOld/7)
plot(date(ydx),movmean(sum(ver{ydx,4:6},2),[3 3]))
plot(dateW-3,posYoung/7)
xlim([datetime(2021,6,1),datetime('today')])
% extraDays = find(date>dateW(end));
% extraDays = extraDays(7:7:end);
% dateW(1
yy = movmean([ver{ydx,4:6},ver{idx,4:6}],[3 3]);
yyNorm = movmean([ver{ydx,7:9},ver{idx,7:9}],[3 3]);
mult = nan(size(yy));
mult(8:end,:) = yy(8:end,:)./yy(1:end-7,:);
multNorm = nan(size(yyNorm));
multNorm(8:end,:) = yyNorm(8:end,:)./yyNorm(1:end-7,:);
multNorm(1:213,1) = nan;
multNorm(1:198,4) = nan;
figure;
plot(date(ydx),yy)


figure;
plot(date(ydx),mult)
xlim([datetime(2021,6,1),datetime('today')])
top = [25,3];
date1 = [datetime(2021,6,1),datetime(2021,7,1)];
figure;
for ii = 1:2
    subplot(2,1,ii)
    plot(date(ydx),multNorm)
    xlim([date1(ii),datetime('today')])
    ylim([0 top(ii)]);
    grid on
    if ii == 1
        legend('<60 dose III','<60 dose II','<60 no vax','60+ dose III','60+ dose II','60+ no vax');
        title('Weekly multiplication factor  מקדם הכפלה שבועי')
    else
        title('zoom in')
    end
end

function [posOld, posYoung, dateW] = getTimna60
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
posOld = sum(pos(:,10:14),2);
posYoung = sum(pos(:,1:9),2);


% tt = struct2table(json);
% json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedByAge');
% json = jsondecode(json);
% tAge = struct2table(json);
% 
% json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
% json = jsondecode(json);
% tv = struct2table(json);
% 
% idx60 = find(ismember(tt.age_group,'מעל גיל 60'));
% idxy = find(ismember(tt.age_group,'מתחת לגיל 60'));
% if isequal(date(idxy),unique(date))
%     date = date(idxy);
% else
%     error('bad dates')
% end

% [pos60w, dateW] = getTimna60;
% old_60_unvacc = movmean(tt.verified_amount_not_vaccinated(idx60),[3 3]);

% listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');

% 
% old_60_unvacc_norm = old_60_unvacc./tt.not_vaccinated_amount_cum(idx60)*10^6;
% w = ones(size(pos60w_norm))*tt.not_vaccinated_amount_cum(idx60(1));
% wtmp = tt.not_vaccinated_amount_cum(idx60(3:7:end));
% w(41:end) = wtmp(1:length(w)-40);
% pos60w_norm = pos60w/7./w*10^6;  % /tt.not_vaccinated_amount_cum(idx60(1))*10^6;
% 
% figure;
% plot(date,movmean(old_60_unvacc_norm,[3 3])/20);
% hold on
% % plot(dateW-3,pos60w_norm)
% plot(listD.date-14,movmean(listD.CountDeath,[3 3]),'k')
