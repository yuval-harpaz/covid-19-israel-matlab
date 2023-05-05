function covid_Israel_moh_dashboard2

cd ~/covid-19-israel-matlab/
dataPrev = readtable('data/Israel/dashboard_timeseries.csv');

[~,~] = system(['curl -k ''','https://datadashboardapi.health.gov.il/api/queries/_batch''',' -H ''','Accept: application/json, text/plain, */*''',' -H ''','Referer: https://datadashboard.health.gov.il/COVID-19/''',' -H ''','Origin: https://datadashboard.health.gov.il''',' -H ''','User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36''',' -H ''','DNT: 1''',' -H ''','Content-Type: application/json''',' --data-binary ''',...
    '{"requests":[',...
    '{"id":"time","queryName":"lastUpdate","single":false,"parameters":{}},',...
    '{"id":"confirmed","queryName":"infectedPerDate","single":false,"parameters":{}},',...
    '{"id":"tests_positive","queryName":"testResultsPerDate","single":false,"parameters":{}}]}''',...
    ' --compressed -o data/Israel/dashboard.json']);

fid = fopen('data/Israel/dashboard.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
json = jsondecode(txt);


%% bug with test results

!wget -O tmp.json --no-check-certificate https://datadashboardapi.health.gov.il/api/queries/testResultsPerDate
fid = fopen('tmp.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
json3 = jsondecode(txt);
json(3).data = json3; % bug
%% bug with test results

!wget -O tmp.json --no-check-certificate https://datadashboardapi.health.gov.il/api/queries/infectedPerDate
fid = fopen('tmp.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
json2 = jsondecode(txt);
json(2).data = json2; % bug

%%
!wget -O tmp.json --no-check-certificate https://datadashboardapi.health.gov.il/api/queries/hospitalizationStatus 
fid = fopen('tmp.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
json1 = jsondecode(txt);
% json1 = urlread('https://datadashboardapi.health.gov.il/api/queries/hospitalizationStatus');
% json1 = jsondecode(json1);
hosp = struct2table(json1);
hosp.dayDate = datetime(strrep(hosp.dayDate,'T00:00:00.000Z',''));
if ~isequal(hosp.dayDate,unique(hosp.dayDate))
    [a,b,c] = unique(hosp.dayDate);
    warning('duplicate dates')
    disp(datestr(hosp.dayDate(~ismember(1:height(hosp),b))))
    hosp = hosp(b,:);
end
% vars1 = data.Properties.VariableNames(2:end)';
vars1 = {'countHospitalized','CountHospitalized';'countHospitalizedWithoutRelease','';'countHardStatus','CountHardStatus';'countMediumStatus','CountMediumStatus';'countEasyStatus','CountEasyStatus';'countBreath','CountBreath';'countDeath','CountDeath';'totalBeds','';'standardOccupancy','';'numVisits','';'patientsHome','';'patientsHotel','';'countBreathCum','CountBreathCum';'countDeathCum','';'countCriticalStatus','CountCriticalStatus';'countSeriousCriticalCum','CountSeriousCriticalCum';'seriousCriticalNew','serious_critical_new';'countEcmo','count_ecmo';'countDeadAvg7days','';'mediumNew','medium_new';'easyNew','easy_new'};
col = find(~cellfun(@isempty, vars1(:,2)));
hosp.countEcmo(cellfun(@isempty, hosp.countEcmo)) = {nan};
hosp.countEcmo = [hosp.countEcmo{:}]';

%%
% confirmed = struct2table(json(2).data);
% confirmed.date = cellfun(@(x) datetime(x(1:10)),confirmed.date);
% writetable(confirmed,'data/Israel/confirmed.csv','Delimiter',',','WriteVariableNames',true);

iTests = find(ismember({json(:).id},'tests_positive'));
date = datetime(cellfun(@(x) x(1:10),{json(iTests).data.date}','UniformOutput',false));
tests = [json(iTests).data.amount]';
tests_result = [json(iTests).data.amountVirusDiagnosis]';
tests_positive = [json(iTests).data.positiveAmount]';
tests_survey = [json(iTests).data.amountMagen]';
bad = cellfun(@(x) str2double(x(13)),{json(iTests).data.date}');
bad(1:find(tests_positive == 0,1)-1) = true;
data = table(date,tests,tests_result,tests_positive,tests_survey);
data = data(~bad,:);
vars = {'CountDeath';'CountDeathCum';'CountEasyStatus';'CountMediumStatus';'CountHardStatus';'CountBreath';'tests_cumulative';...
    'new_hospitalized';'CountHospitalized';'CountBreathCum';'CountCriticalStatus';'CountSeriousCriticalCum';...
    'serious_critical_new';'medium_new';'easy_new';'count_ecmo';'tests_positive1';'recovered';'tests1'};
vars(:,2) = {''};
low = [1:6,9:12];
vars(low,2) = cellfun(@(x) [lower(x(1)),x(2:end)],vars(low,1),'UniformOutput',false);
vars([7,12:15]+1,2) = {'newHospitalized','seriousCriticalNew','mediumNew','easyNew','countEcmo'};
warning off
data.CountDeath(1) = nan;
warning on
data.CountDeath(:) = nan;

hosp.Properties.VariableNames{1} = 'date';
[~,idx] = ismember(hosp.date,data.date);
if any(idx == 0)
    error('missing dates')
end


% !wget -O tmp.json --no-check-certificate https://datadashboardapi.health.gov.il/api/queries/https://datadashboardapi.health.gov.il/api/queries/deadPatientsPerDate
% fid = fopen('tmp.json','r');
% txt = fread(fid)';
% fclose(fid);
% txt = native2unicode(txt);
% json4 = jsondecode(txt);
% !rm tmp.json
% % options=weboptions; 
% % options.CertificateFilename=''; 
% % death1 = urlread('https://datadashboardapi.health.gov.il/api/queries/deadPatientsPerDate', options);
% death1 = struct2table(json4);
% dateDeaths = datetime(strrep(death1.date,'T00:00:00.000Z',''));
% death1 = death1.amount;

data.CountDeath(idx) = hosp.countDeath;
for ii = 2:length(vars)
    eval(['data.',vars{ii},' = nan(size(data.CountDeath));'])
    if ~isempty(vars{ii,2})
        eval(['data.',vars{ii},'(idx) = hosp.',vars{ii,2},';'])
    end
end



if ~isequal(data(end,1:4),dataPrev(end,1:4))
    tests0 = sum(tests(1:find(tests_positive == 0,1)-1));
    data.tests_cumulative = cumsum(data.tests)+tests0;
    clear date tests positive_tests
%     iTable = find(ismember({json(:).id},'table'));
%     dateTable = datetime(cellfun(@(x) x(1:10),{json(iTable).data.date}','UniformOutput',false));
%     [isRow,row] = ismember(dateTable,data.date);
    % t = table(date);
%     field = fieldnames(json(iTable).data);
%     for fi = field(2:end)'
%         col = nan(height(data),1);
%         vec = eval(['[json(iTable).data.',fi{1},']''',';']);
%         if length(vec) < length(dateTable)
%             vec(end+1:length(dateTable)) = nan;
%         end
%         col(row(isRow)) = vec(isRow);
%         eval(['data.',fi{1},' = col;'])
%     end
%     iRec = find(ismember({json(:).id},'recovered'));
%     firstRec = find(~cellfun(@isempty,{json(iRec).data.date}'),1);
%     dateRec = datetime(cellfun(@(x) x(1:10),{json(iRec).data(firstRec:end).date}','UniformOutput',false));
%     recovered = [json(iRec).data(firstRec:end).amount]';
%     data.recovered = nan(height(data),1);
%     [isRow,row] = ismember(dateRec,data.date);
%     data.recovered(row(isRow)) = recovered(isRow);
    
    iConf = find(ismember({json(:).id},'confirmed'));
    firstConf = find(~cellfun(@isempty,{json(iConf).data.date}'),1);
    dateConf = datetime(cellfun(@(x) x(1:10),{json(iConf).data(firstConf:end).date}','UniformOutput',false));
    tests_positive1 = [json(iConf).data(firstConf:end).amount]';
    recovered = [json(iConf).data(firstConf:end).recovered]';
    data.tests_positive1 = nan(height(data),1);
    [isRow,row] = ismember(dateConf,data.date);
    data.tests_positive1(row(isRow)) = tests_positive1(isRow);
    data.recovered(row(isRow)) = recovered(isRow);
    
    iPeople = find(ismember({json(:).id},'tests_positive'));
    firstPeople = find(~cellfun(@isempty,{json(iPeople).data.date}'),1);
    datePeople = datetime(cellfun(@(x) x(1:10),{json(iPeople).data(firstPeople:end).date}','UniformOutput',false));
    tests1 = [json(iPeople).data(firstPeople:end).amountPersonTested]';
    data.tests1 = nan(height(data),1);
    [isRow,row] = ismember(datePeople,data.date);
    data.tests1(row(isRow)) = tests1(isRow);
    iStart = find(ismember(dataPrev.date,data.date),1);
    iEnd = days(data.date(end)-dataPrev.date(end))+height(dataPrev);
    dataNew = dataPrev;
    for iField = 1:length(dataPrev.Properties.VariableNames)
        col = find(ismember(data.Properties.VariableNames,dataPrev.Properties.VariableNames{iField}));
        if ~isempty(col)
            dataNew{iStart:iEnd,iField} = data{:,col};
        end
    end
%     iEcmo = find(ismember({json(:).id},'ecmo'));
%     dataNew.count_ecmo(end) = json(iEcmo).data.countEcmo;
%     dataNew.CountBreath(end) = json(iEcmo).data.countBreath;
%     dataNew.CountCriticalStatus(end) = json(iEcmo).data.countCriticalStatus;
%     dataNew.CountHospitalized(end) = json(iEcmo).data.countEasyStatus+json(iEcmo).data.countMediumStatus+json(iEcmo).data.countHardStatus;
%     data = [dataPrev(1:find(ismember(dataPrev.date,data.date),1)-1,:);data];
%     missingNew = find(isnan(dataNew.new_hospitalized),1,'last');
%     if missingNew < height(dataNew) && missingNew > 700
%         dataNew.new_hospitalized(missingNew:end) = nan;
%     end
%     for column = find(ismember(dataNew.Properties.VariableNames,{'CountBreathCum','CountSeriousCriticalCum'}))
%         missingNew = find(dataNew{:,column} > 0,1,'last');
%         if missingNew < height(dataNew) && missingNew > 700
%             dataNew{missingNew+1:end,column} = nan;
%         end
%     end
    %
%     if sum(hosp.countDeath) < sum(death1)
%         warning(['hospitalizationStatus not up to date? ',str(sum(hosp.countDeath)),...
%             ' instead of ',str(sum(death1)),' deaaths'])
%         iStart = find(ismember(dataPrev.date,data.date),1);
%         [isx,idx] = ismember(dataNew.date,dateDeaths);
%         data.CountDeath(idx(isx)) = death1;
%         %     hosp.countDeath(idx) = death1;
%     end
    nanwritetable(dataNew,'data/Israel/dashboard_timeseries.csv');
end

%% age gender 
% infected total, severe today, on vent today, dead total
% ageGen = readtable('data/Israel/dashboard_age_gen.csv');
% jDate = datetime([json(1).data.lastUpdate(1:10),' ',json(1).data.lastUpdate(12:16)])+3/24;
% if ~isequal(jDate,ageGen.date(end))
%     warning off
%     ageGen.date(end+1) = jDate;
%     warning on
%     order = [1,3,2,4];
%     for ag = 1:4
%         into = 2+(((ag-1)*20+1):2:ag*20);
%         empty = cellfun(@isempty,{json(12+order(ag)).data.male});
%         into(empty) = [];
%         ageGen{end,into} = [json(12+order(ag)).data.male];
%         into = 1+(((ag-1)*20+1):2:ag*20);
%         empty = cellfun(@isempty,{json(12+order(ag)).data.female});
%         into(empty) = [];
%         ageGen{end,into} = [json(12+order(ag)).data.female];
%     end
%     nanwritetable(ageGen,'data/Israel/dashboard_age_gen.csv');
% end
