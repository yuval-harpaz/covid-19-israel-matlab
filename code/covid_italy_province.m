function [ita,popreg,date] = covid_italy_province 
cd ~/covid-19-israel-matlab
[~,~] = system ('wget -O tmp.csv https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-province/dpc-covid19-ita-province.csv');
region = readtable('tmp.csv');
!rm tmp*
region.denominazione_provincia(contains(region.denominazione_provincia,'/')) = ...
    cellfun(@(x) x(1:strfind(x,'/')-1),region.denominazione_provincia(contains(region.denominazione_provincia,'/')),'UniformOutput',false);
region.denominazione_provincia = strrep(region.denominazione_provincia,'-','_');
region.denominazione_provincia = strrep(region.denominazione_provincia,' ','_');
region.denominazione_provincia = strrep(region.denominazione_provincia,'''','');
region.denominazione_provincia = strrep(region.denominazione_provincia,'ì','i');

dateReg = datetime(cellfun(@(x) x(1:10),region.data,'UniformOutput',false));
Date = unique(dateReg); %#ok<NASGU>
provName = unique(region.denominazione_provincia);
% provName(contains(provName,'/')) = cellfun(@(x) x(1:strfind(x,'/')-1),provName(contains(provName,'/')),'UniformOutput',false);
% provName = strrep(provName,'-','_');
% provName = strrep(provName,' ','_');
% provName = strrep(provName,'''','');
% provName = strrep(provName,'ì','i');
provName(contains(provName,{'Fuori','In_fase_di'})) = [];
nameStr = join(provName,',');

popreg = readtable('data/Italy/Italy_population_by_province2019.csv'); 

for iName = 1:length(provName)
     eval([provName{iName},' = region.totale_casi(ismember(region.denominazione_provincia,popreg.Province{iName}));']);
end
eval(['ita = table(Date,',nameStr{1},');']);
date = ita.Date; %#ok<NODEF>
ita.Date = [];
% writetable(ita,'data/Italy/deceased.csv','delimiter',',','WriteVariableNames',true);
