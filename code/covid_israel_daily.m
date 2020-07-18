function covid_israel_daily(plt)
if nargin == 0
    plt = true;
end
cd ~/covid-19-israel-matlab/data/Israel
listDash = readtable('dashboard_timeseries.csv');
listDaily = readtable('daily.csv');
% listT = readtable('Israel_ministry_of_health.csv');
[err,op] = system(['wget -O tmp.pdf https://www.gov.il/BlobFolder/reports/daily-report-20200717/he/daily-report_daily-report-',...
    datestr(datetime('today'),'yyyymmdd'),'.pdf']);
if err
    [err,op] = system(['wget -O tmp.pdf https://www.gov.il/BlobFolder/reports/daily-report-20200717/he/daily-report_daily-report-',...
    datestr(datetime('yesterday'),'yyyymmdd'),'.pdf']);
end
if err
    error(op)
end
javaaddpath(which('/iText-4.2.0-com.itextpdf.jar'));
% pdf = pdfRead('tmp.pdf');
% strfind(pdf{2},'במצב קשה')
ip = input('fix manually new_critical.csv from tmp.pdf, y when done ','s');
if strcmp(ip,'y')
    listH = readtable('new_critical.csv');
    % fix existing data
    updated = listH.new_critical(ismember(listH.date,listDaily.date));
    iEq = find(updated == listDaily.critical,1,'last');
    if iEq == height(listDaily)
        disp('up to date')
    else
        date = listH.date(iEq+1:end);
        iNew = height(listDaily)+1:height(listDaily)+length(date);
        warning off
        listDaily.date(iNew) = date;
        warning on
        listDaily.critical(iNew) = listH.new_critical(ismember(listH.date,date));
        listDaily.hospitalized(iNew) = listDash.new_hospitalized(ismember(dateshift(listDash.date','start','day'),date));
        listDaily.deceased(iNew) = listDash.CountDeath(ismember(dateshift(listDash.date,'start','day'),date));
        listDaily.positive(iNew) = listDash.tests_positive(ismember(dateshift(listDash.date,'start','day'),date))./...
            listDash.tests_result(ismember(dateshift(listDash.date,'start','day'),date))*100;
        hospitalizedTot = listDash.Counthospitalized(ismember(dateshift(listDash.date,'start','day'),[date(1)-1;date]));
        criticalTot = listDash.CountHardStatus(ismember(dateshift(listDash.date,'start','day'),[date(1)-1;date]));
        listDaily.previously_critical(iNew) = [criticalTot(1:end-1)-criticalTot(2:end)+listDaily.critical(iNew)-listDaily.deceased(iNew)];
        listDaily.discharged(iNew) = [hospitalizedTot(1:end-1)-hospitalizedTot(2:end)+listDaily.hospitalized(iNew)-listDaily.deceased(iNew)];
    end
    writetable(listDaily,'daily.csv','WriteVariableNames',true,'Delimiter',',')
end

if plt
    desiredDates = fliplr(listDaily.date(end):-7:listDaily.date(1));
    figure;
    plot(listDaily.date,movmean(listDaily{:,2:end},[3 3]));
    legend({'positive (%)','new hospitalized','new critical','new deceased','1st day not critical','new discharged'},'location','north')
    box off
    grid
    set(gca,'xtick',desiredDates,'ytick',0:10:110)
    xtickangle(90)
end