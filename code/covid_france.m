function [fra,pop,date] = covid_france 
cd ~/covid-19-israel-matlab
[~,~] = system ('wget -O tmp.csv https://raw.githubusercontent.com/opencovid19-fr/data/master/dist/chiffres-cles.csv');
region = readtable('tmp.csv');
!rm tmp.csv
dateAll = region.date;
date = unique(dateAll);
date = (date(1):date(end))';
reg = unique(region.maille_nom(contains(region.maille_code,'REG-')));
pop = table(reg);
pop.pop = [8032377;2783039;3340379;2559073;344679;5511747;0;0;5962662;0;0;0;3303500;5999982;5924858;3801797;5055651;12278210];
reg(end+1) = {'France'};
fra = zeros(length(date),length(reg));
for ii = 1:length(date)
    for iReg = 1:length(reg)
        idx = dateAll == date(ii) & ismember(region.maille_nom,reg{iReg});
        if sum(idx) > 0
            fra(ii,iReg) = sum(region.deces(idx));
        end
    end
end


