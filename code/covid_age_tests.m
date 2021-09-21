function covid_age_tests
% [posDash, dateD] = get_dashboard;

[pos, tests, dateW, ages] = getTimna;
[posY, testsY, dateY, agesY] = getTimnaY;
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
yy = [testsY,tests(:,2:end)];
figure;
bar(dateW-3,yy,'stacked','EdgeColor','none')
hold on
% plot(listD.date,movsum(listD.tests,[3 3]),'r','linewidth',2);
plot(listD.date(1:end-8),movsum(listD.tests1(1:end-8),[3 3]),'k','linewidth',2);

yypos = [posY,pos(:,2:end)];
figure;
bar(dateW-3,yypos,'stacked','EdgeColor','none')
hold on
% plot(listD.date,movsum(listD.tests,[3 3]),'r','linewidth',2);
plot(listD.date(1:end-8),movsum(listD.tests_positive1(1:end-8),[3 3]),'k','linewidth',2);

yl = movsum(listD.tests_positive1(1:end-8),[3 3]);
figure;
hp = bar(dateW-3,yypos./sum(yypos,2)*100,1,'stacked','EdgeColor','none');
hold on
% plot(listD.date,movsum(listD.tests,[3 3]),'r','linewidth',2);
ylim([0 100])
plot(listD.date(1:end-8),yl./max(yl)*100,'k','linewidth',2);
legend(fliplr(hp),flipud([agesY;ages(2:end-1)]))

xlim([dateW(1)-3 datetime('today')-3]);
title('cases by age  (%)  מאומתים לפי גיל')
set(gcf,'Color','w')


perc = yypos./yy*100;

figure;
h = plot(dateW-3,perc);
legend([agesY;ages(2:end-1)])
xlim([dateW(1)-3 datetime('today')-3]);
title('percent positive by age   מאומתים לפי גיל')
grid on
h(7).LineWidth = 2;
h(8).LineWidth = 2;
h(9).LineWidth = 2;
set(gcf,'Color','w')


function [pos, tests, dateW, ages] = getTimna
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
% pos20 = [pos(:,1),sum(pos(:,2:5),2),sum(pos(:,6:9),2),sum(pos(:,10:13),2),pos(:,14)];
% posYoung = sum(pos(:,1:9),2);

function [pos, tests, date, ages] = getTimnaY
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=767ffb4e-a473-490d-be80-faac0d83cae7&limit=10000');
json = jsondecode(json);
week = struct2table(json.result.records);
% week.weekly_newly_tested(ismember(week.weekly_newly_tested,'<15')) = {''};
week.weekly_cases(ismember(week.weekly_cases,'<15')) = {'2'};
week.weekly_newly_tested(ismember(week.weekly_newly_tested,'<15')) = {'2'};
week.weekly_tests_num(ismember(week.weekly_tests_num,'<15')) = {'2'};
week.last_week_day = strrep(week.last_week_day,'T00:00:00','');
% week.weekly_tests_num(ismember(week.weekly_tests_num,'<15')) = {'2'};
writetable(week,'tmp.csv','Delimiter',',','WriteVariableNames',true);
week = readtable('tmp.csv');
% week0(ismember(week0.last_week_day,week.last_week_day),:) = [];
% week = [week0;week];
date = unique(week.last_week_day);
ages = unique(week.age_group);
ages = ages([1,5,6,7,2,3,4]);
for ii = 1:length(date)
    for iAge = 1:7
        tests(ii,iAge) = nansum(week.weekly_tests_num(week.last_week_day == date(ii) &...
            ismember(week.age_group,ages(iAge))));%,nansum(week.weekly_newly_tested(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))]
        pos(ii,iAge) = nansum(week.weekly_cases(week.last_week_day == date(ii) &...
            ismember(week.age_group,ages(iAge))));
    end
end
a=1;
