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
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
for month = 3:12
    death(month-2,1) = deathRow(find(dateRow < datetime(2020,month+1,1),1,'last'));
    death(month-2,2) = listD.CountDeathCum(find(listD.date < datetime(2020,month+1,1),1,'last'));
end

figure;
yyaxis left
bar((3:12)-0.15,diff([0;death(:,1)]),'BarWidth',0.3)
yyaxis right
bar((3:12)+0.15,diff([0;death(:,2)]),'BarWidth',0.3)
ylim([0 1200])
legend('בני ברק','ישראל')
title('תמותה')
xlim([2.5 12.5])
xlabel('חודש')
set(gcf,'color','w')
box off
set(gca,'ygrid','on')
set(gca,'ygrid','on','XTick',3:12)

caseRow = cellfun(@str2num,strrep(BB.Cumulative_verified_cases,'<15','0'));
caseCum = cumsum(listD.tests_positive);
for month = 3:12
    cases(month-2,1) = caseRow(find(dateRow < datetime(2020,month+1,1),1,'last'));
    cases(month-2,2) = caseCum(find(listD.date < datetime(2020,month+1,1),1,'last'));
end

figure;
yyaxis left
bar((3:12)-0.15,diff([0;cases(:,1)])/1000,'BarWidth',0.3)
yyaxis right
bar((3:12)+0.15,diff([0;cases(:,2)])/1000,'BarWidth',0.3)
ylim([0 150])
legend('בני ברק','ישראל')
title('מאומתים (אלפים)')
xlim([2.5 12.5])
xlabel('חודש')
set(gcf,'color','w')
box off
set(gca,'ygrid','on','XTick',3:12)
