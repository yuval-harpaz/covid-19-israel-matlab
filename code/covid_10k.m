per = readtable('~/Downloads/-1550216003254707372infected_per10k.xlsx');
vars = per.Properties.VariableNames(2:end);
for iVar = 1:3
    vals{iVar,1} = unique(per{:,iVar+1});
    vals{iVar,1} = 
end
per.infected_per10K = strrep(per.infected_per10K,'inf','5656');
infected = cellfun(@str2num, per.infected_per10K);
date = unique(per.tick);
for iSec = 1:3
    for iAge = 1:5
        