clear
cd ~/covid-19-israel-matlab/data/Israel
fid = fopen('data/Israel/log.txt','r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
% lastRead = str2num(txt(find(ismember(txt,','),1,'last')+1:find(ismember(txt,newline),1,'last')-1));
% ii = lastRead-100000;
tt = readtable('symptoms.csv');

ii = 0;
read = true;
tables = {};
json = {};
id = false;
while read
    tic;
    json = urlread(['https://data.gov.il/api/3/action/datastore_search?resource_id=d337959a-020a-4ed3-84f7-fca182292308&limit=100000&offset=',str(ii)]);
    if length(json) > 10000
        %json{ii/100000+1} = strrep(json{ii/100000+1},'NULL',' ');
        json = jsondecode(json);
        clear cell*
        cellDate = {json.result.records(:).test_date}';
        cellDate = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDate);
        cellDateU = unique(cellDate);
        cough = ismember({json.result.records(:).cough}','1');
        fever = ismember({json.result.records(:).fever}','1');
        sore = ismember({json.result.records(:).sore_throat}','1');
        breath = ismember({json.result.records(:).shortness_of_breath}','1');
        head = ismember({json.result.records(:).head_ache}','1');
        nosym = sum([cough,fever,sore,breath,head],2) == 0;
        positive = ismember({json.result.records(:).corona_result}','חיובי');
        negative = ismember({json.result.records(:).corona_result}','שלילי');
        other = ismember({json.result.records(:).corona_result}','אחר');
        age = nan(size(other));
        age(ismember({json.result.records(:).age_60_and_above}','Yes')) = 1;
        age(ismember({json.result.records(:).age_60_and_above}','No')) = 0;
        cellID = [json.result.records(:).x_id]';
        if any(ismember(find(id),cellID))
            warning([str(sum(ismember(find(id),cellID))),' duplicates!'])
        end
        id(cellID,1) = true;
        for jj = 1:length(cellDateU)
            today = ismember(cellDate,cellDateU(jj));
            cellPos(jj,1) = sum(today & positive);
            cellNeg(jj,1) = sum(today & negative);
            cellCoughPos(jj,1) = sum(today & positive & cough);
            cellCoughNeg(jj,1) = sum(today & negative & cough);
            cellFeverPos(jj,1) = sum(today & positive & fever);
            cellFeverNeg(jj,1) = sum(today & negative & fever);
            cellSorePos(jj,1) = sum(today & positive & sore);
            cellSoreNeg(jj,1) = sum(today & negative & sore);
            cellBreathPos(jj,1) = sum(today & positive & breath);
            cellBreatNeg(jj,1) = sum(today & negative & breath);
            cellHeadPos(jj,1) = sum(today & positive & head);
            cellHeadNeg(jj,1) = sum(today & negative & head);
            cellNosymPos(jj,1) = sum(today & positive & nosym);
            cellNosymNeg(jj,1) = sum(today & negative & nosym);
            cellOver60(jj,1) = sum(today & age == 1);
            cellBelow60(jj,1) = sum(today & age == 0);
            cellNoAge(jj,1) = sum(today & isnan(age)); %#ok<*SAGROW>
        end
        tables{end+1,1} = table(cellDateU,cellPos,cellNeg,cellCoughPos,cellCoughNeg,...
            cellFeverPos,cellFeverNeg,cellSorePos,cellSoreNeg,cellBreathPos,cellBreatNeg,...
            cellHeadPos,cellHeadNeg,cellNosymPos,cellNosymNeg,cellOver60,cellBelow60,cellNoAge);
        ii = ii+100000;
        disp(datestr(cellDateU(1)))
    else
        read = false;
        %json = json(1:end-1);
        disp('done')
    end
end



% date = [];
% for ij = 1:length(tables)
%     date = [date;tables{ij}.cellDateU];
% end
% date = unique(date);
% test2result = nan(size(date));
% for iDate = 1:length(date)
%     n = [];
%     avg = [];
%     for ij = 1:length(tables)
%         iRow = ismember(tables{ij}.cellDateU,date(iDate));
%         if sum(iRow) > 0
%         	n(end+1,1) = tables{ij}.cellN(iRow);
%             avg(end+1,1) = tables{ij}.cellDif(iRow);
%         end
%     end
%     test2result(iDate,1) = sum(avg.*n)./sum(n);
% end

neg = zeros(length(date),1);
pos = neg;
cough_pos = neg;
cough_neg = neg;
fever_pos = neg;
fever_neg = neg;
sorethroat_pos = neg;
sorethroat_neg = neg;
shortbreath_pos = neg;
shortbreath_neg = neg;
headache_pos = neg;
headache_neg = neg;
nosymptoms_pos = neg;
nosymptoms_neg = neg;
ageover60 = neg;
agebelow60 = neg;
agenull = neg;
t = table(date,pos,neg,cough_pos,cough_neg,fever_pos,fever_neg,sorethroat_pos,...
    sorethroat_neg,shortbreath_pos,shortbreath_neg,headache_pos,headache_neg,...
    nosymptoms_pos,nosymptoms_neg,ageover60,agebelow60,agenull);
for iDate = 1:length(date)
    for ij = 1:length(tables)
        row = find(ismember(tables{ij}.cellDateU,date(iDate)));
        if ~isempty(row)
            t{iDate,2:end} = t{iDate,2:end}+tables{ij}{row,2:end};
        end
    end
end

figure;
plot(t.date,100*t.pos./(t.pos+t.neg))
hold on
plot(t.date,100*t.cough_pos./(t.pos+t.neg))
plot(t.date,100*t.cough_neg./(t.pos+t.neg))

figure;
bar(t.date,100*t.pos./(t.pos+t.neg),'b')
hold on
plot(t.date,movmean(100*t.cough_pos./t.pos,[3 3]))
plot(t.date,movmean(100*t.fever_pos./t.pos,[3 3]))
plot(t.date,movmean(100*t.sorethroat_pos./t.pos,[3 3]))
plot(t.date,movmean(100*t.shortbreath_pos./t.pos,[3 3]))
plot(t.date,movmean(100*t.headache_pos./t.pos,[3 3]))
plot(t.date,movmean(100*t.nosymptoms_pos./t.pos,[3 3]))
legend('בדיקות חיוביות מתוך סך הבדיקות','חיוביים עם שיעול','חיוביים עם חום',...
    'חיוביים עם כאב גרון','חיוביים עם קוצר נשימה','חיוביים עם כאב ראש','חיוביים ללא סימפטומים',...
    'location','north');
ylim([0 80])
grid on
% xlim([t.date(1) t.date(end)])
ylabel('%')
title('שיעור הנבדקים החיוביים בעלי תסמינים')
box off
xlim([datetime(2020,6,1) t.date(end)])
writetable(t,'symptoms.csv','delimiter',',','WriteVariableNames',true)

figure;
plot(t.date,t.agebelow60)
hold on
plot(t.date,t.ageover60)
plot(t.date,t.agenull)
legend('below 60','over 60','null')

figure;
plot(t.date,t.agebelow60)
hold on
plot(t.date,t.ageover60)
plot(t.date,t.agenull)
legend('below 60','over 60','null')

over60 = t.ageover60./t.agebelow60;
figure;
plot(t.date,100-100*movmean(over60,[3 3],'omitnan'))
xlim([datetime(2020,6,1) t.date(end)])
ylabel('%')
title('שיעור הנבדקים החיוביים מתחת לגיל 60')
box off
grid on
ylim([50 95])

listD = readtable('dashboard_timeseries.csv');
listD.CountDeath(isnan(listD.CountDeath)) = 0;
listD.new_hospitalized(isnan(listD.new_hospitalized)) = 0;

t.ageover60(t.ageover60 == 0) = nan;
figure
plot(listD.date,movmean(listD.CountDeath,[3 3]))
hold on
plot(t.date+10,movmean(t.ageover60,[3 3])/125)
plot(t.date+10,movmean((t.pos-t.nosymptoms_pos),[3 3])./50)
legend('deaths','positive over 60 / 150','positive with symptoms / 50')
box off
grid on
title('Predict deaths by positive tests 10 days before')
ylabel('Daily deaths')


figure;
plot(listD.date,listD.CountDeath)
hold on
plot(t.date,100*t.pos./(t.pos+t.neg))
plot(t.date,(100*t.pos./(t.pos+t.neg))./(t.fever_pos./t.pos))

symp = (t.fever_pos+t.cough_pos)/2;
%symp = t.cough_pos;
figure;
plot(listD.date,movmean(listD.CountDeath,[3 3]))
hold on
plot(12+t.date,movmean(100*t.pos./(t.pos+t.neg),[3 3]))
plot(12+t.date,movmean((100*t.pos./(t.pos+t.neg))./(symp./t.pos),[3 3])/2.5)


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


% for ij = 1:length(json)
%     clear cell*
%     cellDate = {json{ij}.result.records(:).test_date}';
%     cellDate = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDate);
%     cellDateU = unique(cellDate);
%     cough = ismember({json{ij}.result.records(:).cough}','1');
%     fever = ismember({json{ij}.result.records(:).fever}','1');
%     sore = ismember({json{ij}.result.records(:).sore_throat}','1');
%     breath = ismember({json{ij}.result.records(:).shortness_of_breath}','1');
%     head = ismember({json{ij}.result.records(:).head_ache}','1');
%     positive = ismember({json{ij}.result.records(:).corona_result}','חיובי');
%     negative = ismember({json{ij}.result.records(:).corona_result}','שלילי');
%     other = ismember({json{ij}.result.records(:).corona_result}','אחר');
%     for ii = 1:length(cellDateU)
%         today = ismember(cellDate,cellDateU(ii));
%         cellPos(ii,1) = sum(today & positive);
%         cellNeg(ii,1) = sum(today & negative);
%         cellCoughPos(ii,1) = sum(today & positive & cough);
%         cellCoughNeg(ii,1) = sum(today & negative & cough);
%         cellFeverPos(ii,1) = sum(today & positive & fever);
%         cellFeverNeg(ii,1) = sum(today & negative & fever);
%         cellSorePos(ii,1) = sum(today & positive & sore);
%         cellSoreNeg(ii,1) = sum(today & negative & sore);
%         cellBreathPos(ii,1) = sum(today & positive & breath);
%         cellBreatNeg(ii,1) = sum(today & negative & breath);
%         cellHeadPos(ii,1) = sum(today & positive & head);
%         cellHeadNeg(ii,1) = sum(today & negative & head);
%     end
%     tables{ij,1} = table(cellDateU,cellPos,cellNeg,cellCoughPos,cellCoughNeg,...
%         cellFeverPos,cellFeverNeg,cellSorePos,cellSoreNeg,cellBreathPos,cellBreatNeg,cellHeadPos,cellHeadNeg);
%     IEprog(ij)
% end


% cd ~/covid-19-israel-matlab/data/Israel
% %pop = 9097000;
% listD = readtable('dashboard_timeseries.csv');
% listD.CountDeath(isnan(listD.CountDeath)) = 0;
% listD.new_hospitalized(isnan(listD.new_hospitalized)) = 0;
% endTrain = find(ismember(listD.date,datetime([2020,6,30])));
% deaths = listD.CountDeath;
% deathSmooth = movmean(deaths,[3 3]);
% positiveTests = listD.tests_positive./listD.tests_result*100;
% positiveTests(106:113) = 0.7; % ignore Gymnasia spike
% positiveTestSmooth = movmean(positiveTests,[3 3]);
% % endTrain = length(deathSmooth)-14;
% bP = [ones(endTrain-15,1),positiveTestSmooth(1:endTrain-15)]\deathSmooth(16:endTrain);
% predPositive = movmean([zeros(15,1);[ones(length(positiveTests),1),positiveTests]*bP],[3 3]);
% predPositive(1:37) = 0;
% 
% newHosp = listD.new_hospitalized;
% newHospSmooth = movmean(newHosp,[3 3]);
% [xc,lag] = xcorr(deathSmooth(1:endTrain),newHospSmooth(1:endTrain));
% %figure;
% %plot(lag,xc)
% [~,iMax] = max(xc);
% lagH = lag(iMax);
% bH = [ones(endTrain-lagH+1,1),movmean(newHospSmooth(1:endTrain-lagH+1),[3 3])]\deathSmooth(lagH:endTrain);
% predHosp = movmean([zeros(lagH-1,1);[ones(length(positiveTests),1),newHospSmooth]*bH],[3 3]);
% predHosp(1:37) = 0;
% %% plot
% dP = [listD.date;(listD.date(end)+1:listD.date(end)+15)'];
% dH = [listD.date;(listD.date(end)+1:listD.date(end)+lagH-1)'];
% figure('units','normalized','position',[0,0.25,1,0.5]);
% subplot(1,3,1)
% plot(listD.date,positiveTestSmooth/prctile(positiveTestSmooth,95),'k')
% hold on
% plot(listD.date,newHospSmooth/prctile(newHospSmooth,95),'b')
% plot(listD.date,deathSmooth/prctile(deathSmooth,95),'r')
% legend('Positive tests','New hospitalized','Daily deaths (smoothed)','location','northwest')
% ylabel('normalized units')
% box off
% grid on
% title('Two predictors for death rate')
% subplot(1,3,2)
% plot(dP,predPositive,'k--')
% hold on
% plot(dH,predHosp,'b--')
% plot(listD.date,deaths,'r')
% title('Daily deaths per million')
% legend('predicted by tests','predicted by hospitalizations','daily deaths','location','northwest')
% ylim([0 13])
% box off
% grid on
% ylabel('deaths')
% subplot(1,3,3)
% plot(dP,cumsum(predPositive),'k--')
% hold on
% plot(dH,cumsum(predHosp),'b--')
% plot(listD.date,cumsum(deaths),'r')
% title('Cumulative deaths per million')
% legend('predicted by tests','predicted by hospitalizations','total deaths','location','northwest')
% box off
% grid on
% ylabel('deaths')
% 
% %% hospitalized, not new hospitalized
% listD.Counthospitalized(isnan(listD.Counthospitalized)) = 0;
% hosp = listD.Counthospitalized;
% hospSmooth = movmean(hosp,[3 3]);
% [xc,lag] = xcorr(deathSmooth(1:endTrain),hospSmooth(1:endTrain));
% figure;
% plot(lag,xc)
% [~,iMax] = max(xc);
% lagHt = lag(iMax);
% bHt = [ones(endTrain-lagHt+1,1),movmean(hospSmooth(1:endTrain-lagHt+1),[3 3])]\deathSmooth(lagHt:endTrain);
% predHospTot = movmean([zeros(lagHt-1,1);[ones(length(positiveTests),1),hospSmooth]*bHt],[3 3]);
% predHospTot(1:37) = 0;
% 
% weekend = (listD.tests_result(80:end)-movmean(listD.tests_result(80:end),[3 3]))\posd(80:end);
% 
% figure;
% plot(listD.date,positiveTests)
% hold on
% plot(listD.date,positiveTests+(listD.tests_result-movmean(listD.tests_result,[3 3]))*weekend);
% 
%% test result gap
ii = 0;
read = true;
clear tables
while read
    tic;
    json = urlread(['https://data.gov.il/api/3/action/datastore_search?resource_id=dcf999c1-d394-4b57-a5e0-9d014a62e046&limit=100000&offset=',str(ii)]);
    if length(json) > 10000
        json = strrep(json,'NULL','2020-01-01');
        json = jsondecode(json);
        
        clear cell*
        
        cellDateR = {json.result.records(:).result_date}';
        cellDateR = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDateR); %#ok<*ST2NM>
        cellDateT = {json.result.records(:).test_date}';
        cellDateT = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDateT); %#ok<*ST2NM>
        cellDateU = unique(cellDateR);
        cellDateU(cellDateU == datetime(2020,1,1)) = [];
        for jj = 1:length(cellDateU)
            iii = ismember({json.result.records(:).corona_result}',{'חיובי','שלילי'}) & ...
                ismember({json.result.records(:).is_first_Test}','Yes') & ...
                cellDateR == cellDateU(jj);
            cellT = cellDateT(iii);
            cellT(cellT == datetime(2020,1,1)) = [];
            bad = datenum(cellDateU(jj)-cellT) > 7 | datenum(cellDateU(jj)-cellT) < 0;
            cellT(bad) = [];
            cellDif(jj,1) = mean(datenum(cellDateU(jj)-cellT));
            cellN(jj,1) = length(cellT);
        end
        cellDateU = cellDateU(~isnan(cellDif));
        cellN(isnan(cellDif)) = [];
        cellDif(isnan(cellDif)) = [];
        
        tables{ii/100000+1,1} = table(cellDateU,cellDif,cellN);
        disp(cellDateU(1));
    else
        read = false;
        json = json(1:end-1);
        disp('done')
    end
    ii = ii+100000;
end
disp('XXXXXXXXXXXXX')

date = [];
for ij = 1:length(tables)
    date = [date;tables{ij}.cellDateU];
end
date = unique(date);
test2result = nan(size(date));
for iDate = 1:length(date)
    n = [];
    avg = [];
    for ij = 1:length(tables)
        iRow = ismember(tables{ij}.cellDateU,date(iDate));
        if sum(iRow) > 0
        	n(end+1,1) = tables{ij}.cellN(iRow);
            avg(end+1,1) = tables{ij}.cellDif(iRow);
        end
    end
    test2result(iDate,1) = sum(avg.*n)./sum(n);
end
figure;plot(date,test2result)
%% old
% for ij = 1:length(json)
%     clear cell*
%     cellDate = {json{ij}.result.records(:).test_date}';
%     cellDate = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDate); %#ok<*ST2NM>
%     cellDateU = unique(cellDate);
%     for ii = 1:length(cellDateU)
%         cellPosFirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','Yes')); %#ok<*SAGROW>
%         cellPosNotfirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','No'));
%         cellNegFirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','שלילי') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
%         cellNegNotfirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','שלילי') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','No'));
%         cellPosmargFirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי גבולי') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
%         cellPosmargNotfirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','חיובי גבולי') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','No'));
%         cellUncertainFirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','לא ודאי') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
%         cellUncertainNotfirst(ii,1) = sum(ismember({json{ij}.result.records(:).corona_result}','לא ודאי') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','No'));
%         cellErrFirst(ii,1) = sum(contains({json{ij}.result.records(:).corona_result}','פסול') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','Yes'));
%         cellErrNotfirst(ii,1) = sum(contains({json{ij}.result.records(:).corona_result}','פסול') & ...
%             cellDate == cellDateU(ii) & ...
%             ismember({json{ij}.result.records(:).is_first_Test}','No'));
%     end
%     tables{ij,1} = table(cellDateU,cellNegFirst,cellPosFirst,cellPosmargFirst,cellUncertainFirst,cellErrFirst,...
%         cellNegNotfirst,cellPosNotfirst,cellPosmargNotfirst,cellUncertainNotfirst,cellErrNotfirst);
%     IEprog(ij)
% end
% date = [];
% for ij = 1:length(json)
%     date = [date;tables{ij}.cellDateU];
% end
% date = unique(date);
% neg_first = zeros(length(date),1);
% pos_first = zeros(length(date),1);
% posmarg_first = zeros(length(date),1);
% uncertain_first = zeros(length(date),1);
% err_first = zeros(length(date),1);
% neg_notfirst = zeros(length(date),1);
% pos_notfirst = zeros(length(date),1);
% posmarg_notfirst = zeros(length(date),1);
% uncertain_notfirst = zeros(length(date),1);
% err_notfirst = zeros(length(date),1);
% t = table(date,neg_first,pos_first,posmarg_first,uncertain_first,err_first,...
%     neg_notfirst,pos_notfirst,posmarg_notfirst,uncertain_notfirst,err_notfirst);
% for iDate = 1:length(date)
%     for ij = 1:length(tables)
%         row = find(ismember(tables{ij}.cellDateU,date(iDate)));
%         if ~isempty(row)
%             t{iDate,2:end} = t{iDate,2:end}+tables{ij}{row,2:end};
%         end
%     end
% end
% t(1,:) = [];
% writetable(t,'data/Israel/tests.csv','delimiter',',','WriteVariableNames',true)
% %% 
% t = readtable('tests.csv');
% figure;
% bar(t.date,[t.pos_first,t.posmarg_first,t.uncertain_first,t.err_first],'stacked','linestyle','none')
% hold on
% plot(listD.date,listD.tests_positive)
% legend('positive','marginally positive','uncertain','error')
% 
% figure;
% plot(t.date,cumsum(t.pos_first+t.posmarg_first))  % [t.pos_first,t.posmarg_first,t.uncertain_first,t.err_first],'stacked','linestyle','none')
% hold on
% plot(listD.date,cumsum(listD.tests_positive))
% 
% allPos = (t.pos_first+t.pos_notfirst+t.posmarg_first+t.posmarg_notfirst)./sum(t{:,2:end},2)*100;
% allPos(79:82) = 2;
% allPos = movmean(allPos,[3 3]);
% 
% bPa = [ones(97,1),allPos(1:112-15)]\deathSmooth(44:endTrain);
% predPositiveA = [zeros(15,1);[ones(length(allPos),1),allPos]*bPa];
% figure;
% plot(listD.date,listD.CountDeath);
% hold on
% plot(t.date(16):t.date(16)+length(predPositiveA)-1,predPositiveA)
% 
%% 


%% 
% cd ~/covid-19-israel-matlab/data/Israel
% listD = readtable('dashboard_timeseries.csv');
% listD.CountDeath(isnan(listD.CountDeath)) = 0;
% listD.new_hospitalized(isnan(listD.new_hospitalized)) = 0;
% endTrain = find(ismember(listD.date,datetime([2020,6,30])));
% deaths = listD.CountDeath;
% deathSmooth = movmean(deaths,[3 3]);
% positiveTests = listD.tests_positive./listD.tests_result*100;
% positiveTests(106:113) = 0.7; % ignore Gymnasia spike
% positiveTestSmooth = movmean(positiveTests,[3 3]);
% % endTrain = length(deathSmooth)-14;
% bP = [ones(endTrain-15,1),positiveTestSmooth(1:endTrain-15)]\deathSmooth(16:endTrain);
% predPositive = movmean([zeros(15,1);[ones(length(positiveTests),1),positiveTests]*bP],[3 3]);
% predPositive(1:37) = 0;
% 
% newHosp = listD.new_hospitalized;
% newHospSmooth = movmean(newHosp,[3 3]);
% [xc,lag] = xcorr(deathSmooth(1:endTrain),newHospSmooth(1:endTrain));
% [~,iMax] = max(xc);
% lagH = lag(iMax);
% bH = [ones(endTrain-lagH+1,1),movmean(newHospSmooth(1:endTrain-lagH+1),[3 3])]\deathSmooth(lagH:endTrain);
% predHosp = movmean([zeros(lagH-1,1);[ones(length(positiveTests),1),newHospSmooth]*bH],[3 3]);
% predHosp(1:37) = 0;
% 
% sym = readtable('symptoms.csv');
% shortSmooth = movmean(sym.shortbreath_pos,[3 3]);
% lagS = 16;
% [~,endTrainSym] = ismember(listD.date(endTrain),sym.date);
% tmp = shortSmooth(22:endTrainSym-lagS+1);
% bS = [ones(length(tmp),1),tmp]\...
%     deathSmooth(days(sym.date(1)-listD.date(1))+lagS+21:endTrain);
% predSym = [zeros(lagS-1,1);[ones(length(shortSmooth),1),shortSmooth]*bS];
% %predSym(1:37) = 0;
% 
% dP = [listD.date;(listD.date(end)+1:listD.date(end)+15)'];
% dH = [listD.date;(listD.date(end)+1:listD.date(end)+lagH-1)'];
% dS = [sym.date;(sym.date(end)+1:sym.date(end)+lagS-1)'];
% 
% figure('units','normalized','position',[0,0.25,1,0.5]);
% subplot(1,2,1)
% plot(dP,predPositive,'k--')
% hold on
% plot(dH,predHosp,'b--')
% plot(dS,predSym,'g--')
% plot(listD.date,deaths,'r')
% title('Daily deaths per million')
% legend('predicted by tests','predicted by hospitalizations','predicted by short breath','total deaths','location','northwest')
% ylim([0 13])
% box off
% grid on
% ylabel('deaths')
% 
% subplot(1,2,2)
% plot(dP,cumsum(predPositive),'k--')
% hold on
% plot(dH,cumsum(predHosp),'b--')
% plot(dS,cumsum(predSym),'g--')
% plot(listD.date,cumsum(deaths),'r')
% title('Cumulative deaths per million')
% legend('predicted by tests','predicted by hospitalizations','predicted by short breath','total deaths','location','northwest')
% box off
% grid on
% ylabel('deaths')
% 
% 
% %%
% shortSmooth = movmean(sym.pos./(sym.pos+sym.neg),[3 3]);
% lagS = 16;
% [~,endTrainSym] = ismember(listD.date(endTrain),sym.date);
% tmp = shortSmooth(22:endTrainSym-lagS+1);
% bS = [ones(length(tmp),1),tmp]\...
%     deathSmooth(days(sym.date(1)-listD.date(1))+lagS+21:endTrain);
% predSym = [zeros(lagS-1,1);[ones(length(shortSmooth),1),shortSmooth]*bS];