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

