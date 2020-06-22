function covid_Israel_moh_dashboard

cd ~/covid-19-israel-matlab/
%!curl 'https://datadashboardapi.health.gov.il/api/queries/_batch' -H 'Accept: application/json, text/plain, */*' -H 'Referer: https://datadashboard.health.gov.il/COVID-19/' -H 'Origin: https://datadashboard.health.gov.il' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36' -H 'DNT: 1' -H 'Content-Type: application/json' --data-binary '{"requests":[{"id":"0","queryName":"lastUpdate","single":true,"parameters":{}},{"id":"1","queryName":"infectedPerDate","single":false,"parameters":{}},{"id":"2","queryName":"updatedPatientsOverallStatus","single":false,"parameters":{}},{"id":"3","queryName":"sickPerDateTwoDays","single":false,"parameters":{}},{"id":"4","queryName":"sickPerLocation","single":false,"parameters":{}},{"id":"5","queryName":"patientsPerDate","single":false,"parameters":{}},{"id":"6","queryName":"deadPatientsPerDate","single":false,"parameters":{}},{"id":"7","queryName":"recoveredPerDay","single":false,"parameters":{}},{"id":"8","queryName":"testResultsPerDate","single":false,"parameters":{}},{"id":"9","queryName":"infectedPerDate","single":false,"parameters":{}},{"id":"10","queryName":"patientsPerDate","single":false,"parameters":{}},{"id":"11","queryName":"doublingRate","single":false,"parameters":{}},{"id":"12","queryName":"infectedByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}},{"id":"13","queryName":"isolatedDoctorsAndNurses","single":true,"parameters":{}},{"id":"14","queryName":"testResultsPerDate","single":false,"parameters":{}},{"id":"15","queryName":"contagionDataPerCityPublic","single":false,"parameters":{}},{"id":"16","queryName":"hospitalStatus","single":false,"parameters":{}}]}' --compressed -o tmp.json
%!curl 'https://datadashboardapi.health.gov.il/api/queries/_batch' -H 'Accept: application/json, text/plain, */*' -H 'Referer: https://datadashboard.health.gov.il/COVID-19/' -H 'Origin: https://datadashboard.health.gov.il' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36' -H 'DNT: 1' -H 'Content-Type: application/json' --data-binary '{"requests":[{"id":"5","queryName":"patientsPerDate","single":false,"parameters":{}}]}' --compressed -o tmp.json
!curl 'https://datadashboardapi.health.gov.il/api/queries/_batch' -H 'Accept: application/json, text/plain, */*' -H 'Referer: https://datadashboard.health.gov.il/COVID-19/' -H 'Origin: https://datadashboard.health.gov.il' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36' -H 'DNT: 1' -H 'Content-Type: application/json' --data-binary '{"requests":[{"id":"time","queryName":"lastUpdate","single":false,"parameters":{}},{"id":"confirmed","queryName":"infectedPerDate","single":false,"parameters":{}},{"id":"conf2days","queryName":"sickPerDateTwoDays","single":false,"parameters":{}},{"id":"home_hospital","queryName":"sickPerLocation","single":false,"parameters":{}},{"id":"table","queryName":"patientsPerDate","single":false,"parameters":{}},{"id":"dead","queryName":"deadPatientsPerDate","single":false,"parameters":{}},{"id":"recovered","queryName":"recoveredPerDay","single":false,"parameters":{}},{"id":"tests_positive","queryName":"testResultsPerDate","single":false,"parameters":{}},{"id":"doubling","queryName":"doublingRate","single":false,"parameters":{}},{"id":"age_gender","queryName":"infectedByAgeAndGenderPublic","single":false,"parameters":{"ageSections":[0,10,20,30,40,50,60,70,80,90]}},{"id":"staff","queryName":"isolatedDoctorsAndNurses","single":false,"parameters":{}},{"id":"city","queryName":"contagionDataPerCityPublic","single":false,"parameters":{}},{"id":"hospital","queryName":"hospitalStatus","single":false,"parameters":{}}]}' --compressed -o tmp.json

fid = fopen('tmp.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
json = jsondecode(txt);

iTable = find(ismember({json(:).id},'table'));
date = datetime(cellfun(@(x) x(1:10),{json(iTable).data.date}','UniformOutput',false));
t = table(date);
field = fieldnames(json(iTable).data);
for fi = field(2:end)'
    vec = eval(['[json(iTable).data.',fi{1},']''',';']);
    if length(vec) < height(t)
        vec(end+1:height(t)) = nan;
    end
    eval(['t.',fi{1},' = vec;'])
end
writetable(t,'data/Israel/dashboard_data.csv','Delimiter',',','WriteVariableNames',true);
% discharged = t.Counthospitalized-t.Counthospitalized_without_release-t.CountDeath;