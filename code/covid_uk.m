function [y,pop,date] = covid_uk(plt,deaths)
if nargin == 0
    plt = false;
end
if ~exist('deaths','var')
    deaths = true;
end

cd ~/covid-19-israel-matlab/
% https://data.london.gov.uk/dataset/coronavirus--covid-19--deaths
if deaths
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
    if deaths
        writetable(lon,'data/London.csv');
    else
        writetable(lon,'data/LondonCases.csv');
    end
    % lon = readtable('data/London.csv');
    y = lon.Cum;
    pop = table({'London'},8982000);
    if plt
        figure;
        bar(date(2:end),diff(y));
    end
else
    txt = urlread('https://data.london.gov.uk/dataset/coronavirus--covid-19--cases');
    iStart = strfind(txt,'01 March');
    [~,~] = system('wget -O tmp.csv https://data.london.gov.uk/download/coronavirus--covid-19--cases/151e497c-a16e-414e-9e03-9e428f555ae9/phe_cases_london_boroughs.csv')
    lonC = readtable('tmp.csv');
    date = unique(lonC.date);
    for ii = 1:length(date)
        y(ii,1) = sum(lonC.new_cases(ismember(lonC.date,date(ii))));
    end
    
    error('cases dont work same way')
end
