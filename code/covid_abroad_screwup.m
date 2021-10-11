function covid_abroad_screwup

!wget -O ~/Downloads/abroad_prev.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/9ecf627eb4f7277f126ee1067c28f5eb2a2d54c8/from_abroad.csv
ttPrev = readtable('~/Downloads/abroad_prev.csv','HeaderLines',1,'ReadVariableNames',true,'Delimiter',',');
!wget -O ~/Downloads/abroad_now.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/from_abroad.csv
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
abr = cellfun(@(x) x,paad.sum_positive);
isdd = ismember(date,abroad.date);
abr = abr(isdd);
date = date(isdd);
isd = ismember(abroad.date,date);
abroad.incoming(isd) = abr;

aad = struct2table(webread('https://datadashboardapi.health.gov.il/api/queries/arrivingAboardDaily',options));
aad = aad(ismember(aad.visited_country,'כלל המדינות'),:);
aadDate = datetime(aad.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');


abroad.incoming_tests(ismember(abroad.date,aadDate)) = aad.sum_arrival(ismember(aadDate,abroad.date));
abroad.local = abroad.positive-abroad.incoming;
writetable(abroad,'infected_abroad.csv')
xt = dateshift(datetime('today'),'start','week');
xt = fliplr(xt:-7:abroad.date(1));
figure;
subplot(1,2,1)
yy = abroad{:,5}./(abroad{:,4}+abroad{:,5})*100;
yys = nan(size(yy));
idx = ~isnan(yy);
yys(idx) = movmean(yy(idx),[3 3]);
plot(abroad.date,yy,'.b')
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