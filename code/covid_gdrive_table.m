% get https://docs.google.com/spreadsheets/d/1kiOrQxOtBg0__IoLkEZgqhMDpIQCXbBxEE78BwqcOs4/edit?usp=sharing
% !wget 'https://docs.google.com/uc?export=download&id=IoLkEZgqhMDpIQCXbBxEE78BwqcOs4&output=csv' -O ~/covid-19-israel-matlab/data/Israel/delta.csv --no-check-certificate 

!wget --no-check-certificate -O ~/covid-19-israel-matlab/data/Israel/delta.csv 'https://docs.google.com/spreadsheets/d/1kiOrQxOtBg0__IoLkEZgqhMDpIQCXbBxEE78BwqcOs4/export?gid=472501586&format=csv'
delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);

vacc30 = 1937000+2160000;
pop30 = 2317000+2462000;
vacc = 1000*(21+151+437+1020+1937+2160);
pop = 9500000;


ncba = readtable('~/covid-19-israel-matlab/data/Israel/severe_by_age.xlsx');
extra = 188-height(ncba)+height(delta);
if extra > 0
    warning off
    ncba.date(end+1:end+extra) = ncba.date(end)+(1:extra);
    warning on
    ncba{189:end,[2:4,6:8]} = delta{:,15:20};
    ncba{189:end,5} = sum(ncba{189:end,2:4},2);
    ncba{189:end,9} = sum(ncba{189:end,6:8},2);
    writetable(ncba,'~/covid-19-israel-matlab/data/Israel/severe_by_age.csv','Delimiter',',','WriteVariableNames',true);
end

cd ~/covid-19-israel-matlab/
%%
!git add ~/covid-19-israel-matlab/data/Israel/delta.csv
!git commit -m "gdrive to csv"
!git push

%% QA
row = find(delta.severeVacc60_ > delta.severe60_);
if ~isempty(row)
    error(['delta.severeVacc60_ > delta.severe60_ at row ',str(row)])
end
row = find(delta.severeVacc40_60 > delta.severe40_60);
if ~isempty(row)
    error(['delta.severeVacc40_60 > delta.severe40_60 at row ',str(row)])
end
row = find(delta.severe_40 > delta.severe_40);
if ~isempty(row)
    error(['delta.severeVacc_40 > delta.severe_40 at row ',str(row)])
end

row = find(delta.deathsVacc60_ > delta.deaths60_);
if ~isempty(row)
    error(['delta.deathsVacc60_ > delta.deaths60_ at row ',str(row)])
end
row = find(delta.deathsVacc40_60 > delta.deaths40_60);
if ~isempty(row)
    error(['delta.deathsVacc40_60 > delta.deaths40_60 at row ',str(row)])
end
row = find(delta.deaths_40 > delta.deaths_40);
if ~isempty(row)
    error(['delta.deathsVacc_40 > delta.deaths_40 at row ',str(row)])
end

row = (nansum(delta{:,6:8},2) - nansum(delta{:,15:17},2)) ~= 0;
if sum(row) > 0
    disp('severe vacc ~ age mismatch')
    disp(delta(row,[1,6:8,15:17]))
end

row = (delta.severeVacc - nansum(delta{:,18:20},2)) ~= 0;
if sum(row) > 0
    disp('severe vacc mismatch')
    disp(delta(row,[1,8,18:20]))
end

% deaths
row = find(delta.deathsVacc60_ > delta.deaths60_);
if ~isempty(row)
    error(['delta.deathsVacc60_ > delta.deaths60_ at row ',str(row)])
end
row = find(delta.deathsVacc40_60 > delta.deaths40_60);
if ~isempty(row)
    error(['delta.deathsVacc40_60 > delta.deaths40_60 at row ',str(row)])
end
row = find(delta.deaths_40 > delta.deaths_40);
if ~isempty(row)
    error(['delta.deathsVacc_40 > delta.deaths_40 at row ',str(row)])
end

row = find(delta.deathsVacc60_ > delta.deaths60_);
if ~isempty(row)
    error(['delta.deathsVacc60_ > delta.deaths60_ at row ',str(row)])
end
row = find(delta.deathsVacc40_60 > delta.deaths40_60);
if ~isempty(row)
    error(['delta.deathsVacc40_60 > delta.deaths40_60 at row ',str(row)])
end
row = find(delta.deaths_40 > delta.deaths_40);
if ~isempty(row)
    error(['delta.deathsVacc_40 > delta.deaths_40 at row ',str(row)])
end

row = (nansum(delta{:,9:11},2) - nansum(delta{:,21:23},2)) ~= 0;
row(1:2) = false;
if sum(row) > 0
    disp('deaths vacc ~ age mismatch')
    disp(delta(row,[1,9:11,21:23]))
end

row = (delta.deathsVacc - nansum(delta{:,24:26},2)) ~= 0;
row(1:2) = false;
if sum(row) > 0
    disp('deaths vacc mismatch')
    disp(delta(row,[1,11,24:26]))
end

listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
iComm = listD.date(ismember(listD.date,delta.date));
iComm(1:2) = [];
iDash = ismember(listD.date,iComm);
iDel = ismember(delta.date,iComm);
deathDiff = sum(listD.CountDeath(iDash)) - nansum(delta.deaths_40(iDel)+delta.deaths40_60(iDel)+delta.deaths60_(iDel));

figure;
plot(iComm,[listD.CountDeath(iDash),delta.deaths_40(iDel)+delta.deaths40_60(iDel)+delta.deaths60_(iDel)])
legend('dashboard','tamatz')
title('deaths')

figure;
plot(iComm,[[0;diff(listD.CountBreathCum(iDash))],delta.vent_40(iDel)+delta.vent40_60(iDel)+delta.vent60_(iDel)])
legend('dashboard','tamatz')
title('vent')

figure;
h = plot(iComm,[listD.serious_critical_new(iDash),...
    delta.severe_40(iDel)+delta.severe40_60(iDel)+delta.severe60_(iDel),...
    [0;diff(listD.CountSeriousCriticalCum(iDash))]]);
legend(h([1,3,2]),'dashboard ser crit new','dashboard SerCritCum','tamatz')
title('severe')
