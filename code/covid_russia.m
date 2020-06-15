function [y,pop,date] = covid_russia(plt)
if nargin == 0
    plt = false;
end
% only got 3 regions, too many non-latin script
cd ~/covid-19_data_analysis
[~,~] = system ('wget https://raw.githubusercontent.com/jeetiss/covid19-russia/master/docs/timeseries.json');

fid = fopen('timeseries.json','r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt);
txt = strrep(txt','Москва','Moscow');
txt = strrep(txt,'Московская область','Moscow_region');
txt = strrep(txt,'Санкт-Петербург','Saint_Petersburg');
region = jsondecode(txt);
!rm 'timeseries.json'

pop = table({'Moscow';'Moscow_region';'Saint_Petersburg'},[12537954;7095000;5467808]);
date = datetime(reshape([region.Moscow(:).date]',10,length(region.Moscow(:)))');
for ii = 1:length(date)
    y(ii,1) = str2num(region.Moscow(ii).deaths);
    y(ii,2) = str2num(region.Moscow_region(ii).deaths);
    y(ii,3) = str2num(region.Saint_Petersburg(ii).deaths);
end
if plt
    figure;
    plot(date,y./pop{:,2}'*10^6);
    legend(strrep(pop{:,1},'_',' '))
end