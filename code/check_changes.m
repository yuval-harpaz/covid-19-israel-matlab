
cd covid-19-israel-matlab/
% [~,msg] = system('git log --oneline > tmp.log')
!git log --pretty=tformat:"%H" --shortstat > tmp.log
log = importdata('tmp.log');
log = log(1:2:100);
for ii = 1:length(log)
    [~,msg] = system(['wget -O tmp.csv https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/',...
        log{ii},'/data/Israel/dashboard_timeseries.csv']);
    t = readtable('tmp.csv');
    t.CountHardStatus(isnan(t.CountHardStatus)) = 0;
    t = 
     if ii == 1
        date = t.date;
        hardMax = t.CountHardStatus;
        hardMin = t.CountHardStatus;
     else
        [~,iExist] = ismember(t.date,date);
%          iDif = hardMax(iExist)>t.CountHardStatus
         hardMax(iExist) = max([hardMax(iExist),t.CountHardStatus],[],2);
         hardMin(iExist) = min([hardMin(iExist),t.CountHardStatus],[],2);
     end
end
     
        
