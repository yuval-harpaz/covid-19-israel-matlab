% gil = readtable('~/Downloads/contagionDataPerCityPublic_orig.csv')

data = urlread(['https://data.gov.il/api/3/action/datastore_search?q=','ירושלים','&resource_id=8a21d39d-91e3-40db-aca1-f73f7ab1df69&limit=10000000']);
data = jsondecode(data);
data = struct2table(data.result.records);
dateRow = datetime(data.Date);
[dateRow,order] = unique(dateRow);
%     if ii == 1
%         nMonths = 11+month(dateRow(end));
%     end
data = data(order,:);
%     data.Cumulated_deaths = strrep(data.Cumulated_deaths,'<15','0');
data.Cumulative_verified_cases = strrep(data.Cumulative_verified_cases,'<15','0');
%     deathRow = cellfun(@str2num,data.Cumulated_deaths);
caseRow = cellfun(@str2num,data.Cumulative_verified_cases);
cases = [0;diff(caseRow)];



% save tmp.mat cases city dateRow
%
date = dateRow;
%%

data.Cumulated_deaths = strrep(data.Cumulated_deaths,'<15','0');
%     deathRow = cellfun(@str2num,data.Cumulated_deaths);
deathRow = cellfun(@str2num,data.Cumulated_deaths);
deaths = [0;diff(deathRow)];
deaths(27) = 4;
figure;
yyaxis left
bar(dateRow,deaths)
ylabel('deaths per day')
ylim([0 20])
yyaxis right
plot(dateRow,cases)
ylabel('cases per day')
title('Jerusalem')
grid on
box off
ylim([0 2000])
legend('deaths per day','cases per day')

% save tmp.mat cases city dateRow
%
date = dateRow;
figure;
plot(dateRow,cases)