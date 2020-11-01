pos1 = listD.tests_positive./listD.tests_result;
pos1(108:109) = 0.0155;
pos1(107:112) = 0.0072;
pos1 = movmean(pos1,[3 3],'omitnan');

pos2 = (tests.pos_f+tests.pos_m)./(tests.pos_f+tests.pos_m+tests.neg_m+tests.neg_f);
pos2(79:86) = 0.007;
pos2(1) = 0.06;
pos2(isnan(pos2)) = 0.005;
pos2 = movmean(pos2,[3 3],'omitnan');

pos3 = (tests.pos_f_60+tests.pos_m_60)./(tests.pos_f_60+tests.pos_m_60+tests.neg_m+tests.neg_f_60);
pos3(10) = 0.03;
pos3(221) = 0.014;
pos3(228) = 0.01;
pos3(isnan(pos3)) = 0;
pos3(pos3<0.005) = pos2(pos3<0.005)*0.11;
pos3 = movmean(pos3,[3 3],'omitnan');

dead = movmean(listD.CountDeath,[3 3],'omitnan');

figure
plot(listD.date,pos1/max(pos1));
hold on;
plot(tests.date,pos2/max(pos2))
plot(tests.date,pos3/max(pos3))
plot(listD.date,dead/max(dead),'k')

pos2 = [zeros(27,1);pos2];
pos3 = [zeros(27,1);pos3];
pos1 = pos1(1:length(pos2));
prob = readtable('positive_to_death.txt');

pred = conv(pos1,prob.all);
pred(:,2) = conv(pos2,prob.all);
pred(:,3) = conv(pos3,prob.all);
date = listD.date(1):listD.date(1)+length(pred)-1;
figure;
plot(date,pred.*[325,270,950])
hold on
plot(listD.date,dead)

lag = 7;
for ii = 15:length(date)
    pred1(ii,1) = dead(ii-7)-pred(ii-7,3)*950+pred(ii,3)*950;
end