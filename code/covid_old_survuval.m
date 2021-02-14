cd ~/covid-19-israel-matlab/data/Israel
listName = {'','deaths_'};
tit = {'מאומתים','נפטרים'};
col = [0.259 0.525 0.961;0.063 0.616 0.345;0.961 0.706 0.4;0.988 0.431 0.016;0.863 0.267 0.216];
for iList = [1,2]
    txt = urlread(['https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/',listName{iList},'ages_dists.csv']);
    txt = txt(find(ismember(txt,newline),1)+1:end);
    fid = fopen('tmp.csv','w');
    fwrite(fid,txt);
    fclose(fid);
    ag = readtable('tmp.csv');
    agDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
    agDate = dateshift(agDate,'start','day');
    casesYOday = [sum(ag{:,[2:7,12:17]},2),sum(ag{:,[8:11,18:21]},2)];
    %%
%     yyy0 = movmean(diff(casesYOday)./datenum(diff(agDate)),[11 11],'omitnan');
%     yyy0 = movmean(yyy0,[11 11],'omitnan');
    
    clear yy;
    for ii = 1:5
        idx = 1+(ii*2-1:ii*2);
        yy(1:length(agDate),ii) = sum(ag{:,idx},2);
        disp(idx)
    end
%     if iList == 1 || iList == 4
%         yyy = movmean(diff(yy)./datenum(diff(agDate)),[11 11],'omitnan');
%     else
    agDate = dateshift(agDate,'start','day');
    date = agDate(1):agDate(end);
    tmpY = nan(size(date'));
%     tmpY = [];
    for iDate = 1:length(date)
        jDate = find(ismember(agDate,date(iDate)),1,'last');
        if ~isempty(jDate)
            tmpY(iDate,1:5) = yy(jDate,:);
%         else
%             tmpY(iDate,1:5) = nan;
        end
    end
    yyy = diff(movmean(tmpY,[6 0],'omitnan'));
    yyy(yyy < 0) = 0;
%     end
    yyy = [cumsum(yyy,2);zeros(size(yyy))];
    xxx = [date(2:end)';flipud(date(2:end)')];
    
    figure;
    subplot(2,1,1)
    for ii = 1:5
        fill(xxx,yyy(:,6-ii),col(6-ii,:),'linestyle','none')
        hold on
    end
    % plot(agDate(2:end),yyy)
    legend('80+','60-80','40-60','20-40','0-20','location','northwest');
    set(gcf,'Color','w')
    ax = gca;
    ax.YRuler.Exponent = 0;
    xtickformat('MMM')
    xlim(agDate([2,end]))
    grid on
    title([tit{iList},' ','לפי גיל'])
    set(gca, 'layer', 'top');
    
    yyy1 = yyy./yyy(:,5)*100;
    yyy1(isnan(yyy1)) = 0;
    yyy1(yyy1 < 0) = 0;
    subplot(2,1,2)
    for ii = 1:5
        fill(xxx,yyy1(:,6-ii),col(6-ii,:),'linestyle','none')
        hold on
    end
    % legend('80+','60-80','40-60','20-40','0-20','location','northwest');
    set(gcf,'Color','w')
    ax = gca;
    ax.YRuler.Exponent = 0;
    xtickformat('MMM')
    xlim(agDate([2,end]))
    grid on
      title([tit{iList},' ','לפי גיל','%'])
    set(gca, 'layer', 'top');
    dates{iList,1} = date;
    ys{iList,1} = tmpY;
end
lg = fliplr({'80+','60-80','40-60','20-40','0-20'});
figure('units','normalized','position',[0,0,0.5,1]);
for ii = 1:5
    subplot(5,1,ii)
    yyaxis left
    if ii > 2
        y = diff(movmean(ys{1}(:,ii),[6 0]));
    else
        y = diff(ys{1}(:,ii));
    end
    y(y < 0) = 0;
    plot(dates{1}(2:end)+16,y)
    yyaxis right
    y = diff(movmean(ys{2}(:,ii),[6 0]));
    y(y < 0) = 0;
    plot(dates{2}(2:end),y)
    title(lg{ii})
    if ii == 1
        legend('מאומתים','נפטרים','location','northwest')
    end
    xlim([datetime(2020,9,1) datetime('tomorrow')])
    box off
    xtickformat('MMM')
    grid on
end

%% 
conf2 = [movmean(diff(sum(ys{1}(:,1:3),2)),[3 3]),movmean(diff(sum(ys{1}(:,4:5),2)),[3 3])];
dead2 = [movmean(diff(sum(ys{2}(:,1:3),2)),[3 3]),movmean(diff(sum(ys{2}(:,4:5),2)),[3 3])];
figure;
yyaxis left;
plot(conf2(:,1));
yyaxis right;
plot(conf2(:,2));

% w = repmat(0.12,239,1);
% w(103:end) = 0.16;
% w(190:220) = 0.12;
% iii = 214:220;
% w(iii) = linspace(0.12,0.16,length(iii));
w = 0.1232;
figure;
yyaxis left;
plot(dates{1}(3:end),conf2(2:end,2));
hold on
plot(dates{1}(3:end),conf2(2:end,1).*w);
yyaxis right
plot(dates{1}(3:end),conf2(2:end,1));
legend('מאומתים מעל 60','מאומתים מעל 60 אם החיסון היה מתעכב','מאומתים מתחת 60')
grid on
common = find(ismember(dates{1},dates{2}));

prob = readtable('positive_to_death.txt');
pred = conv(conf2(common(1:end-1),2),prob.all1)*0.07;
pred1 = conv(conf2(common(1:end-1),1).*w,prob.all1)*0.07;
figure;
plot(dead2(:,2))
hold on
plot(pred)
plot(pred1)

plot(dead2(17:end,2)./conf2(common(1:end-16),2))