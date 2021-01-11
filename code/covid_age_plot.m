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
in = find(isnan(dash(:,1)))
if in(end) == length(dash)
    in(end) = [];
end
for iin = 1:length(in)
    dash(in(iin),:) = (dash(in(iin)-1,:)+dash(in(iin)+1,:))/2;
end
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
xtickformat('MMM')
subplot(1,2,2)
yyaxis left
plot(date(2:end),movmean(diff(dash(:,1)),[3 3],'omitnan'))
hold on
plot(tests.date,movmean(tests.pos_f-tests.pos_f_60+tests.pos_m-tests.pos_m_60,[3 3]))
ylabel('מאומתים צעירים')
yyaxis right
plot(date(2:end),movmean(diff(dash(:,2)),[3 3],'omitnan'))
hold on
plot(tests.date,movmean(tests.pos_f_60+tests.pos_m_60,[3 3]))
legend('לוח בקרה צעירים','מאגר מידע צעירים','לוח בקרה מבוגרים','מאגר מידע מבוגרים','location','northwest')
title('מאומתים- מבוגרים וצעירים מ- 60, נתונים מוחלקים ומנורמלים')
xlim([datetime(2020,10,1) datetime('today')+3])
grid on
box off
ylabel('מאומתים מבוגרים')
set(gcf,'Color','w')
xtickformat('MMM')
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
%%
figure;
yyaxis left
plot(date(2:end),movmean(diff(dash(:,1)),[3 3],'omitnan'))
hold on
plot(date(2:end),movmean(diff(dash(:,2)),[3 3],'omitnan'))
yyaxis right
plot(date(2:end),movmean(diff(dash(:,2)),[3 3],'omitnan')./movmean(diff(dash(:,1)),[3 3],'omitnan'))
xtickformat('MMM')
xlim([datetime(2020,10,10) datetime('today')])


%%

json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=6253ce68-5f31-4381-bb4e-557260d5c9fc&limit=1000');
json = jsondecode(json);
tsevet = struct2table(json.result.records);
tsevet = tsevet(:,2:end);
for ii = 2:7
    tsevet{ismember(tsevet{:,ii},'<15'),ii} = {''};
end
writetable(tsevet,'tmp.csv','Delimiter',',','WriteVariableNames',true);
tsevet = readtable('tmp.csv');
[~,order] = sort(tsevet.Date);
tsevet = tsevet(order,:);

!wget -O tmp.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/isolated_staff.csv
staff = readtable('tmp.csv');
staffDate = datetime(cellfun(@(x) x(1:end-5),strrep(staff.Date,'T',' '),'UniformOutput',false));
yDash = staff{:,2:5};
bad = sum(yDash,2) == 0;

%%
% json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=6253ce68-5f31-4381-bb4e-557260d5c9fc&limit=10000');
% json = jsondecode(json);
% daily = struct2table(json.result.records);
% daily = daily(:,2:end)
% for ii = 1:7
%     daily{ismember(daily{:,ii},'<15'),ii} = {''};
% end
% writetable(daily,'tmp.csv','Delimiter',',','WriteVariableNames',true);
% daily = readtable('tmp.csv');



figure;
% subplot(1,2,1)
plot(staffDate(~bad),yDash(~bad,1:2))
hold on
colorset
plot(tsevet.Date,tsevet{:,2:3},'--')
xtickformat('MMM')
xlim([datetime(2020,3,15) datetime('today')])
title(['מאומתים בצוות הרפואי עד ',datestr(tsevet.Date(end),'mmm-dd')])
box off
grid on
legend('רופאים (לוח בקרה)','אחיות (לוח בקרה)','רופאים (מאגר מידע)', 'אחיות (מאגר מידע)','location','northwest')
set(gcf,'Color','w')
xtickformat('MMM')
xlim([datetime(2020,6,15) datetime('today')+5])
title('צוות רפואי מאומת לפי לוח הבקרה ומאגר המידע')


figure;plot(staffDate(~bad),yDash(~bad,:))
legend('רופאים מאומתים','אחיות מאומתות','רופאים מבודדים','אחיות מבודדות')
box off
grid on
set(gcf,'Color','w')
xtickformat('MMM')
xlim([datetime(2020,6,15) datetime('today')])
title('צוות רפואי מאומת לפי לוח הבקרה')

%% 
tests = readtable('tests.csv');
figure;
yyaxis left;
plot(tests.date,tests.pos60);
yyaxis right;
plot(tests.date,tests.pos-tests.pos60)
xtickformat('MMM')
grid on
set(gcf,'Color','w')
title('מאומתים סימפטומטיים')
legend('מבוגרים מ 60','צעירים מ 60')

