cd /media/innereye/1T/Repos/covid-19-israel-matlab/data/Israel
pop = 9097000;
listDaily = readtable('daily.csv');
x = listDaily.positive;
x(89:96) = 0.75;
y = movmean(listDaily.critical,[3,3]);
fac = x(1:80)\y(12:91);
yy = [zeros(11,1);fac*x(1:end-11)];
figure;
plot(listDaily.date,listDaily.positive,'b')
hold on
plot(listDaily.date,listDaily.critical,'r')
plot(listDaily.date,yy,'k--')


y = movmean(listDaily.hospitalized,[3,3]);
train = [51:87,95:112];

fac = x(train)\y(3+train);
yy = [zeros(3,1);fac*movmean(x(1:end-3),[3 3])];
figure;
plot(listDaily.date,listDaily.positive,'b')
hold on
plot(listDaily.date,listDaily.hospitalized,'r')
plot(listDaily.date,yy,'k--')
legend('positive tests (%)','new hospitalized patients','predicted new hospitalized, as 13*positive tests 3 days before')

%% dashboard
listD = readtable('dashboard_timeseries.csv');
listD.CountDeath(isnan(listD.CountDeath)) = 0;
dpm = listD.CountDeath/pop*10^6;
ds2 = movmean(dpm,[3 3]);
%i1 = find(~isnan(ds2),1);
ps2 = listD.tests_positive./listD.tests_result*100;
ps2(106:113)
ps2(106:113) = 0.7;

[xc,lag] = xcorr(ps2,dpm);
figure;
plot(lag,xc)
ps2(1:22) = 0;
b = ps2(1:end-15)\ds2(16:end);

pred3 = [zeros(15,1);ps2(1:end-15)*b];
pred3(1:37) = 0;
figure;
plot(listD.date,listD.tests_positive./listD.tests_result*100)
hold on
plot(listD.date,dpm,'r')
plot(listD.date,pred3,'k--')
title('Israel')
legend('positive tests (%)','deaths per million',...
    ['predicted as ',str(round(b,2)),' of positive 16 days before'],...
    'predicted as 0.12 of positive 16 days before')
ylim([0 13])
box off
grid on
box off
grid on
%ylim([0 30])

figure;
plot(listD.date,cumsum(dpm),'r')
hold on
plot(listD.date,cumsum(pred3),'k--')
title('Israel')

legend('positive tests (%)','deaths per million',...
    ['predicted as ',str(round(b,2)),' of positive 16 days before'],...
    'predicted as 0.12 of positive 16 days before')
box off
grid on
box off
grid on
%% intercept
b = [ones(length(ps2)-15,1),ps2(1:end-15)]\ds2(16:end);
b(1) = 0.056;

pred4 = [zeros(15,1);[ones(length(ps2),1),ps2]*b];
pred4(1:37) = 0;
figure;
plot(listD.date,listD.tests_positive./listD.tests_result*100)
hold on
plot(listD.date,dpm,'r')
d = [listD.date;(listD.date(end)+1:listD.date(end)+15)'];
plot(d,pred4,'k--')
title('Daily deaths per million')
legend('positive tests (%)','deaths per million',...
    ['predicted as ',str(round(b(2),2)),' of positive 16 days before'],...
    'predicted as 0.12 of positive 16 days before')
ylim([0 13])
box off
grid on
box off
grid on
%ylim([0 30])

figure;
plot(listD.date,cumsum(dpm),'r')
hold on
plot(d,cumsum(pred4),'k--')
title('Cumulative deaths per million')
legend('deaths per million',...
    ['predicted as ',str(round(b(2),2)),' of positive 16 days before'],...
    'predicted as 0.12 of positive 16 days before')
box off
grid on
box off
grid on

%% stop training two weeks ago
%b = [ones(length(ps2)-15,1),ps2(1:end-15)]\ds2(16:end);
endTrain = length(ds2)-14;
b = [ones(endTrain-15,1),movmean(ps2(1:endTrain-15),[3 3])]\ds2(16:endTrain);
%b(1) = 0.056;

pred4 = movmean([zeros(15,1);[ones(length(ps2),1),ps2]*b],[3 3]);
pred4(1:37) = 0;
figure;
subplot(1,2,1)
plot(listD.date,listD.tests_positive./listD.tests_result*100)
hold on
plot(listD.date,dpm,'r')
d = [listD.date;(listD.date(end)+1:listD.date(end)+15)'];
plot(d,pred4,'k--')
title('Daily deaths per million')
legend('positive tests (%)','deaths per million',...
    ['predicted as ',str(round(b(end),2)),' of positive 16 days before'])
ylim([0 13])
box off
grid on
box off
grid on
%ylim([0 30])
subplot(1,2,2)
plot(listD.date,cumsum(dpm),'r')
hold on
plot(d,cumsum(pred4),'k--')
title('Cumulative deaths per million')
legend('deaths per million',...
    ['predicted as ',str(round(b(end),2)),' of positive 16 days before'])
box off
grid on
box off
grid on