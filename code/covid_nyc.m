function nyc = covid_nyc
% https://www1.nyc.gov/site/doh/covid/covid-19-data.page

nyc = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/Deaths/probable-confirmed-dod.csv');
strrep(nyc,'\n\n','\n')
nyc = strrep(nyc,'/20,','/2020,');
fid = fopen('tmp.csv','w');
fwrite(fid,nyc);
fclose(fid);
nyc = readtable('tmp.csv');
!rm tmp.csv
% cum = nan;
% for ic = 2:height(nyc)
%     cum(ic,1) = nansum(nyc.CONFIRMED_COUNT(1:ic));
% end
% figure;
% plot(nyc.date_of_death,cum./8.4)