cd ~/covid-19-israel-matlab/data/Israel
listD = readtable('dashboard_timeseries.csv');
listH = readtable('new_critical.csv');
listT = readtable('Israel_ministry_of_health.csv');
date = listH.date;
critical = listH.new_critical;
hospitalized = listD.new_hospitalized(ismember(dateshift(listD.date','start','day'),date));
deceased = listD.CountDeath(ismember(dateshift(listD.date,'start','day'),date));
deceased(1) = 0;
hospitalized(1) = 0;
positive = listD.tests_positive(ismember(dateshift(listD.date,'start','day'),date))./...
    listD.tests_result(ismember(dateshift(listD.date,'start','day'),date))*100;
hospitalizedTot = listD.Counthospitalized(ismember(dateshift(listD.date,'start','day'),date));
hospitalizedTot(1) = 0;
criticalTot = listD.CountHardStatus(ismember(dateshift(listD.date,'start','day'),date));
criticalTot(1) = 0;
previously_critical = [0;criticalTot(1:end-1)-criticalTot(2:end)+critical(2:end)-deceased(2:end)];
discharged = [0;hospitalizedTot(1:end-1)-hospitalizedTot(2:end)+hospitalized(2:end)-deceased(2:end)];
list = table(date,positive,hospitalized,critical,deceased,previously_critical,discharged);
list.discharged(list.discharged <= 0) = 0;
list.previously_critical(list.previously_critical <= 0) = 0;
desiredDates = fliplr(list.date(end):-7:list.date(1));
figure;
plot(list.date,movmean(list{:,2:end},[3 3]));
legend({'positive (%)','new hospitalized','new critical','new deceased','1st day not critical','new discharged'},'location','north')
box off
grid 
set(gca,'xtick',desiredDates,'ytick',0:10:110)
xtickangle(90)
