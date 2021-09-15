function covid_severe3
t = readtable('~/covid-19-israel-matlab/data/Israel/severe60.csv');
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');

json = urlread('https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily');
json = jsondecode(json);
severe = struct2table(json);
severe.day_date = datetime(strrep(severe.day_date,'T00:00:00.000Z',''));
severe.Properties.VariableNames{1} = 'date';


iOld = ismember(severe.age_group,'מעל גיל 60');
iYoung = ismember(severe.age_group,'מתחת לגיל 60');
idx = find(t.date == severe.date(1));
idx = idx:idx+sum(iOld)-1;

t.date(end+1:idx(end)) = t.date(end)+(1:(idx(end)-height(t)))';
for ii = 4:2:8
    t{idx,ii} = severe{iOld,ii/2+4};
end
for ii = 5:2:9
    t{idx,ii} = severe{iYoung,ii/2+3.5};
end

% jdx = ismember(listD.date,t.date);
t.total = diff(listD.CountSeriousCriticalCum(293:end));
t{241:end,2:3} = [sum(t{241:end,4:2:8},2),sum(t{241:end,5:2:9},2)];

figure;
plot(t.date,[sum(t{:,2:3},2),sum(t{:,4:9},2),t.total])
legend('below and above 60','below and above 60 by vacc','all')

writetable(t,'~/covid-19-israel-matlab/data/Israel/severe60.csv','Delimiter',',','WriteVariableNames',true);

figure;
plot(listD.date,movmean(listD.CountDeath,[3 3]),'k')
hold on
plot(t.date+7,movmean(sum(t{:,2:3}.*[0.45,0.05],2),[3 3]))
xlim(t.date([1,end]))
