cd ~/covid-19-israel-matlab/data/Israel
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=32150ead-89f2-461e-9cc3-f785e9e8608f&limit=5000');
json = jsondecode(json);
t = struct2table(json.result.records);

t60 = t(ismember(t.age_group,'60+'),:);
weekStartVacc = datetime(cellfun(@(x) x(1:10),t60.First_dose_week,'UniformOutput',false));
[weekVacc,order] = sort(weekStartVacc);
t60 = t60(order,:);
% weekVacc = (min(weekStartVacc):7:max(weekStartVacc))';
weekInfec = datetime(cellfun(@(x) strrep(x(10:19),'_','-'),t60.Properties.VariableNames(5:end),'UniformOutput',false))';
% weekInfec = (min(weekStartInfec):7:max(weekStartInfec))';
cells = t60{:,5:end};
cells(cellfun(@isempty, cells)) = {'0'};
cells = strrep(cells,'1-5','2.5');
cases = cellfun(@str2num, cells);
cases(cases == -4) = 8;
cpm = round(cases./cellfun(@str2num, t60.group_size).*10^6,1);
cpm4 = movsum(cpm,[2 2]);
pct = cpm4./sum(cpm4);

pctnn = cases./sum(cases);

col = flipud(jet(length(weekVacc)));
yy{1} = cpm4;
yy{3} = pct;

t_ = t(ismember(t.age_group,'<60'),:);
weekStartVacc = datetime(cellfun(@(x) x(1:10),t_.First_dose_week,'UniformOutput',false));
[weekVacc,order] = sort(weekStartVacc);
t_ = t_(order,:);
% weekVacc = (min(weekStartVacc):7:max(weekStartVacc))';
weekInfec = datetime(cellfun(@(x) strrep(x(10:19),'_','-'),t_.Properties.VariableNames(5:end),'UniformOutput',false))';
% weekInfec = (min(weekStartInfec):7:max(weekStartInfec))';
cells = t_{:,5:end};
cells(cellfun(@isempty, cells)) = {'0'};
cells = strrep(cells,'1-5','2.5');
cases = cellfun(@str2num, cells);
cases(cases == -4) = 8;
cpm = round(cases./cellfun(@str2num, t_.group_size).*10^6,1);
cpm4 = movsum(cpm,[2 2]);
pct = cpm4./sum(cpm4);
col = flipud(jet(length(weekVacc)));
yy{2} = cpm4;
yy{4} = pct;
tit= {'Amount of 60+ y/o infections by date and vaccine age',...
    'Amount of <60 y/o infections by date and vaccine age',...
    'Ratio of 60+ y/o infections by date and vaccine age',...
    'Ratio of <60 y/o infections by date and vaccine age'};
%%
figure;
for isp = 1:4
    subplot(2,2,isp)
    for ii = 1:length(weekVacc)
        if ii == 1
            prev = zeros(1,length(weekInfec));
            %     else
            %         prev = fliplr(cumsum(cpm(1:ii-1,:)));
        end
        curr = sum(yy{isp}(1:ii,:),1);
        h(ii) = fill([weekInfec;flipud(weekInfec)],[curr,prev],col(ii,:),'LineStyle','none');
        prev = fliplr(curr);
        hold on
    end
    xlim(weekInfec([1,end]))
    if isp > 2
        ylim([0 1])
        set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)
        ylabel('% of aged vaccines')
    else
        ax = gca;
        ax.YRuler.Exponent = 0;
        ax.YAxis.TickLabelFormat = '%,.0g';
        ylabel('cases per 1M per 5 weeks')
        ylim([0 200000])
    end
    box off
    set(gca,'Layer','top')
    xlabel('infection date')
    title(tit{isp})
end
set(gcf,'Color','w')

%% normalized by group size
figure;
isp = 3;
for ii = 1:length(weekVacc)
    if ii == 1
        prev = zeros(1,length(weekInfec));
        %     else
        %         prev = fliplr(cumsum(cpm(1:ii-1,:)));
    end
    curr = sum(yy{isp}(1:ii,:),1);
    h(ii) = fill([weekInfec;flipud(weekInfec)],[curr,prev],col(ii,:),'LineStyle','none');
%     h(ii).FaceAlpha = 0.5;
    prev = fliplr(curr);
    hold on
end
axis tight
set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)
ylabel('% of aged vaccines')
box off
set(gca,'Layer','top')
xlabel('infection date     תאריך ההדבקה')
title(tit{isp})
set(gcf,'Color','w')
ylabel('percent of aged vaccines    אחוז החיסונים הוותיקים')
gap = 0;
yc = 1:length(weekInfec);
yc = yc/max(yc);
for ic = 1:length(col)
    fill([weekInfec(end)+gap+1,weekInfec(end)+gap+7,weekInfec(end)+gap+7,weekInfec(end)+gap+1],...
        [yc(ic)-yc(1),yc(ic)-yc(1),yc(ic),yc(ic)],col(ic,:))
    text(weekInfec(end)+gap+9,yc(ic)-yc(1)/2,datestr(weekInfec(ic),'dd-mmm'))
end
% ax = gca;
grid on


%% cancel group size effect, just show percent of old vaccines
figure;
clear isp
for ii = 1:length(weekVacc)
    if ii == 1
        prev = zeros(1,length(weekInfec));
        %     else
        %         prev = fliplr(cumsum(cpm(1:ii-1,:)));
    end
    curr = sum(pctnn(1:ii,:),1);
    h(ii) = fill([weekInfec;flipud(weekInfec)],[curr,prev],col(ii,:),'LineStyle','none');
%     h(ii).FaceAlpha = 0.5;
    prev = fliplr(curr);
    hold on
end
axis tight
set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)
ylabel('% of aged vaccines')
box off
set(gca,'Layer','top')
xlabel('infection date     תאריך ההדבקה')
title(tit{3})
set(gcf,'Color','w')
ylabel('percent of aged vaccines    אחוז החיסונים הוותיקים')
gap = 0;
yc = 1:length(weekInfec);
yc = yc/max(yc);
for ic = 1:length(col)
    fill([weekInfec(end)+gap+1,weekInfec(end)+gap+7,weekInfec(end)+gap+7,weekInfec(end)+gap+1],...
        [yc(ic)-yc(1),yc(ic)-yc(1),yc(ic),yc(ic)],col(ic,:))
    text(weekInfec(end)+gap+9,yc(ic)-yc(1)/2,datestr(weekInfec(ic),'dd-mmm'))
end
% ax = gca;
grid on
%% dots
% vecCases = cases(:);
% vecCases(vecCases == 0) = nan;
% x = 1:31;
% x = repmat(x,1,31)';
% y = reshape(reshape(x,31,31)',31^2,1);
% figure;
% scatter(y,x,vecCases./max(vecCases)*100,'fill')
% surf(weekInfec,