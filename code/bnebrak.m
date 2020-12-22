BB = urlread('https://data.gov.il/api/3/action/datastore_search?q=%D7%91%D7%A0%D7%99%20%D7%91%D7%A8%D7%A7&resource_id=8a21d39d-91e3-40db-aca1-f73f7ab1df69&limit=10000000');
BB = jsondecode(BB);
BB = struct2table(BB.result.records);
% BB(contains(BB.Cumulated_deaths,{'0','<15'}),:) = [];
dateRow = datetime(BB.Date);
[dateRow,order] = unique(dateRow);
BB = BB(order,:);
BB.Cumulated_deaths(16:40) = repmat({'0'},25,1);
deathRow = cellfun(@str2num,BB.Cumulated_deaths);
% date = (dateRow(1):dateRow(end))';
% death = nan(size(date));
% death(ismember(date,dateRow)) = deathRow;
% 
% figure;
% plot(date(2:end),diff(death),'.','linestyle','-')
listD = readtable('dashboard_timeseries.csv');
for month = 4:12
    death(month-3,1) = deathRow(find(dateRow < datetime(2020,month+1,1),1,'last'));
    death(month-3,2) = listD.CountDeathCum(find(listD.date < datetime(2020,month+1,1),1,'last'));
end

figure;
yyaxis left
bar((4:12)-0.15,diff([0;death(:,1)]),'BarWidth',0.3)
yyaxis right
bar((4:12)+0.15,diff([0;death(:,2)]),'BarWidth',0.3)