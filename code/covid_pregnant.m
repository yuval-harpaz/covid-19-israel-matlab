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

week = week(ismember(week.gender,'נקבה'),:)

for ii = 1:length(dateW)
    for iAge = 1:14
        tests(ii,iAge) = nansum(week.weekly_tests_num(week.last_week_day == dateW(ii) &...
            ismember(week.age_group,ages(iAge))));%,nansum(week.weekly_newly_tested(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))]
        pos(ii,iAge) = nansum(week.weekly_cases(week.last_week_day == dateW(ii) &...
            ismember(week.age_group,ages(iAge))));
    end
end


%%
figure;
yyaxis left
bar(datetime(2020,3:13,1),[71,133,19,103,567,688,863,816,288,1238,2629],'EdgeColor','none')

yyaxis right
plot(dateM,sum(pos(:,2:5),2))
xtickformat('MMM')
grid on
xlim([dateM(1),listD.date(end)])
ylim([0 10000])
ax = gca;
ax.YAxis(1).TickLabelFormat = '%,.0f';
ax.YAxis(2).TickLabelFormat = '%,.0f';
% ax.YRuler.Exponent = 0;
legend('נשים בהריון חיוביות לקורנה לחודש','נשים חיוביות בגיל 20-40')
title({'positive pregnant women per month (blue)','vs all positive women per week (red)'})
set(gcf,'Color','w')
%%
% dateM = dateW-3.5;
% idx = [1:7;8:14];
% agetit = {'צעירים','מבוגרים'};
% figure;
% % plot(dateM,pos./tests)
% for ip = 1:2
%     subplot(1,2,ip)
%     plot(dateM,100*pos(:,idx(ip,:))./tests(:,idx(ip,:)));
%     legend(ages(idx(ip,:)),'Location','northwest');
%     xtickformat('MMM');
%     xlim([datetime(2020,10,1) datetime('tomorrow')]);
%     ylim([0 25])
%     grid on;
%     box off
%     title(['אחוז הבדיקות החיוביות ל',agetit{ip}])
%     grid minor
% end
% set(gcf,'Color','w')
% 
% %%
% ps = covid_israel_percent_positive;
% close;
% close;
% close;
% %%
% figure;
% h1 = plot(dateM,100*pos./tests);
% hold on
% h2 = plot(ps.dateSmooth,ps.posSmooth,'r','linewidth',2);
% h3 = plot(listD.date(1:end-1),movmean(listD.new_hospitalized(1:end-1),[3 3])/23,'b','linewidth',2);
% xtickformat('MMM')
% grid on
% xlim([dateM(1),listD.date(end)])
% legend([h3,h2],'מאושפזים חדשים (מנורמל)','אחוז הבדיקות החיוביות לכל האוכלוסיה')
% ylabel('%')
% title('אחוז הבדיקות החיוביות לפי גיל, מול אישפוזים חדשים')
% set(gcf,'Color','w')
% ylim([0 25])
% grid minor