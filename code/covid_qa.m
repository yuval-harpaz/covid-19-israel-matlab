listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
!wget -O ~/Downloads/all_dashboard_timeseries.csv https://raw.githubusercontent.com/erasta/CovidDataIsrael/master/out/csv/all_dashboard_timeseries.csv

list = readtable('~/Downloads/all_dashboard_timeseries.csv');
vars = {'cases','tests_positive1';...
        'recovered','recovered';...
        'tests','tests1';...
        'positiveRate','';...
        'positiveRatePCR','';...
        'positiveRateAntigen','';...
        'countHardStatus','CountHardStatus';...
        'countMediumStatus','CountMediumStatus';...
        'countEasyStatus','CountEasyStatus';...
        'deaths','CountDeath';...
        'severeNew','serious_critical_new';...
        'mediumNew','medium_new';...
        'easyNew','easy_new';...
        'newHospitalized','new_hospitalized';...
        'countBreathCum','CountBreathCum';...
        'countBreath','CountBreath';...
        'countCriticalStatus','CountCriticalStatus';...
        'countEcmo','count_ecmo'};
% if ~isequal(list.Properties.VariableNames(2:end)',vars(:,1))
%     error('unexpected columns')
% end
if isequal(list{end,13:16}, list{end-1,13:16})
    warning('duplicate last day')
    list = list(1:end-1,:);
end
col = find(~cellfun(@isempty, vars(:,2)));
%%
figure('units','normalized','position',[0,0,1,1]);
for ii = 1:length(col)
    subplot(4,4,ii)
    y1 = eval(['listD.',vars{col(ii),2}]);
    plot(listD.date,y1+nanmedian(y1)*0.1)
    hold on
    plot(list.date,eval(['list.',vars{col(ii),1}]))
    title(['E: ',vars{col(ii),1},', Y: ',vars{col(ii),2}],'Interpreter','none')
    if ii == 1
        legend('Yuval + 0.1xmedian','Eran','location','northwest')
    end
end

for ii = 1:length(col)
    y1 = eval(['listD.',vars{col(ii),2}]);
    valuesY = y1 > 0;
    y2 = eval(['list.',vars{col(ii),1}]);
    valuesE = y2 > 0;
    if sum(valuesE) == sum(valuesY)
        if ~isequal(y1(valuesY),y2(valuesE))
            warning(['values not equal for ',vars{col(ii),2}])
            figure;
            plot(list.date(valuesE), eval(['list.',vars{col(ii),1},'(valuesE)']),'.r')
            hold on
            plot(listD.date(valuesY), eval(['listD.',vars{col(ii),2},'(valuesY)']),'ob')
            title(vars{col(ii),2})
            legend('Eran','Yuval')
        end
    else
        warning(['values for different dates for ',vars{col(ii),2}])
    end
end
%%
json = urlread('https://datadashboardapi.health.gov.il/api/queries/hospitalizationStatus');
json = jsondecode(json);
data = struct2table(json);
data.dayDate = datetime(strrep(data.dayDate,'T00:00:00.000Z',''));
if ~isequal(data.dayDate,unique(data.dayDate))
    [a,b,c] = unique(data.dayDate);
    warning('duplicate dates')
    disp(datestr(data.dayDate(~ismember(1:height(data),b))))
    data = data(b,:);
end
% vars1 = data.Properties.VariableNames(2:end)';
vars1 = {'countHospitalized','CountHospitalized';'countHospitalizedWithoutRelease','';'countHardStatus','CountHardStatus';'countMediumStatus','CountMediumStatus';'countEasyStatus','CountEasyStatus';'countBreath','CountBreath';'countDeath','CountDeath';'totalBeds','';'standardOccupancy','';'numVisits','';'patientsHome','';'patientsHotel','';'countBreathCum','CountBreathCum';'countDeathCum','';'countCriticalStatus','CountCriticalStatus';'countSeriousCriticalCum','CountSeriousCriticalCum';'seriousCriticalNew','serious_critical_new';'countEcmo','count_ecmo';'countDeadAvg7days','';'mediumNew','medium_new';'easyNew','easy_new'};
col = find(~cellfun(@isempty, vars1(:,2)));
data.countEcmo(cellfun(@isempty, data.countEcmo)) = {nan};
data.countEcmo = [data.countEcmo{:}]';
%%
figure('units','normalized','position',[0,0,1,1]);
for ii = 1:length(col)
    subplot(4,4,ii)
    y1 = eval(['listD.',vars1{col(ii),2}]);
    plot(listD.date,y1+nanmedian(y1)*0.1)
    hold on
    plot(data.dayDate,eval(['data.',vars1{col(ii),1}]))
    title(vars1{col(ii),1})
    if ii == 1
        legend('Yuval + 0.1xmedian','MOH','location','northwest')
    end
end

% figure;
% bar(data.dayDate,[data.countEasyStatus,data.countMediumStatus,data.countHardStatus],'stacked')
% hold on
% plot(data.dayDate,data.countHospitalized,'.k')
% legend('countEasyStatus','countMediumStatus','countHardStatus','countHospitalized')
% 
% figure;
% bar(data.dayDate,100*(data.countHospitalized ./ sum([data.countEasyStatus,data.countMediumStatus,data.countHardStatus],2)-1))

vars2 = {'countDeath','countEasyStatus','countMediumStatus','countHardStatus','newHospitalized','countHospitalized','countBreathCum','countCriticalStatus','countSeriousCriticalCum','seriousCriticalNew','mediumNew','easyNew','countEcmo'}';
vars2(:,2) = {'deaths','countEasyStatus','countMediumStatus','countHardStatus','newHospitalized','countHospitalized','countBreathCum','countCriticalStatus','countSeriousCriticalCum','severeNew','mediumNew','easyNew','countEcmo'}';
figure('units','normalized','position',[0,0,1,1]);
for ii = 1:length(vars2)
    try
%         disp(eval(['list.',vars2{ii,2}]))
        subplot(4,4,ii)
        y1 = eval(['list.',vars2{ii,2}]);
        plot(list.date,y1+nanmedian(y1)*0.1)
        hold on
        plot(data.dayDate,eval(['data.',vars2{ii,1}]))
        title(vars2{ii,1})
    end
    if ii == 1
        legend('Eran + 0.1xmedian','MOH','location','northwest')
    end
end
% va = ['countDeath','deaths';'countEasyStatus','countEasyStatus';'countMediumStatus','countMediumStatus';'countHardStatus','countHardStatus';'newHospitalized','new_hospitalized';'countHospitalized',' ';'countBreathCum','CountBreathCum';'countCriticalStatus','countCriticalStatus';'countSeriousCriticalCum','CountSeriousCriticalCum';'seriousCriticalNew','severe_new';'mediumNew','medium_new';'easyNew','easy_new';'countEcmo','countEcmo']
% moh = ['countDeath','countEasyStatus','countMediumStatus','countHardStatus','newHospitalized','countHospitalized','countBreathCum','countCriticalStatus','countSeriousCriticalCum','seriousCriticalNew','mediumNew','easyNew','countEcmo']
% eran = ['deaths','countEasyStatus','countMediumStatus','countHardStatus','new_hospitalized','countHospitalized','CountBreathCum','countCriticalStatus','CountSeriousCriticalCum','severe_new','medium_new','easy_new','countEcmo']

%%
figure;
subplot(2,2,1)
plot(data.dayDate, data.countHospitalized)
subplot(2,2,2)
plot(data.dayDate(2:end), movsum(diff(data.countBreathCum),[6 0]))
subplot(2,2,3)
plot(data.dayDate, data.countCriticalStatus)
subplot(2,2,4)
plot(data.dayDate, movsum(data.newHospitalized,[6 0]))

% figure,


% plot(list.date,list.countCriticalStatus,'linewidth',2);
% hold on;
% plot(listD.date,listD.CountCriticalStatus);
% legend('eran','yuval')
% 
% figure;
% plot(list.date,list.deaths,'linewidth',2);
% hold on;
% plot(listD.date,listD.CountDeath);
% legend('eran','yuval')