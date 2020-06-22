function [y,pop,date] = covid_uk(plt)
if nargin == 0
    plt = false;
end
% cd covid-19-israel-matlab/
% https://data.london.gov.uk/dataset/coronavirus--covid-19--deaths
lon = readtable('data/London.csv');
y = lon.Cum;
date = lon.Date;
% 
% nhs = urlread('https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-daily-deaths/');
% iLink = strfind(nhs,'.xlsx">COVID 19 total announced deaths');
% iLink = iLink(1);
% iHttp = strfind(nhs,'https://');
% iHttp = iHttp(find(iHttp < iLink,1,'last'));
% xlsx = nhs(iHttp:iLink+4);
% !rm tmp.*
% system(['wget -O tmp.xlsx ',xlsx])
% lon = xlsread('tmp.xlsx','Tab1 Deaths by region');
% y = cumsum(lon(5,2:size(lon,2)-4)'); % hospitals only?
% % https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/numberofdeathsincarehomesnotifiedtothecarequalitycommissionengland/2020
% date = datetime(datestr(lon(1,2:size(lon,2)-4)'+datenum('30-Dec-1899')));
pop = table({'London'},8982000);

if plt
    plot(date,y/pop.Var2(1)*10^6);
end