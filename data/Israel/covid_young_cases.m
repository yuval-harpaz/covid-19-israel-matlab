function [pos,dateM,tests] = covid_age_perc_pos
cd ~/covid-19-israel-matlab/data/Israel
listD = readtable('dashboard_timeseries.csv');
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=89f61e3a-4866-4bbf-bcc1-9734e5fee58e&limit=10000');
json = jsondecode(json);
week = struct2table(json.result.records);
% week.weekly_newly_tested(ismember(week.weekly_newly_tested,'<15')) = {''};
week.weekly_cases(ismember(week.weekly_cases,'<15')) = {''};
week.weekly_deceased(ismember(week.weekly_deceased,'<15')) = {''};
week.weekly_tests_num(ismember(week.weekly_tests_num,'<15')) = {''};
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

yy = pos(:,1);
date = dateW;
date(end+1) = date(end)+7;
a=563+533+826+984;
yy(end+1) = a-907-554-94-15;
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
%%
figure;
yyaxis left
plot(date-3,yy)
ylabel('cases per week')
yyaxis right
plot(listD.date,listD.new_hospitalized)
ax = gca;
ax.YAxis(1).TickLabelFormat = '%,.0f';
ax.YRuler.Exponent = 0;
ylabel('hospitalized per day')
grid on
box off
set(gca,'xtick',datetime(2020,4:30,1))
xlim([datetime(2020,6,1),datetime('tomorrow')])
ylim([0 310])