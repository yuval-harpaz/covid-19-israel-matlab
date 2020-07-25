cd /media/innereye/1T/Repos/covid-19-israel-matlab/data/Israel
%pop = 9097000;
listD = readtable('dashboard_timeseries.csv');
listD.CountDeath(isnan(listD.CountDeath)) = 0;
listD.new_hospitalized(isnan(listD.new_hospitalized)) = 0;
endTrain = find(ismember(listD.date,datetime([2020,6,30])));
deaths = listD.CountDeath;
deathSmooth = movmean(deaths,[3 3]);
positiveTests = listD.tests_positive./listD.tests_result*100;
positiveTests(106:113) = 0.7; % ignore Gymnasia spike
positiveTestSmooth = movmean(positiveTests,[3 3]);
% endTrain = length(deathSmooth)-14;
bP = [ones(endTrain-15,1),positiveTestSmooth(1:endTrain-15)]\deathSmooth(16:endTrain);
predPositive = movmean([zeros(15,1);[ones(length(positiveTests),1),positiveTests]*bP],[3 3]);
predPositive(1:37) = 0;

newHosp = listD.new_hospitalized;
newHospSmooth = movmean(newHosp,[3 3]);
[xc,lag] = xcorr(deathSmooth(1:endTrain),newHospSmooth(1:endTrain));
%figure;
%plot(lag,xc)
[~,iMax] = max(xc);
lagH = lag(iMax);
bH = [ones(endTrain-lagH+1,1),movmean(newHospSmooth(1:endTrain-lagH+1),[3 3])]\deathSmooth(lagH:endTrain);
predHosp = movmean([zeros(lagH-1,1);[ones(length(positiveTests),1),newHospSmooth]*bH],[3 3]);
predHosp(1:37) = 0;
%% plot
dP = [listD.date;(listD.date(end)+1:listD.date(end)+15)'];
dH = [listD.date;(listD.date(end)+1:listD.date(end)+lagH-1)'];
figure('units','normalized','position',[0,0.25,1,0.5]);
subplot(1,3,1)
plot(listD.date,positiveTestSmooth/prctile(positiveTestSmooth,95),'k')
hold on
plot(listD.date,newHospSmooth/prctile(newHospSmooth,95),'b')
plot(listD.date,deathSmooth/prctile(deathSmooth,95),'r')
legend('Positive tests','New hospitalized','Daily deaths (smoothed)','location','northwest')
ylabel('normalized units')
box off
grid on
title('Two predictors for death rate')
subplot(1,3,2)
plot(dP,predPositive,'k--')
hold on
plot(dH,predHosp,'b--')
plot(listD.date,deaths,'r')
title('Daily deaths per million')
legend('predicted by tests','predicted by hospitalizations','daily deaths','location','northwest')
ylim([0 13])
box off
grid on
ylabel('deaths')
subplot(1,3,3)
plot(dP,cumsum(predPositive),'k--')
hold on
plot(dH,cumsum(predHosp),'b--')
plot(listD.date,cumsum(deaths),'r')
title('Cumulative deaths per million')
legend('predicted by tests','predicted by hospitalizations','total deaths','location','northwest')
box off
grid on
ylabel('deaths')

%% old
% listDaily = readtable('daily.csv');
% x = listDaily.positive;
% x(89:96) = 0.75;
% y = movmean(listDaily.critical,[3,3]);
% fac = x(1:80)\y(12:91);
% yy = [zeros(11,1);fac*x(1:end-11)];
% figure;
% plot(listDaily.date,listDaily.positive,'b')
% hold on
% plot(listDaily.date,listDaily.critical,'r')
% plot(listDaily.date,yy,'k--')
% 
% 
% y = movmean(listDaily.hospitalized,[3,3]);
% train = [51:87,95:112];
% 
% fac = x(train)\y(3+train);
% yy = [zeros(3,1);fac*movmean(x(1:end-3),[3 3])];
% figure;
% plot(listDaily.date,listDaily.positive,'b')
% hold on
% plot(listDaily.date,listDaily.hospitalized,'r')
% plot(listDaily.date,yy,'k--')
% legend('positive tests (%)','new hospitalized patients','predicted new hospitalized, as 13*positive tests 3 days before')
