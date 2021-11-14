function covid_abroad4


cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
abroad = readtable('infected_abroad.csv');
listD = listD(find(ismember(listD.date,abroad.date),1):end,:);
extra = height(listD)-height(abroad);
if extra > 0
    row = height(abroad)+1:height(abroad)+extra;
    abroad.date(end+1:end+extra) = listD.date(row);
end
abroad.tests = listD.tests;
abroad.positive = listD.tests_positive;
if sum(abroad{end,4:5}) == 0
    abroad(end,:) = [];
end

options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/positiveArrivingAboardDaily';
paad = webread(url, options);
paad = struct2table(paad);
paad = paad(ismember(paad.visited_country,'כלל המדינות'),:);
date = datetime(paad.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
ie = cellfun(@isempty,paad.sum_positive);
paad.sum_positive(ie) = {0};
% abr = cellfun(@(x) x,paad.sum_positive);
% isdd = ismember(date,abroad.date);
% abr = abr(isdd);
% date = date(isdd);
% isd = ismember(abroad.date,date);
% abroad.incoming(isd) = abr;
n = paad{:,3:4}./paad{:,5:6};
n(isinf(n)) = nan;
perc = movmean(paad{:,3:4},[3 3],'omitnan')./movmean(n,[3 3],'omitnan');
ve = 100*(1-perc(:,1)./perc(:,2));
ve = 100*(1-paad.percent_positive_Vaccination./paad.percent_Positive_None_vaccination);
ve = movmean(ve,[3 3],'omitnan');
figure;

plot(date,ve,'b')


hold on
plot(abroad.date,yys,'b')
set(gca,'XTick',xt)
title('infected abroad (%) נדבקו בחו"ל')
set(gca,'XTick',xt)
grid on
box off
ylabel('%')
set(gcf,'Color','w')
xlim(abroad.date([1,end]))
ylim([0 100])
xtickangle(90)
subplot(1,2,2)
bar(abroad.date,abroad.incoming)
grid on
box off
ylim([0 2000])
title('infected abroad')
set(gca,'XTick',xt)
xtickangle(90)