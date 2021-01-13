function covid_Israel_moh_dashboard

cd ~/covid-19-israel-matlab/
dataPrev = readtable('data/Israel/dashboard_timeseries.csv');
%!curl 'https://datadashboardapi.health.gov.il/api/queries/_batch' -H 'Accept: application/json, text/plain, */*' -H 'Referer: https://datadashboard.health.gov.il/COVID-19/' -H 'Origin: https://datadashboard.health.gov.il' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36' -H 'DNT: 1' -H 'Content-Type: application/json' --data-binary '{"requests":[{"id":"0","queryName":"lastUpdate","single":true,"parameters":{}},{"id":"1","queryName":"infectedPerDate","single":false,"parameters":{}},{"id":"2","queryName":"updatedPatientsOverallStatus","single":false,"parameters":{}},{"id":"3","queryName":"sickPerDateTwoDays","single":false,"parameters":{}},{"id":"4","queryName":"sickPerLocation","single":false,"parameters":{}},{"id":"5","queryName":"patientsPerDate","single":false,"parameters":{}},{"id":"6","queryName":"deadPatientsPerDate","single":false,"parameters":{}},{"id":"7","queryName":"recoveredPerDay","single":false,"parameters":{}},{"id":"8","queryName":"testResultsPerDate","single":false,"parameters":{}},{"id":"9","queryName":"infectedPerDate","single":false,"parameters":{}},{"id":"10","queryName":"patientsPerDate","single":false,"parameters":{}},{"id":"11","queryName":"doublingRate","single":false,"parameters":{}},{"id":"12","queryName":"infectedByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}},{"id":"13","queryName":"isolatedDoctorsAndNurses","single":true,"parameters":{}},{"id":"14","queryName":"testResultsPerDate","single":false,"parameters":{}},{"id":"15","queryName":"contagionDataPerCityPublic","single":false,"parameters":{}},{"id":"16","queryName":"hospitalStatus","single":false,"parameters":{}}]}' --compressed -o tmp.json
%!curl 'https://datadashboardapi.health.gov.il/api/queries/_batch' -H 'Accept: application/json, text/plain, */*' -H 'Referer: https://datadashboard.health.gov.il/COVID-19/' -H 'Origin: https://datadashboard.health.gov.il' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36' -H 'DNT: 1' -H 'Content-Type: application/json' --data-binary '{"requests":[{"id":"5","queryName":"patientsPerDate","single":false,"parameters":{}}]}' --compressed -o tmp.json
% [~,~] = system(['curl ''','https://datadashboardapi.health.gov.il/api/queries/_batch''',' -H ''','Accept: application/json, text/plain, */*''',' -H ''','Referer: https://datadashboard.health.gov.il/COVID-19/''',' -H ''','Origin: https://datadashboard.health.gov.il''',' -H ''','User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36''',' -H ''','DNT: 1''',' -H ''','Content-Type: application/json''',' --data-binary ''','{"requests":[{"id":"time","queryName":"lastUpdate","single":false,"parameters":{}},{"id":"confirmed","queryName":"infectedPerDate","single":false,"parameters":{}},{"id":"conf2days","queryName":"sickPerDateTwoDays","single":false,"parameters":{}},{"id":"home_hospital","queryName":"sickPerLocation","single":false,"parameters":{}},{"id":"table","queryName":"patientsPerDate","single":false,"parameters":{}},{"id":"recovered","queryName":"recoveredPerDay","single":false,"parameters":{}},{"id":"tests_positive","queryName":"testResultsPerDate","single":false,"parameters":{}},{"id":"doubling","queryName":"doublingRate","single":false,"parameters":{}},{"id":"age_gender","queryName":"infectedByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}},{"id":"staff","queryName":"isolatedDoctorsAndNurses","single":false,"parameters":{}},{"id":"city","queryName":"contagionDataPerCityPublic","single":false,"parameters":{}},{"id":"hospital","queryName":"hospitalStatus","single":false,"parameters":{}}]}''',' --compressed -o data/Israel/dashboard.json']);
[~,~] = system(['curl ''','https://datadashboardapi.health.gov.il/api/queries/_batch''',' -H ''','Accept: application/json, text/plain, */*''',' -H ''','Referer: https://datadashboard.health.gov.il/COVID-19/''',' -H ''','Origin: https://datadashboard.health.gov.il''',' -H ''','User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36''',' -H ''','DNT: 1''',' -H ''','Content-Type: application/json''',' --data-binary ''',...
    '{"requests":[',...
    '{"id":"time","queryName":"lastUpdate","single":false,"parameters":{}},',...
    '{"id":"confirmed","queryName":"infectedPerDate","single":false,"parameters":{}},',...
    '{"id":"conf2days","queryName":"sickPerDateTwoDays","single":false,"parameters":{}},',...
    '{"id":"home_hospital","queryName":"sickPerLocation","single":false,"parameters":{}},',...
    '{"id":"table","queryName":"patientsPerDate","single":false,"parameters":{}},',...
    '{"id":"recovered","queryName":"recoveredPerDay","single":false,"parameters":{}},',...
    '{"id":"tests_positive","queryName":"testResultsPerDate","single":false,"parameters":{}},',...
    '{"id":"doubling","queryName":"doublingRate","single":false,"parameters":{}},',...
    '{"id":"age_gender","queryName":"infectedByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}},',...
    '{"id":"staff","queryName":"isolatedDoctorsAndNurses","single":false,"parameters":{}},',...
    '{"id":"city","queryName":"contagionDataPerCityPublic","single":false,"parameters":{}},',...
    '{"id":"hospital","queryName":"hospitalStatus","single":false,"parameters":{}},',...
    '{"id":"infectedByAge","queryName":"infectedByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}},',...
    '{"id":"breathByAge","queryName":"breatheByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}},',...
    '{"id":"severeByAge","queryName":"severeByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}},',...
    '{"id":"deadByAge","queryName":"deadByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}}]}''',...
    ' --compressed -o data/Israel/dashboard.json']);

fid = fopen('data/Israel/dashboard.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
json = jsondecode(txt);


iTests = find(ismember({json(:).id},'tests_positive'));
date = datetime(cellfun(@(x) x(1:10),{json(iTests).data.date}','UniformOutput',false));
tests = [json(iTests).data.amount]';
tests_result = [json(iTests).data.amountVirusDiagnosis]';
tests_positive = [json(iTests).data.positiveAmount]';
bad = cellfun(@(x) str2double(x(13)),{json(iTests).data.date}');
bad(1:find(tests_positive == 0,1)-1) = true;
data = table(date,tests,tests_result,tests_positive);
data = data(~bad,:);
if ~isequal(data(end,1:4),dataPrev(end,1:4))
    tests0 = sum(tests(1:find(tests_positive == 0,1)-1));
    data.tests_cumulative = cumsum(data.tests)+tests0;
    clear date tests positive_tests
    iTable = find(ismember({json(:).id},'table'));
    dateTable = datetime(cellfun(@(x) x(1:10),{json(iTable).data.date}','UniformOutput',false));
    [~,row] = ismember(dateTable,data.date);
    % t = table(date);
    field = fieldnames(json(iTable).data);
    for fi = field(2:end)'
        col = nan(height(data),1);
        vec = eval(['[json(iTable).data.',fi{1},']''',';']);
        if length(vec) < length(dateTable)
            vec(end+1:length(dateTable)) = nan;
        end
        col(row) = vec;
        eval(['data.',fi{1},' = col;'])
    end
    iRec = find(ismember({json(:).id},'recovered'));
    firstRec = find(~cellfun(@isempty,{json(iRec).data.date}'),1);
    dateRec = datetime(cellfun(@(x) x(1:10),{json(iRec).data(firstRec:end).date}','UniformOutput',false));
    recovered = [json(iRec).data(firstRec:end).amount]';
    data.recovered = nan(height(data),1);
    [isRow,row] = ismember(dateRec,data.date);
    data.recovered(row(isRow)) = recovered(isRow);
    data = [dataPrev(1:find(ismember(dataPrev.date,data.date),1)-1,:);data];
    nanwritetable(data,'data/Israel/dashboard_timeseries.csv');
end

%% age gender 
% infected total, severe today, on vent today, dead total
ageGen = readtable('data/Israel/dashboard_age_gen.csv');
jDate = datetime([json(1).data.lastUpdate(1:10),' ',json(1).data.lastUpdate(12:16)])+3/24;
if ~isequal(jDate,ageGen.date(end))
    warning off
    ageGen.date(end+1) = jDate;
    warning on
    order = [1,3,2,4];
    for ag = 1:4
        into = 2+(((ag-1)*20+1):2:ag*20);
        empty = cellfun(@isempty,{json(12+order(ag)).data.male});
        into(empty) = [];
        ageGen{end,into} = [json(12+order(ag)).data.male];
        into = 1+(((ag-1)*20+1):2:ag*20);
        empty = cellfun(@isempty,{json(12+order(ag)).data.female});
        into(empty) = [];
        ageGen{end,into} = [json(12+order(ag)).data.female];
    end
    nanwritetable(ageGen,'data/Israel/dashboard_age_gen.csv');
end
