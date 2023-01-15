function covid_waste
cd ~/Downloads/
fName = dir('Waste*');
creation = datetime({fName(:).date}');
[~, imax] = max(creation);
% [creation, order] = sort(creation);
% fName = {fName(order).name}';
T = readtable(fName(imax).name);
% dateAll = cellfun(@(x) datetime(strrep(x(1:11),'T','')), T.Start_Week_Date);
dateAll = datetime(T.Start_Week_Date);
bad = find(isnat(dateAll))

% lastSample = cellfun(@(x) datetime(strrep(x(1:11),'T','')), T.Last_Sampling_Date);
lastSample =  T.Last_Sampling_Date;
date = unique(dateAll);
[town, b] = unique(T.SE_Name);
popt = round(T.Population_For_Normalization(b));
% popt = round(cellfun(@str2num, T.Population_For_Normalization(b)));
% NVL = cellfun(@str2num, T.NVL);
NVL = T.NVL;
% popAll = cellfun(@str2num, T.Population_For_Normalization);
popAll = T.Population_For_Normalization;
% NVL = T.NVL;
% NVL = strrep(T.NVL,'NULL','nan');
% NVL = cellfun(@str2num, NVL);
nvl = nan(size(date));

for ii = 1:length(date)
    popAllDate(ii,1) = sum(popAll(dateAll == date(ii)));
    for jj = 1:length(town)
        row = find(dateAll == date(ii) & ismember(T.SE_Name,town{jj}));
        if length(row) == 1
            nvlt(ii,jj) = NVL(row);
            nvlnorm(ii,jj) = nvlt(ii,jj).*popAll(row);
        elseif length(row) == 0
            nvlt(ii,jj) = nan;
            nvlnorm(ii,jj) = nan;
        else
            [~, last] = max(lastSample(row));
            nvlt(ii,jj) = NVL(row(last));
            nvlnorm(ii,jj) = nvlt(ii,jj).*popAll(row(last));
        end
        
    end
end

% nvlt(nvlt == 0) = nan;
% figure;
% bar(date,nvlt,'stacked')
nvlnorm = nvlnorm(~isnat(date),:);
date = date(~isnat(date),:);
figure;
bar(date,nvlnorm/sum(popt),'stacked')
% set(gca,'YScale','log')
% ylim([70000 10^7])
grid on
box off
title('COVID-19 in Waste water ')
ylabel('NVL')
set(gcf,'Color','w')
set(gca,'XTick',date,'layer','top')
xtickangle(90)
xtickformat('dd.MM.yy')
xlabel('Start week date')


d = nvlnorm/sum(popt);
means = nanmean(d,2);
medians = nanmedian(d,2);
count = sum(isnan(d),2);
figure;
plot(date,[means.*count,medians.*count])
set(gca,'YScale','log')
ylabel('NVL')
set(gcf,'Color','w')
set(gca,'XTick',date,'layer','top')
xtickangle(90)
xtickformat('dd.MM.yy')
xlabel('Start week date')
ylim([10000 10^7])
grid

figure
for ii = 1:size(nvlnorm,2)
    bar(ii,nvlnorm(end,ii)/sum(popt))
    hold on
end
set(gca,'Xtick',1:ii,'XTickLabel',town)
xtickangle(90)

count = [];
nvln = [];
firstOnly = [];
for ii = 1:length(date)
    nvln(ii,1) = nansum(nvlnorm(ii,:))./sum(popt(~isnan(nvlnorm(ii,:))));
    count(ii,1) = sum(isnan(nvlnorm(ii,:)));
    firstOnly(ii,1) = sum(dateAll(dateAll == date(ii)) == lastSample(dateAll == date(ii)));
    present(ii,1) = length(town)-count(ii,1)-firstOnly(ii,1);
end
figure;
bar(date,nvln,0.75, 'EdgeColor','none')
set(gca,'YScale','log')
ylim([70000 10^7])
grid on
box off
title('COVID-19 in Waste water ')
ylabel('NVL')
set(gcf,'Color','w')
set(gca,'XTick',date,'layer','top')
xtickangle(90)
xtickformat('dd.MM.yy')
xlabel('Start week date')
hold on
% plot(date,means.*count,'r')
% plot(date,medians.*count,'k')


figure;
hb = bar(date,[present,firstOnly,count],'stacked');
set(gca,'XTick',date,'layer','top','ygrid','on')
xtickangle(90)
xtickformat('dd.MM.yy')
xlabel('Start week date')
ylabel('N locations (94 total)')
legend('data','data from 1st weekday only','missing')
hb(3).FaceColor = 'w';
title('Number of sewer systems sampled')
box off