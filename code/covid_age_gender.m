function covid_age_gender

[posDash, dateD] = get_dashboard;
dd = dateshift(dateD,'start','day');
dU = unique(dd);
sunday = dU(10);
sunday = sunday:7:dU(end);
end7 = unique([sunday';dU(end)]);
dash = nan(size(end7,1),4);
for iWeek = 1:length(end7)
    start = find(dd == end7(iWeek)-7,1,'last');
    wend = find(dd == end7(iWeek),1,'last');
    if ~isempty(start) && ~isempty(wend)
        dash(iWeek,:) = posDash(wend,:)-posDash(start,:);
    end
end
dash(59,:) = [];
end7(59) = [];
dash(dash < 0) = 0;
figure;
hh = plot(end7-3,dash,'r','LineWidth',2);
set(gca,'FontSize',13,'Xtick',datetime(2020,1:50,1))
grid on
ax = gca;
ax.YRuler.Exponent = 0;
xlim([end7(1)-3,datetime('today')])
xtickformat('MMM')
legend(' 0-10 male','10-20 male',' 0-10 female','10-20 female','location',[0.65,0.55,0.05,0.1])
title('weekly cases by age')
set(gcf,'Color','w')
hh(1).Color = 'b';
hh(1).LineStyle = ':';
hh(2).Color = 'b';
hh(3).LineStyle = ':';

% ratio = [max(dash(55:end,:))./max(dash(25:35,:))]';
% figure;
% for ii = 1:10
%     bar(ii,100*ratio(ii),'EdgeColor','none','FaceColor',hh(ii).Color)
%     hold on
% end
% set(gca,'ygrid','on','Xtick',1:10,...
%     'XTickLabel',{'0-10','10-20','20-30','30-40','40-50','50-60','60-70','70-80','80-90','90+'})
% title('max(wave 4)/max(wave 3)')
% ylabel('%')
% box off
% set(gcf,'Color','w')
% 
% 
% %%
% stc = struct2table(webread('https://datadashboardapi.health.gov.il/api/queries/vaccinationsPerAge'));
% figure;
% bar(0,100,'EdgeColor','none','FaceColor',hh(1).Color);
% hold on
% bar(1,100-stc.persent_vaccinated_second_dose(ii),'EdgeColor','none','FaceColor',hh(2).Color);
% for ii = 2:10
%     bar(ii,100-stc.percent_vaccinated_first_dose(ii),'EdgeColor','none','FaceColor',hh(ii).Color);
% end
% set(gca,'ygrid','on','Xtick',0:10,...
%     'XTickLabel',[{'0-11'};stc.age_group])
% ylabel('%')
% box off
% set(gcf,'Color','w')
% title('not vaccinated (0 or 1 doses)')
function [pos, date] = get_dashboard
txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/ages_dists.csv');
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
pos = ag{:,[12,13,22,23]};
% pos = sum(ag{:,2:3},2);
% pos(:,2) = sum(ag{:,4:5},2);
% pos(:,3) = sum(ag{:,6:7},2);
% pos(:,4) = sum(ag{:,8:9},2);
% pos(:,5) = sum(ag{:,10:11},2);
date = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);

%%
% for ii = 1:2
%     figure;
%     subplot(3,1,1)
%     plot(dateT,merged,'LineWidth',1)
%     title('weekly cases by age')
%     set(gca,'FontSize',13,'Xtick',datetime(2020,1:50,1))
%     grid on
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     xlim([date1,datetime('today')])
%     xtickformat('MMM')
%     legend('0-20','20-40','40-60','60-80','80+','location',[0.7,0.8,0.05,0.1])
%     if ii == 1
%         xlim([date1,datetime('today')])
% %         ylim([0 6])
%     else
%         xlim([datetime(2021,6,15),datetime('today')])
% %         ylim([0 2])
% %         grid minor
%     end
%     subplot(3,1,2)
%     plot(dateT,merged,'LineWidth',1)
%     title('weekly cases by age (log)')
%     set(gca,'YScale','log','FontSize',13,'Xtick',datetime(2020,1:50,1))
%     grid on
%     xlim([date1,datetime('today')])
%     xtickformat('MMM')
%     if ii == 1
%         xlim([date1,datetime('today')])
% %         ylim([0 6])
%     else
%         xlim([datetime(2021,6,15),datetime('today')])
% %         ylim([0 2])
% %         grid minor
%     end
%     subplot(3,1,3)
%     plot(dateT,mult,'LineWidth',1)
%     grid on
%     title('weekly multiplication factor')
%     set(gca,'FontSize',13,'YTick',0:6,'Xtick',datetime(2020,1:50,1))
%     xtickformat('MMM')
%     set(gcf,'Color','w')
%     if ii == 1
%         xlim([date1,datetime('today')])
%         ylim([0 6])
%     else
%         xlim([datetime(2021,6,15),datetime('today')])
%         ylim([0 2])
%     end
% end


% function [pos20, dateW] = getTimna20
% json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=89f61e3a-4866-4bbf-bcc1-9734e5fee58e&limit=10000');
% json = jsondecode(json);
% week = struct2table(json.result.records);
% % week.weekly_newly_tested(ismember(week.weekly_newly_tested,'<15')) = {''};
% week.weekly_cases(ismember(week.weekly_cases,'<15')) = {'2'};
% week.weekly_deceased(ismember(week.weekly_deceased,'<15')) = {'2'};
% week.weekly_tests_num(ismember(week.weekly_tests_num,'<15')) = {'2'};
% writetable(week,'tmp.csv','Delimiter',',','WriteVariableNames',true);
% week = readtable('tmp.csv');
% % week0(ismember(week0.last_week_day,week.last_week_day),:) = [];
% % week = [week0;week];
% dateW = unique(week.last_week_day);
% ages = unique(week.age_group);
% for ii = 1:length(dateW)
%     for iAge = 1:14
%         tests(ii,iAge) = nansum(week.weekly_tests_num(week.last_week_day == dateW(ii) &...
%             ismember(week.age_group,ages(iAge))));%,nansum(week.weekly_newly_tested(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))]
%         pos(ii,iAge) = nansum(week.weekly_cases(week.last_week_day == dateW(ii) &...
%             ismember(week.age_group,ages(iAge))));
%     end
% end
% pos20 = [pos(:,1),sum(pos(:,2:5),2),sum(pos(:,6:9),2),sum(pos(:,10:13),2),pos(:,14)];
% % posYoung = sum(pos(:,1:9),2);

