function covid_age10_mult
% delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);
% !~/Programs/anaconda3/bin/python ~/covid-19-israel-matlab/code/vaccinated_cases.py
% ver = readtable('~/covid-19-israel-matlab/data/Israel/VerfiiedVaccinationStatusDaily.csv');
% date = datetime(ver.day_date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

[posTimna, dateT] = getTimna20;
[posDash, dateD] = get_dashboard;
dd = dateshift(dateD,'start','day');

dateT = [dateT;(dateT(end)+(7:7:50))'];
dU = unique(dd);
dateT(dateT>dU(end-1)) = [];
dash = nan(size(dateT));
for iWeek = 1:length(dateT)
    start = find(dd == dateT(iWeek)-7,1,'last');
    wend = find(dd == dateT(iWeek),1,'last');
    if ~isempty(start) && ~isempty(wend)
        dash(iWeek) = posDash(wend)-posDash(start);
    end
end
dash(73) = nan;
figure;
plot(dateT(1:length(posTimna))-3,posTimna)
hold on
plot(dateT-3,dash)



% extraDays = find(date>dateW(end));
% extraDays = extraDays(7:7:end);
% dateW(1
young = dash;
young(1:length(posTimna)) = posTimna;
mult = nan(size(dash));
mult(2:end,:) = young(2:end,:)./young(1:end-1,:);
date1 = datetime(2020,5,1);
%%
figure;
subplot(3,1,1)
plot(dateT,young)
title('weekly cases for 0-20 years old')
set(gca,'FontSize',13,'Xtick',datetime(2020,1:50,1))
grid on
ax = gca;
ax.YRuler.Exponent = 0;
xlim([date1,datetime('today')])
xtickformat('MMM')
subplot(3,1,2)
plot(dateT,young)
title('weekly cases for 0-20 years old (log)')
set(gca,'YScale','log','FontSize',13,'Xtick',datetime(2020,1:50,1))
grid on
xlim([date1,datetime('today')])
xtickformat('MMM')
subplot(3,1,3)
plot(dateT,mult)
grid on
title('multiplication factor')
set(gca,'FontSize',13,'YTick',0:6,'Xtick',datetime(2020,1:50,1))
xtickformat('MMM')
set(gcf,'Color','w')
xlim([date1,datetime('today')])

%%

function [pos20, dateW] = getTimna20
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
pos20 = pos(:,1);
% posYoung = sum(pos(:,1:9),2);

function [pos, dateD] = get_dashboard
txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/ages_dists.csv');
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
pos = sum(ag{:,2:3},2);
dateD = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
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
