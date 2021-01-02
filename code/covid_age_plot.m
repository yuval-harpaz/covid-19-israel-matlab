cd ~/covid-19-israel-matlab/data/Israel
agegen = readtable('dashboard_age_gen.csv');
tests = readtable('tests.csv');
date = unique(dateshift(agegen.date,'start','day'));
clear dash
for ii = 1:length(date)
    dash(ii,1:2) = [sum(max(agegen{agegen.date > date(ii) & agegen.date < date(ii)+1,2:13})),...
        sum(max(agegen{agegen.date > date(ii) & agegen.date < date(ii)+1,14:21}))];
end
dash(dash(:,1) < 150000,:) = nan;
%%
figure('position',[0,0,1200,700]);
subplot(1,2,1)
h(1:2) = plot(tests.date,[tests.pos_f-tests.pos_f_60+tests.pos_m-tests.pos_m_60,tests.pos_f_60+tests.pos_m_60]);
hold on
h(3:4) = plot(date(2:end),diff(dash));
legend(h([3,1,4,2]),'לוח בקרה צעירים','מאגר מידע צעירים','לוח בקרה מבוגרים','מאגר מידע מבוגרים','location','northwest')
title('מאומתים מבוגרים וצעירים מ- 60, נתונים גולמיים')
grid on
box off
subplot(1,2,2)
yyaxis left
plot(date(2:end),movmean(diff(dash(:,1)),[3 3],'omitnan'))
hold on
plot(tests.date,movmean(tests.pos_f-tests.pos_f_60+tests.pos_m-tests.pos_m_60,[3 3]))
yyaxis right
plot(date(2:end),movmean(diff(dash(:,2)),[3 3],'omitnan'))
hold on
plot(tests.date,movmean(tests.pos_f_60+tests.pos_m_60,[3 3]))
legend('לוח בקרה צעירים','מאגר מידע צעירים','לוח בקרה מבוגרים','מאגר מידע מבוגרים','location','northwest')
title('מאומתים- נתונים מוחלקים ומנורמלים')
xlim([datetime(2020,10,1) datetime('today')+3])
grid on
box off
%%

json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=89f61e3a-4866-4bbf-bcc1-9734e5fee58e&limit=10000');
json = jsondecode(json);
week = struct2table(json.result.records);
week.weekly_newly_tested(ismember(week.weekly_newly_tested,'<15')) = {''};
week.weekly_cases(ismember(week.weekly_cases,'<15')) = {''};
week.weekly_deceased(ismember(week.weekly_deceased,'<15')) = {''};
week.weekly_tests_num(ismember(week.weekly_tests_num,'<15')) = {''};
writetable(week,'tmp.csv','Delimiter',',','WriteVariableNames',true);
week = readtable('tmp.csv');
dateW = unique(week.last_week_day);
ages = unique(week.age_group);
for ii = 1:length(dateW)
    casesYO(ii,1:2) = [nansum(week.weekly_cases(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(1:9)))),...
        nansum(week.weekly_cases(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))];
    deathsYO(ii,1:2) = [nansum(week.weekly_deceased(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(1:9)))),...
        nansum(week.weekly_deceased(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))];
end
figure;
yyaxis left
plot(dateW,casesYO/1000)
ylim([0 40])
ylabel('מאומתים לשבוע (באלפים)')
yyaxis right
plot(dateW,100*casesYO(:,2)./casesYO(:,1))
xlim([datetime(2020,6,20) datetime('today')])
ylim([0 40])
ylabel('שיעור המאומתים מעל גיל 60 (באחוזים)')
xtickformat('MMM')
box off
grid on
% figure;plot(dateW,deathsYO)