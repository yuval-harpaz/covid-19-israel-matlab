function covid_abroadPP

options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/positiveArrivingAboardDaily';
paad = webread(url, options);
paad = struct2table(paad);
paad = paad(~ismember(paad.visited_country,'כלל המדינות'),:);
date = datetime(paad.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
dateU = unique(date);
country = unique(paad.visited_country);

ie = cellfun(@isempty,paad.sum_positive);
paad.sum_positive(ie) = {0};
abroad = cellfun(@(x) x,paad.sum_positive);
for ic = 1:length(country)
    for id = 1:length(dateU)
        idx = ismember(paad.visited_country,country{ic}) & date == dateU(id);
        if sum(idx) == 0
            pos(id,ic) = 0;
        elseif sum(idx) == 1
            perc(id,ic) = paad{idx,5}+paad{idx,6};
            pos(id,ic) = paad{idx,3}+paad{idx,4};
%             if pos(id,ic) > 0
%                 disp(paad(idx,3:end));
%             end
        else
            error('two?')
        end
    end
end
        

mask = pos < 4;
yy = perc;
yy(mask) = nan;
include = any(pos > 10) & any(yy > 4); sum(include)
figure
plot(dateU,yy(:,include),'.')
legend(country(include))
        


aad = struct2table(webread('https://datadashboardapi.health.gov.il/api/queries/arrivingAboardDaily'));
aad = aad(ismember(aad.visited_country,'כלל המדינות'),:);
aadDate = datetime(aad.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

abroad1 = readtable('~/covid-19-israel-matlab/data/Israel/infected_abroad.xlsx');

aac = struct2table(webread('https://datadashboardapi.health.gov.il/api/queries/arrivingAboardCountry'));
% aac = aac(ismember(aac.visited_country,'כלל המדינות'),:);
% aacDate = datetime(aac.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

figure;plot(dateA,abroad);
hold on;
% plot(aadDate,aad.sum_arrival);
plot(abroad1.date,abroad1.incoming);
legend('positiveArrivingAboardDaily','tamatz')
