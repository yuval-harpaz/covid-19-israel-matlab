cd ~/covid-19-israel-matlab/data/Israel
%pop = 9097000;
listD = readtable('dashboard_timeseries.csv');
listD.CountDeath(isnan(listD.CountDeath)) = 0;
listD.new_hospitalized(isnan(listD.new_hospitalized)) = 0;
endTrain = find(ismember(listD.date,datetime([2020,6,30])));
deaths = listD.CountDeath;
deathSmooth = movmean(deaths,[3 3]);
positiveTests = listD.tests_positive./listD.tests_result*100;
positiveTests(106:113) = 0.7; % ignore Gymnasia spike
positiveTestSmooth = movmean(positiveTests,[3 3]);
% endTrain = length(deathSmooth)-14;
bP = [ones(endTrain-15,1),positiveTestSmooth(1:endTrain-15)]\deathSmooth(16:endTrain);
predPositive = movmean([zeros(15,1);[ones(length(positiveTests),1),positiveTests]*bP],[3 3]);
predPositive(1:37) = 0;

newHosp = listD.new_hospitalized;
newHospSmooth = movmean(newHosp,[3 3]);
[xc,lag] = xcorr(deathSmooth(1:endTrain),newHospSmooth(1:endTrain));
%figure;
%plot(lag,xc)
[~,iMax] = max(xc);
lagH = lag(iMax);
bH = [ones(endTrain-lagH+1,1),movmean(newHospSmooth(1:endTrain-lagH+1),[3 3])]\deathSmooth(lagH:endTrain);
predHosp = movmean([zeros(lagH-1,1);[ones(length(positiveTests),1),newHospSmooth]*bH],[3 3]);
predHosp(1:37) = 0;
%% plot
dP = [listD.date;(listD.date(end)+1:listD.date(end)+15)'];
dH = [listD.date;(listD.date(end)+1:listD.date(end)+lagH-1)'];
figure('units','normalized','position',[0,0.25,1,0.5]);
subplot(1,3,1)
plot(listD.date,positiveTestSmooth/prctile(positiveTestSmooth,95),'k')
hold on
plot(listD.date,newHospSmooth/prctile(newHospSmooth,95),'b')
plot(listD.date,deathSmooth/prctile(deathSmooth,95),'r')
legend('Positive tests','New hospitalized','Daily deaths (smoothed)','location','northwest')
ylabel('normalized units')
box off
grid on
title('Two predictors for death rate')
subplot(1,3,2)
plot(dP,predPositive,'k--')
hold on
plot(dH,predHosp,'b--')
plot(listD.date,deaths,'r')
title('Daily deaths per million')
legend('predicted by tests','predicted by hospitalizations','daily deaths','location','northwest')
ylim([0 13])
box off
grid on
ylabel('deaths')
subplot(1,3,3)
plot(dP,cumsum(predPositive),'k--')
hold on
plot(dH,cumsum(predHosp),'b--')
plot(listD.date,cumsum(deaths),'r')
title('Cumulative deaths per million')
legend('predicted by tests','predicted by hospitalizations','total deaths','location','northwest')
box off
grid on
ylabel('deaths')

%% hospitalized, not new hospitalized
listD.Counthospitalized(isnan(listD.Counthospitalized)) = 0;
hosp = listD.Counthospitalized;
hospSmooth = movmean(hosp,[3 3]);
[xc,lag] = xcorr(deathSmooth(1:endTrain),hospSmooth(1:endTrain));
figure;
plot(lag,xc)
[~,iMax] = max(xc);
lagHt = lag(iMax);
bHt = [ones(endTrain-lagHt+1,1),movmean(hospSmooth(1:endTrain-lagHt+1),[3 3])]\deathSmooth(lagHt:endTrain);
predHospTot = movmean([zeros(lagHt-1,1);[ones(length(positiveTests),1),hospSmooth]*bHt],[3 3]);
predHospTot(1:37) = 0;

weekend = (listD.tests_result(80:end)-movmean(listD.tests_result(80:end),[3 3]))\posd(80:end);

figure;
plot(listD.date,positiveTests)
hold on
plot(listD.date,positiveTests+(listD.tests_result-movmean(listD.tests_result,[3 3]))*weekend);

%% מאגר מידע
clear json
ii = 0;
read = true;
while read
    tic;
    json{ii/100000+1} = urlread(['https://data.gov.il/api/3/action/datastore_search?resource_id=dcf999c1-d394-4b57-a5e0-9d014a62e046&limit=100000&offset=',str(ii)]);
    if length(json{ii/100000+1}) > 10000
        json{ii/100000+1} = strrep(json{ii/100000+1},'NULL','2020-01-01');
        json{ii/100000+1} = jsondecode(json{ii/100000+1});
        ii = ii+100000;
        toc;
    else
        read = false;
        json = json(1:end-1);
        disp('done')
    end
end
for ij = 1:length(json)
    clear cell*
    cellDate = {json{ij}.result.records(:).test_date}';
    cellDate = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDate);
    cellDateU = unique(cellDate);
    for ii = 1:length(cellDateU)
        cellPosFirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
        cellPosNotfirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','No'));
        cellNegFirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','שלילי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
        cellNegNotfirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','שלילי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','No'));
        cellPosmargFirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי גבולי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
        cellPosmargNotfirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי גבולי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','No'));
        cellUncertainFirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','לא ודאי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
        cellUncertainNotfirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','לא ודאי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','No'));
        cellErrFirst(ii,1) = sum(contains({json{ij}.result.records(:).corona_result}','פסול') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
        cellErrNotfirst(ii,1) = sum(contains({json{ij}.result.records(:).corona_result}','פסול') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).is_first_Test}','No'));
    end
    tables{ij,1} = table(cellDateU,cellNegFirst,cellPosFirst,cellPosmargFirst,cellUncertainFirst,cellErrFirst,...
        cellNegNotfirst,cellPosNotfirst,cellPosmargNotfirst,cellUncertainNotfirst,cellErrNotfirst);
    IEprog(ij)
end
date = [];
for ij = 1:length(json)
    date = [date;tables{ij}.cellDateU];
end
date = unique(date);
neg_first = zeros(length(date),1);
pos_first = zeros(length(date),1);
posmarg_first = zeros(length(date),1);
uncertain_first = zeros(length(date),1);
err_first = zeros(length(date),1);
neg_notfirst = zeros(length(date),1);
pos_notfirst = zeros(length(date),1);
posmarg_notfirst = zeros(length(date),1);
uncertain_notfirst = zeros(length(date),1);
err_notfirst = zeros(length(date),1);
t = table(date,neg_first,pos_first,posmarg_first,uncertain_first,err_first,...
    neg_notfirst,pos_notfirst,posmarg_notfirst,uncertain_notfirst,err_notfirst);
for iDate = 1:length(date)
    for ij = 1:length(tables)
        row = find(ismember(tables{ij}.cellDateU,date(iDate)));
        if ~isempty(row)
            t{iDate,2:end} = t{iDate,2:end}+tables{ij}{row,2:end};
        end
    end
end
t(1,:) = [];
writetable(t,'data/Israel/tests.csv','delimiter',',','WriteVariableNames',true)
%% 
t = readtable('tests.csv');
figure;
bar(t.date,[t.pos_first,t.posmarg_first,t.uncertain_first,t.err_first],'stacked','linestyle','none')
hold on
plot(listD.date,listD.tests_positive)
legend('positive','marginally positive','uncertain','error')

figure;
plot(t.date,cumsum(t.pos_first+t.posmarg_first))  % [t.pos_first,t.posmarg_first,t.uncertain_first,t.err_first],'stacked','linestyle','none')
hold on
plot(listD.date,cumsum(listD.tests_positive))

allPos = (t.pos_first+t.pos_notfirst+t.posmarg_first+t.posmarg_notfirst)./sum(t{:,2:end},2)*100;
allPos(79:82) = 2;
allPos = movmean(allPos,[3 3]);

bPa = [ones(97,1),allPos(1:112-15)]\deathSmooth(44:endTrain);
predPositiveA = [zeros(15,1);[ones(length(allPos),1),allPos]*bPa];
figure;
plot(listD.date,listD.CountDeath);
hold on
plot(t.date(16):t.date(16)+length(predPositiveA)-1,predPositiveA)

%% 
clear json
ii = 0;
read = true;
while read
    tic;
    json{ii/100000+1} = urlread(['https://data.gov.il/api/3/action/datastore_search?resource_id=d337959a-020a-4ed3-84f7-fca182292308&limit=100000&offset=',str(ii)]);
    if length(json{ii/100000+1}) > 10000
        %json{ii/100000+1} = strrep(json{ii/100000+1},'NULL',' ');
        json{ii/100000+1} = jsondecode(json{ii/100000+1});
        ii = ii+100000;
        toc;
    else
        read = false;
        json = json(1:end-1);
        disp('done')
    end
end
for ij = 1:length(json)
    clear cell*
    cellDate = {json{ij}.result.records(:).test_date}';
    cellDate = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDate);
    cellDateU = unique(cellDate);
    for ii = 1:length(cellDateU)
        cellPosOld(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).age_60_and_above}','Yes'));
        cellPosNotold(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).age_60_and_above}','No'));
        cellNegOld(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','שלילי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).age_60_and_above}','Yes'));
        cellNegNotold(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','שלילי') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).age_60_and_above}','No'));
        cellOtherOld(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','אחר') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).age_60_and_above}','Yes'));
        cellOtherNotold(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','אחר') & ...
            cellDate == cellDateU(ii) & ...
            ismember({json{ij}.result.records(:).age_60_and_above}','No'));
    end
    tables{ij,1} = table(cellDateU,cellPosOld,cellPosNotold,cellNegOld,cellNegNotold,cellOtherOld,cellOtherNotold);
    IEprog(ij)
end

date = [];
for ij = 1:length(json)
    date = [date;tables{ij}.cellDateU];
end
date = unique(date);
neg_old = zeros(length(date),1);
pos_old = zeros(length(date),1);
other_old = zeros(length(date),1);
neg_notold = zeros(length(date),1);
pos_notold = zeros(length(date),1);
other_notold = zeros(length(date),1);
t = table(date,neg_old,pos_old,other_old,neg_notold,pos_notold,other_notold);   
for iDate = 1:length(date)
    for ij = 1:length(tables)
        row = find(ismember(tables{ij}.cellDateU,date(iDate)));
        if ~isempty(row)
            t{iDate,2:end} = t{iDate,2:end}+tables{ij}{row,2:end};
        end
    end
end
t(1,:) = [];
writetable(t,'data/Israel/tests.csv','delimiter',',','WriteVariableNames',true)