function covid_us_google(states)
if nargin == 0
    states = {'North_Dakota'};
end
cd ~/covid-19-israel-matlab/data/
[~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
unzip('tmp.zip','tmp')
!rm tmp.zip
cd tmp
t = readtable('2020_US_Region_Mobility_Report.csv');
t.sub_region_1(cellfun(@isempty ,t.sub_region_1)) = {'USA'};
state = unique(t.sub_region_1);
for ii = 1:length(state)
    row = ismember(t.sub_region_1,state{ii}) & cellfun(@isempty ,t.sub_region_2);
     mob = t{row,9:end};
     mob = movmean(movmedian(mob,[3 3]),[3 3]);
     %     mob = mob./(-min(mob));
     mob = mean(mob(:,[1,4,5]),2);
     glob(1:length(mob),ii) = mob;
end