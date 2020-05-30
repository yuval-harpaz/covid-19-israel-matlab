cd ~/covid-19_data_analysis/
t = readtable('data/Israel/covid19-data-israel.xlsx');
date = [t{2:end,1};[t{end,1}+1:datetime('today')]'];


todayPos = [13;nan;4;10;14;32;24;64;101];
yesterdayTests = [5969;nan;5010;2266;3605;5198;6606;6432;5312];
todayTests = [3203;nan;579;704;2580;3999;4007;4182;1403];
totalPos = [16683;nan;16712;16717;16734;16757;16793;16872;16987];
yesterdayPos = totalPos-todayPos;

tests = [t{2:end,2} - t{1:end-1,2};yesterdayTests(2:end);todayTests(end)];
newnew = diff(yesterdayPos);
new = [t{2:end,3} - t{1:end-1,3};newnew(1:end);todayPos(end)];

tt = table(date,tests,new);
tt.tests = tests;
tt.new(tt.new < 0) = 0;
tt.newPer = 100*tt.new./tt.tests;
titles = {'tests','new cases','percent positive tests'};
yla = {'tests','positive','positive (%)'};
%%
figure;
for ii = 1:3
    subplot(3,1,ii)
    plot(tt.date,tt{:,ii+1});
    set(gca,'XTick',tt.date(6:7:end),'fontsize',13)
    xlim(tt.date([34,end])+1)
    box off
    grid on
    title(titles{ii});
    ylabel(yla{ii});
    xtickangle(30)
    switch ii
        case 1
            ylim([0 15000])
        case 3
            set(gca,'YTick',0:2:10)
    end
end

%% 
clear tests
json = urlread('https://data.gov.il/api/action/datastore_search?resource_id=dcf999c1-d394-4b57-a5e0-9d014a62e046&limit=100000000');
struc = jsondecode(json);
dateCell = {struc.result.records(:).result_date}';
dateU = unique(dateCell);
date = cellfun(@(x) datetime(x,'InputFormat','yyyy-MM-dd'),dateU);
isFirst = ismember({struc.result.records(:).is_first_test}','Yes');
posAll = contains({struc.result.records(:).corona_result}','חיובי');
negAll = ismember({struc.result.records(:).corona_result}','שלילי');

for iDate = 1:length(date)
    isToday = ismember(dateCell,dateU{iDate});
    positive(iDate,1) = sum(isToday & isFirst & posAll);
    negative(iDate,1) = sum(isToday & isFirst & negAll);
    first_tests(iDate,1) = sum(isToday & isFirst);
    tests(iDate,1) = sum(isToday);
end

t = table(date,tests,first_tests,positive,negative);
no_results = t.first_tests - t.positive - t.negative;
reccurent = t.tests - t.first_tests;
figure;
h = bar(t.date,[t.negative,t.positive,no_results,reccurent],1,'stack','linestyle','none');
legend('negative','positive','no results','recurrent test')
h(2).FaceColor = [1,0,0];
% tic
% dateAll = cellfun(@(x) datetime(x,'InputFormat','yyyy-MM-dd'),dateCell);
% toc
% date = unique(dateAll);


% diff(yesterdayPos)./yesterdayTests(1:end-1);