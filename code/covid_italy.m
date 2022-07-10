function [ita,popreg,date] = covid_italy 
cd ~/covid-19-israel-matlab
[~,~] = system ('wget https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv');
region = readtable('dpc-covid19-ita-regioni.csv');
!rm 'dpc-covid19-ita-'*

dateReg = datetime(cellfun(@(x) x(1:10),region.x_data,'UniformOutput',false));
Date = unique(dateReg); %#ok<NASGU>
regName = strrep(strrep(unique(region.denominazione_regione),'P.A. ',''),' ','_');
regName = strrep(regName,'-','_');
regName = strrep(regName,'''','');
nameStr = join(regName,',');

popreg = readtable('data/Italy/Italy_population_by_region.csv'); 

for iName = 1:length(regName)
     eval([regName{iName},' = region.deceduti(ismember(region.denominazione_regione,popreg.region{iName}));']);
end
eval(['ita = table(Date,',nameStr{1},');']);
date = ita.Date; %#ok<NODEF>
ita.Date = [];
% writetable(ita,'data/Italy/deceased.csv','delimiter',',','WriteVariableNames',true);
