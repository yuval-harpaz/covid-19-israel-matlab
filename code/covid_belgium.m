function [bel,pop,date] = covid_belgium 
cd ~/covid-19-israel-matlab
[~,~] = system ('wget -O tmp.csv https://epistat.sciensano.be/Data/COVID19BE_MORT.csv');
region = readtable('tmp.csv');
!rm tmp.csv
dateAll = datetime(region.DATE);
date = unique(dateAll);
date = (date(1):date(end))';
reg = {'Brussels';'Flanders';'Wallonia'};
pop = table(reg);
pop.pop = [1.2;11.5-3.6-1.2;3.6];
bel = zeros(length(date),3);
for ii = 1:length(date)
    for iReg = 1:3
        bel(ii,iReg) = sum(region.DEATHS(dateAll == date(ii) & ismember(region.REGION,pop.reg{iReg})));
    end
end


