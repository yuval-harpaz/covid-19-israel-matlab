function [y,pop,date] = covid_uk(plt)
if nargin == 0
    plt = false;
end


cd ~/covid-19-israel-matlab/
% https://data.london.gov.uk/dataset/coronavirus--covid-19--deaths

txt = urlread('https://data.london.gov.uk/dataset/coronavirus--covid-19--deaths');
iStart = strfind(txt,'06 March');
iStart = iStart(1);
iEnd = strfind(txt,'Total');
iEnd = iEnd(1)-1;
extracted = regexprep(txt(iStart:iEnd),'<.*?>','');
ws = isspace(extracted);
nl = ismember(extracted,newline);
nl = [false,diff(nl) == 1];
ws(nl) = false;
extracted(ws) = [];
extracted = regexp(extracted,newline,'split');
extracted = extracted(1:end-1);
extracted = reshape(extracted,9,length(extracted)/9)';
date = cellfun(@(x) datetime([x(1:2),'-',x(3:5),'-','2020']),extracted(:,1));
hospital = cellfun(@str2double, extracted(:,2));
care_home = cellfun(@str2double, extracted(:,4));
home = cellfun(@str2double, extracted(:,6));
other = cellfun(@str2double, extracted(:,8));
Cum = cumsum(hospital+care_home+home+other);
lon = table(date,hospital,care_home,home,other,Cum);
writetable(lon,'data/London.csv');

%     writetable(lon,'data/LondonCases.csv');

% lon = readtable('data/London.csv');
y = lon.Cum;
pop = table({'London'},8982000);

%% cases
txt = urlread('https://data.london.gov.uk/dataset/coronavirus--covid-19--cases');
iCsv = findstr(txt,'phe_cases_london_boroughs.csv');
iDownload = strfind(txt,'download/');
link = ['https://data.london.gov.uk/',txt(iDownload(1):iCsv(1)+28)];
[~,~] = system(['wget -O tmp.csv ',link])
lonC = readtable('tmp.csv');
date2 = unique(lonC.date);
for ii = 1:length(date2)
    yy(ii,1) = sum(lonC.new_cases(ismember(lonC.date,date2(ii))));
end
if plt
    figure;
    yyaxis right
    plot(date2(1:end-2),yy(1:end-2))
    ylabel('מאומתים ליום')
    ylim([0 16000])
    yyaxis left
    bar(date(2:end),diff(y));
    grid on
    ylabel('נפטרים לשבוע')
end
legend('נפטרים לשבוע','מאומתים ליום')
set(gcf,'Color','w')
title('לונדון')
box off
