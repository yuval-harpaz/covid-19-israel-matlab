function [y,pop,date] = covid_uk(plt)
if nargin == 0
    plt = true;
end

%%
% !wget -O tmp.csv https://api.coronavirus.data.gov.uk/v2/data?areaType=overview&metric=newAdmissions&format=csv
% !google-chrome --new-window https://api.coronavirus.data.gov.uk/v2/data?areaType=overview&metric=newAdmissions&format=csv
% 
% !google-chrome --new-window https://api.coronavirus.data.gov.uk/v2/data?areaType=overview&metric=newAntibodyTestsByPublishDate&metric=newCasesByPublishDate&metric=newOnsDeathsByRegistrationDate&metric=newCasesBySpecimenDate&format=csv
% t = readtable('tmp.csv')
%% age data
% https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/conditionsanddiseases/bulletins/coronaviruscovid19infectionsurveypilot/latest
% https://www.ons.gov.uk/visualisations/dvc1456/age/datadownload.xlsx
% look for  "Equivalent downloads for age demographic of cases"  in https://coronavirus.data.gov.uk/details/download 
%%



cd ~/covid-19-israel-matlab/
% https://data.london.gov.uk/dataset/coronavirus--covid-19--deaths

txt = urlread('https://data.london.gov.uk/dataset/coronavirus--covid-19--deaths');
iStart = strfind(txt,'06 Mar');
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
date = [cellfun(@(x) datetime([x(1:2),'-',x(3:5),'-','2020']),extracted(1:43,1));...
    cellfun(@(x) datetime([x(1:2),'-',x(3:5),'-','2021']),extracted(44:end,1))];

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
iPos = strfind(txt,'Positive test');
% iPos = iPos(1:2);
iRest = strfind(txt,'Rest of');
% txt(iPos(1):iPos(2))
extracted1 = regexprep(txt(iPos(3)+19:iRest(3)-1),'<.*?>','');
weekDeathHosp = str2num(strrep(extracted1,',',''));
mon = {'January','February','March','April','May','June','July','August','September','October','November','December'};
idx = [];
for ii = 1:12 
    idx = [idx,strfind(txt,mon{ii})];
end
idx = sort(idx);
idx = idx(find(idx < iPos(3),1,'last'));
ism = strfind(txt,'<');
dateStr = txt(idx-3:ism(find(ism > idx,1))-2);
[~,mm] = ismember(dateStr(4:end),mon);
dd = str2num(dateStr(1:2));
weekDeathDate = datetime(2021,mm,dd-42:7:dd);

%% cases
txt1 = urlread('https://data.london.gov.uk/dataset/coronavirus--covid-19--cases');
iCsv = findstr(txt1,'phe_cases_london_boroughs.csv');
iDownload = strfind(txt1,'download/');
sf = [];
cPrev = 0;
for ic = 1:length(iCsv)
    c = find(iCsv(ic) > iDownload,1,'last');
    if c > cPrev
        sf = [sf;iDownload(c),iCsv(ic)];
    end
    cPrev = c;
end
    
    
iii = 1;
link = ['https://data.london.gov.uk/',txt1(sf(iii,1):sf(iii,2)+28)];
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
    ylabel('cases per day')
    ylim([0 16000])
    yyaxis left
    bar(date(2:end),diff(y));
    hold on
    bar(weekDeathDate,weekDeathHosp,'c')
    grid on
    ylabel('deaths per week')
    legend('deaths per week','deaths per week, hospitals only','cases per day','location','north')
    set(gcf,'Color','w')
    title('London')
    box off
    xlim([datetime(2020,3,15) datetime('tomorrow')+3])
    xtickformat('MMM')
end

