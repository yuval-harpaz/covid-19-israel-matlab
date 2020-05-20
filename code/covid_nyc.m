function [date,pop,deceased,deceased_probable] = covid_nyc
% nyc = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/Deaths/probable-confirmed-dod.csv');
nyc = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/deaths/probable-confirmed-dod.csv');
nyc = strrep(nyc,'/20,','/2020,');
fid = fopen('tmp.csv','w');
fwrite(fid,nyc);
fclose(fid);
nyc = readtable('tmp.csv');
!rm tmp.csv
nyc.PROBABLE_COUNT(isnan(nyc.PROBABLE_COUNT)) = 0;
nyc.CONFIRMED_COUNT(isnan(nyc.CONFIRMED_COUNT)) = 0;
date = nyc.date_of_death;
pop = 8399000;
deceased = cumsum(nyc.CONFIRMED_COUNT);
deceased_probable = deceased + cumsum(nyc.PROBABLE_COUNT);

