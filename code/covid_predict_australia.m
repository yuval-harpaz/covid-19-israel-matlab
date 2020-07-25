cd /media/innereye/1T/Repos/covid-19-israel-matlab/data/
%pop = 9097000;

[~,~] = system('wget -O tmp.csv https://raw.githubusercontent.com/pappubahry/AU_COVID19/master/time_series_deaths.csv');
tD = readtable('tmp.csv');
date = tD.Date;
deaths = [0;diff(tD.Total)];
% endTrain = find(ismember(listD.date,datetime([2020,6,30])));
% deaths = listD.CountDeath;
[~,~] = system('wget -O tmp.csv https://raw.githubusercontent.com/pappubahry/AU_COVID19/master/time_series_cases.csv');
tC = readtable('tmp.csv');
new_cases = [0;diff(tC.Total)];
[~,~] = system('wget -O tmp.csv https://raw.githubusercontent.com/pappubahry/AU_COVID19/master/time_series_tests.csv');
tT = readtable('tmp.csv');
tests = nansum(tT{:,2:9},2);
i1 = 50;  % find(~isnan(tests),1);
tests = tests(i1-1:end);
tests = diff(tests);
iNeg = find(tests < 0);
for jNeg = 1:length(iNeg)
    idx = find(tests' > 0 & 1:length(tests) < iNeg(jNeg),1,'last'):...
        find(tests' > 0 & 1:length(tests) > iNeg(jNeg),1);
    tests(idx) = round(linspace(tests(idx(1)),tests(idx(end)),length(idx)));
end
% tests = tests(ismember(tT.Date,date));

i2 = find(ismember(date,tT.Date(i1)));
new_cases = new_cases(i2:end);
deaths = deaths(i2:end);
date = date(i2:end);
figure;
plot(new_cases./tests*100)


deathSmooth = movmean(deaths,[3 3]);
% positiveTests = listD.tests_positive./listD.tests_result*100;
% positiveTests(106:113) = 0.7; % ignore Gymnasia spike
positiveTestSmooth = movmean(new_cases./tests*100,[3 3]);
endTrain = length(deathSmooth)-14;
bP = [ones(endTrain-15,1),positiveTestSmooth(1:endTrain-15)]\deathSmooth(16:endTrain);
predPositive = [zeros(15,1);[ones(length(positiveTestSmooth),1),positiveTestSmooth]*bP];

% newHosp = listD.new_hospitalized;
% newHospSmooth = movmean(newHosp,[3 3]);
% [xc,lag] = xcorr(deathSmooth(1:endTrain),newHospSmooth(1:endTrain));
%figure;
%plot(lag,xc)
% [~,iMax] = max(xc);
% lagH = lag(iMax);
% bH = [ones(endTrain-lagH+1,1),movmean(newHospSmooth(1:endTrain-lagH+1),[3 3])]\deathSmooth(lagH:endTrain);
% predHosp = movmean([zeros(lagH-1,1);[ones(length(positiveTests),1),newHospSmooth]*bH],[3 3]);
% predHosp(1:37) = 0;
%% plot
dP = [date;(date(end)+1:date(end)+15)'];
% dH = [listD.date;(listD.date(end)+1:listD.date(end)+lagH-1)'];
% figure('units','normalized','position',[0,0.25,1,0.5]);
% subplot(1,3,1)
figure;
plot(date,positiveTestSmooth/prctile(positiveTestSmooth,95),'k')
hold on
% plot(listD.date,newHospSmooth/prctile(newHospSmooth,95),'b')
plot(date,deathSmooth/prctile(deathSmooth,95),'r')
legend('Positive tests','New hospitalized','Daily deaths (smoothed)','location','northwest')
ylabel('normalized units')
box off
grid on
title('Two predictors for death rate')
%% 
figure;
plot(dP,predPositive,'k--')
hold on
% plot(dH,predHosp,'b--')
plot(date,deaths,'r')
title('Daily deaths')
legend('predicted by new cases/tests','daily deaths','location','northwest')
ylim([0 10])
box off
grid on
ylabel('deaths')
