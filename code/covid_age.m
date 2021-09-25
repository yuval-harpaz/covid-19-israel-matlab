function covid_age(source)
if nargin == 0
    source = 'dashboard';
end
position = [100,100,900,600];
pop = [1735000;1565000;1320000;1209000;1112000;874000;747217;526929;238729;58687];
% [posDash, dateD] = get_dashboard;
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
listD(end,:) = [];
yl = movsum(listD.tests_positive1(1:end-1),[3 3]);
if strcmp(source(1),'d')
    [pos, dateW, ages] = get_dashboard;
    co = flipud(hsv(11)); co = co + 0.1; co(co > 1) = 1;
    co = co(2:end,:)*0.9;
    figure('position',position);
    hh = bar(dateW-3,pos,1.8,'stacked','EdgeColor','none');
    for jj = 1:length(hh)
        hh(jj).FaceColor = co(jj,:);
    end
    legend(fliplr(hh),flipud(ages),'location','west');
    xlim([dateW(1)-7 datetime('today')])
    ax = gca;
    ax.YRuler.Exponent = 0;
    ax.YAxis.TickLabelFormat = '%,.0d';
    set(gca,'xtick',datetime(2020,3:100,1),'FontSize',13)
    grid on
    title('weekly cases by age')
    xtickformat('MMM')
    set(gcf,'Color','w')
    
    ratio = pos./sum(pos,2)*100;
    ratio(nansum(pos,2) < 2000,:) = 0;
    figure('position',position);
    hp = bar(dateW-3,ratio,1.8,'stacked','EdgeColor','none');
    for jj = 1:length(hp)
        hp(jj).FaceColor = co(jj,:);
    end
    hold on
    % plot(listD.date,movsum(listD.tests,[3 3]),'r','linewidth',2);
    ylim([0 100])
    plot(listD.date(1:end-1),yl./max(yl)*100,'k','linewidth',2);
    legend(fliplr(hp),flipud(ages))
    
    xlim([datetime(2020,6,1) datetime('today')])
    title('cases by age  (%)  מאומתים לפי גיל')
    set(gcf,'Color','w')
    dateW(59) = [];
    pos(59,:) = [];
    figure('position',position);
    hl = plot(dateW-3,pos);
    set(gca,'FontSize',13,'Xtick',datetime(2020,1:50,1))
    grid on
    ax = gca;
    ax.YRuler.Exponent = 0;
    xlim([dateW(1)-3,datetime('today')])
    xtickformat('MMM')
    legend('0-10','10-20','20-30','30-40','40-50','50-60','60-70','70-80','80-90','90+',...
        'location',[0.65,0.55,0.05,0.1])
    title('weekly cases by age')
    set(gcf,'Color','w')
    for jj = 1:length(hl)
        hl(jj).Color = co(jj,:);
    end
    
    
    figure('position',position);
    hlp = plot(dateW-3,pos./pop'*10000,'linewidth',1.5);
    set(gca,'FontSize',13,'Xtick',datetime(2020,1:50,1))
    grid on
    ax = gca;
    ax.YRuler.Exponent = 0;
    xlim([dateW(1)-3,datetime('today')])
    xtickformat('MMM')
    legend('0-10','10-20','20-30','30-40','40-50','50-60','60-70','70-80','80-90','90+',...
        'location',[0.65,0.55,0.05,0.1])
    title('weekly cases/10k by age')
    set(gcf,'Color','w')
    for jj = 1:length(hlp)
        hlp(jj).Color = co(jj,:);
    end
    ylabel('cases per 10k')
elseif strcmp(source(1),'s')
    [pos, dateW, ages] = get_severe;
    co = flipud(hsv(11)); co = co + 0.1; co(co > 1) = 1;
    co = co(2:end,:)*0.9;
    figure('position',position);
    hh = bar(dateW-3,pos/7,1,'stacked','EdgeColor','none');
    for jj = 1:length(hh)
        hh(jj).FaceColor = co(jj,:);
    end
    hold on
    hh(end+1) = plot(listD.date(2:end-1)-3,movmean(diff(listD.CountSeriousCriticalCum(1:end-1)),[6 0]),'k','linewidth',2);
    legend(fliplr(hh),[{'total'};flipud(ages)],'location','northwest')
    xlim([datetime(2021,6,15),datetime('today')])
    title('daily new severe cases by age')
    set(gcf,'Color','w')
    grid on
    
    figure('position',position);
    hh = plot(dateW-3,pos./pop'*10000,'linewidth',2);
    for jj = 1:length(hh)
        hh(jj).Color = co(jj,:);
    end
    legend(flipud(hh),flipud(ages),'location','northwest')
    xlim([datetime(2021,6,15),datetime('today')])
    title('weekly new severe/10k by age')
    set(gcf,'Color','w')
    grid on
    
    figure('position',position);
    hh = plot(dateW-3,pos/7,'linewidth',2);
    for jj = 1:length(hh)
        hh(jj).Color = co(jj,:);
    end
    legend(flipud(hh),flipud(ages),'location','northwest')
    xlim([datetime(2021,6,15),datetime('today')])
    title('daily new severe by age')
    set(gcf,'Color','w')
    grid on
else
    [pos, testsW, dateW, ages] = getTimna;
    [posY, testsY, dateY, agesY] = getTimnaY;
    
    % yy = [testsY,testsW(:,2:end)];
    % figure;
    % bar(dateW-3,yy,'stacked','EdgeColor','none')
    % hold on
    % % plot(listD.date,movsum(listD.tests,[3 3]),'r','linewidth',2);
    % plot(listD.date(1:end-8),movsum(listD.tests1(1:end-8),[3 3]),'k','linewidth',2);
    
    % yypos = [posY,pos(:,2:end)];
    pos2 = {pos;posY};
    age2 = {ages;agesY};
    co{2} = jet(7); co{1} = co{1} + 0.1; co{1}(co{1} > 1) = 1;
    co{1} = jet(14); co{2} = co{2} + 0.1; co{2}(co{2} > 1) = 1;
    tests2 = {testsW;testsY};
    figure('position',[100,100,900,900]);
    for ii = 1:2
        subplot(2,1,ii)
        hh{ii} = bar(dateW-3,pos2{ii},1,'stacked','EdgeColor','none');
        for jj = 1:length(hh{ii})
            hh{ii}(jj).FaceColor = co{ii}(jj,:);
        end
        legend(fliplr(hh{ii}),flipud(age2{ii}),'location','west');
        xlim([datetime(2020,6,1) datetime('today')])
        ax = gca;
        ax.YRuler.Exponent = 0;
        ax.YAxis.TickLabelFormat = '%,.0d';
        set(gca,'xtick',datetime(2020,3:100,1),'FontSize',13)
        grid on
        if ii == 1
            title('cases by age  מאומתים לפי גיל')
        else
            title('young צעירים')
        end
        xtickformat('MMM')
        grid on
    end
    set(gcf,'Color','w')
    
    figure('position',[100,100,900,900]);
    for ii = 1:2
        subplot(2,1,ii)
        hp{ii} = bar(dateW-3,pos2{ii}./sum(pos2{1},2)*100,1,'stacked','EdgeColor','none');
        for jj = 1:length(hh{ii})
            hp{ii}(jj).FaceColor = co{ii}(jj,:);
        end
        hold on
        % plot(listD.date,movsum(listD.tests,[3 3]),'r','linewidth',2);
        ylim([0 100])
        plot(listD.date(1:end-1),yl./max(yl)*100,'k','linewidth',2);
        legend(fliplr(hp{ii}),flipud(age2{ii}),'location','west')
    
        xlim([dateW(1)-3 datetime('today')-3]);
        if ii == 1
            title('cases by age  (%)  מאומתים לפי גיל')
        else
            title('young צעירים')
        end
        set(gca,'xtick',datetime(2020,3:100,1),'FontSize',13)
        xtickformat('MMM')
        grid on
    end
    set(gcf,'Color','w')
    figure('position',[100,100,900,900]);
    for ii = 1:2
        subplot(2,1,ii)
        perc = pos2{ii}./tests2{ii}*100;
        hpp = plot(dateW-3,perc,'linewidth',1.5);
        legend(hpp,age2{ii},'location','west')
        xlim([dateW(1)-3 datetime('today')-3]);
        if ii == 1
            title('percent positive by age  אחוז חיוביים לפי גיל')
        else
            title('young צעירים')
        end
        grid on
        for jj = 1:length(hpp)
            hpp(jj).Color = co{ii}(jj,:);
        end
        set(gca,'xtick',datetime(2020,3:100,1),'FontSize',13)
        xtickformat('MMM')
        grid on
    end
    set(gcf,'Color','w')
    
    % hold on
    % % plot(listD.date,movsum(listD.tests,[3 3]),'r','linewidth',2);
    % plot(listD.date(1:end-8),movsum(listD.tests_positive1(1:end-8),[3 3]),'k','linewidth',2);
end



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
ages(end) = [];
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


function [dash, end7, ages] = get_dashboard
txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/ages_dists.csv');
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
pos = ag{:,2:11};
% pos = sum(ag{:,2:3},2);
% pos(:,2) = sum(ag{:,4:5},2);
% pos(:,3) = sum(ag{:,6:7},2);
% pos(:,4) = sum(ag{:,8:9},2);
% pos(:,5) = sum(ag{:,10:11},2);
date = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
dd = dateshift(date,'start','day');
dU = unique(dd);
sunday = dU(10);
sunday = sunday:7:dU(end);
end7 = unique([sunday';dU(end-1)]);
dash = nan(size(end7,1),10);
for iWeek = 1:length(end7)
    start = find(dd == end7(iWeek)-7,1,'last');
    wend = find(dd == end7(iWeek),1,'last');
    if ~isempty(start) && ~isempty(wend)
        dash(iWeek,:) = pos(wend,:)-pos(start,:);
    end
end
dash(59,:) = nan;
% end7(59) = [];
dash(dash < 0) = 0;
ages = strrep(ag.Properties.VariableNames(2:11),'x','')';
ages = strrep(ages,'_','-');
ages{end} = '90+';
function [dash, end7, ages] = get_severe
txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/severe_ages_dists.csv');
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
sev = ag{:,2:11};
sev = sev(611:end,:);
date = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
date = date(611:end);
dd = dateshift(date,'start','day');
dU = unique(dd);
sunday = dU(10);
sunday = sunday:7:dU(end);
end7 = unique([sunday';dU(end-1)]);
dash = nan(size(end7,1),10);
for iWeek = 1:length(end7)
    start = find(dd == end7(iWeek)-7,1,'last');
    wend = find(dd == end7(iWeek),1,'last');
    if ~isempty(start) && ~isempty(wend)
        dash(iWeek,:) = sev(wend,:)-sev(start,:);
    end
end
% dash(59,:) = nan;
% end7(59) = [];
dash(dash < 0) = 0;
ages = strrep(ag.Properties.VariableNames(2:11),'x','')';
ages = strrep(ages,'_','-');
ages{end} = '90+';