cd ~/covid-19-israel-matlab/data/Israel

json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=eea57b2e-2d00-4569-b768-1386abe6bb5d&limit=50000');
json = jsondecode(json);
week0 = struct2table(json.result.records);
week0.weekly_newly_tested(cellfun(@isempty, week0.weekly_newly_tested)) = {''};
week0.weekly_newly_tested(ismember(week0.weekly_newly_tested,'<15')) = {''};
week0.weekly_cases(cellfun(@isempty, week0.weekly_cases)) = {''};
week0.weekly_cases(ismember(week0.weekly_cases,'<15')) = {''};
week0.weekly_deceased(cellfun(@isempty, week0.weekly_deceased)) = {''};
week0.weekly_deceased(ismember(week0.weekly_deceased,'<15')) = {''};
week0.weekly_tests_num(cellfun(@isempty, week0.weekly_tests_num)) = {''};
week0.weekly_tests_num(ismember(week0.weekly_tests_num,'<15')) = {''};
week0(cellfun(@isempty,week0.first_week_day),:) = [];
writetable(week0,'tmp.csv','Delimiter',',','WriteVariableNames',true);
week0 = readtable('tmp.csv');
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=89f61e3a-4866-4bbf-bcc1-9734e5fee58e&limit=10000');
json = jsondecode(json);
week = struct2table(json.result.records);
week.weekly_newly_tested(ismember(week.weekly_newly_tested,'<15')) = {''};
week.weekly_cases(ismember(week.weekly_cases,'<15')) = {''};
week.weekly_deceased(ismember(week.weekly_deceased,'<15')) = {''};
week.weekly_tests_num(ismember(week.weekly_tests_num,'<15')) = {''};
writetable(week,'tmp.csv','Delimiter',',','WriteVariableNames',true);
week = readtable('tmp.csv');
week0(ismember(week0.last_week_day,week.last_week_day),:) = [];
week = [week0;week];
dateW = unique(week.last_week_day);
ages = unique(week.age_group);
clear casesYO deathsYO testsYO
for ii = 1:length(dateW)
    casesYO(ii,1:2) = [nansum(week.weekly_cases(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(1:9)))),...
        nansum(week.weekly_cases(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))];
    deathsYO(ii,1:2) = [nansum(week.weekly_deceased(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(1:9)))),...
        nansum(week.weekly_deceased(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))];
    testsYO(ii,1:2) = [nansum(week.weekly_newly_tested(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(1:9)))),...
        nansum(week.weekly_newly_tested(week.last_week_day == dateW(ii) & ismember(week.age_group,ages(10:14))))];
end

%% daily
% dateM = [dateW-3.5;dateW(end)];
dateM = dateW-3.5;
% casesYOM = [casesYO;casesYO(end,:)+((casesYO(end,:)-casesYO(end-1,:))/2)];
% casesYOM = casesYO;
txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/ages_dists.csv');
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
agDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
casesYOday = [sum(ag{:,[2:7,12:17]},2),sum(ag{:,[8:11,18:21]},2)];

% complete = agDate(iBefore)+7:7:agDate(end);
% % for ii = 1:length(ii)-1
% %     completeYO = casesYOday(
% if ~isempty(complete)
%     error('fix for more than 1 week delay')
% end
% end
iBefore = find(agDate < agDate(end)-2,1,'last');
YOlast = (casesYOday(end,:)-casesYOday(iBefore,:));%./datenum((agDate(end)-agDate(iBefore)))*7;
% YOlast = YOlast/datenum((agDate(end)-agDate(iBefore)))*7;
xx = [dateM;agDate(end)];
yy = casesYO/1000;
yy(7,:) = nan;
rat = 100*yy(:,2)./yy(:,1);
rat(end+1) = YOlast(2)/YOlast(1)*100;
xx(8:13) = [];
yy(8:13,:) = [];
rat(8:13) = [];
xtk = datestr(xx);
xtk(:,7:end) = [];
xtk(7,:) = ' ';

% good = true(size(xx));
% good(7:13) = false;
figure;
yyaxis left
h1 = plot(yy(1:end,:));
% colorset;
% hold on
% plot(length(xx)-1:length(xx), yy(end-1:end,:),':')
% ylim([0 50])
ylabel('מאומתים לשבוע (באלפים)')
yyaxis right
h2 = plot(rat);
% xlim([datetime(2020,6,20) datetime('today')])
ylim([0 30])
xlim([0.5 length(rat)+0.5])
ylabel('שיעור המאומתים מעל גיל 60 (באחוזים)')
set(gca,'Xtick',1:length(rat),'XTickLabel',xtk)
xtickangle(90)
% xtickformat('MMM')
box off
grid on
% xlim([datetime(2020,10,1) datetime('today')])
title('שיעור המאומתים מעל גיל 60')
set(gcf,'Color','w')
legend([h1;h2],'מאומתים צעירים','מאומתים מבוגרים','שיעור המבוגרים','location','north')
% figure;plot(dateW,deathsYO)
%%


figure;
plot(dateM,casesYO);
hold on;
plot(agDate(2:end),movmean(diff(casesYOday)./datenum(diff(agDate))*7,[21 21],'omitnan'))

yyy = movmean(diff(casesYOday)./datenum(diff(agDate))*7,[21 21],'omitnan');
figure;
yyaxis left
plot(agDate(2:end),yyy)
yyaxis right
plot(agDate(2:end),yyy(:,2)./yyy(:,1)*100)


%%

figure;
plot(dateW,casesYO./testsYO)

