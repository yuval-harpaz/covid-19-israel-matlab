function [pos,dateM,tests] = covid_age_perc_pos
cd ~/covid-19-israel-matlab/data/Israel
listD = readtable('dashboard_timeseries.csv');
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

%%
dateM = dateW-3.5;
idx = [1:7;8:14];
agetit = {'צעירים','מבוגרים';'young','old'};

figure;
% plot(dateM,pos./tests)
for ip = 1:2
    subplot(1,2,ip)
    plot(dateM,100*pos(:,idx(ip,:))./tests(:,idx(ip,:)));
    legend(ages(idx(ip,:)),'Location','northwest');
    xtickformat('MMM');
%     xlim([datetime(2020,10,1) datetime('tomorrow')]);
    xlim([datetime(2020,3,1) datetime('today')+7])
    set(gca,'xtick',datetime(2020,3:30,1))
    ylim([0 20])
    grid on;
    box off
    title({['אחוז הבדיקות החיוביות ל',agetit{1,ip}],['percent positive tests for the ',agetit{2,ip}]})
    grid minor
end
set(gcf,'Color','w')

%%
ps = covid_israel_percent_positive;
% close;
close;
close;
%%
figure;
h1 = plot(dateM,100*pos./tests);
hold on
h2 = plot(ps.dateSmooth,ps.posSmooth,'r','linewidth',2);
h3 = plot(listD.date(1:end-1),movmean(listD.new_hospitalized(1:end-1),[3 3])/23,'b','linewidth',2);
xtickformat('MMM')
grid on
xlim([dateM(1),listD.date(end)])
legend([h3,h2],'מאושפזים חדשים (מנורמל)','אחוז הבדיקות החיוביות לכל האוכלוסיה')
ylabel('%')
title('אחוז הבדיקות החיוביות לפי גיל, מול אישפוזים חדשים')
set(gcf,'Color','w')
ylim([0 25])
grid minor