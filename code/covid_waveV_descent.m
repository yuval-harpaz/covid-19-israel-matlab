listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
rat = sum(listD.tests_positive1(end-7:end-1))./sum(listD.tests_positive1(end-14:end-8));
y = movmean(listD.tests_positive1(1:end-1),[3 3]);
% rat = y(8:end)./y(1:end-7);
pred = zeros(100,1);
for ii = 1:100
    pred(ii,1) = y(end-4)*(rat^(1/7))^(ii-1);
end
dp = listD.date(end-4);
dp = dp:dp+length(pred)-1;
dp = dp-1;
figure;
plot(listD.date(1:end-1),listD.tests_positive1(1:end-1),'b.')
hold on
hh(1) = plot(listD.date(1:end-1),y,'b');
hh(2) = plot(dp,pred,'g');
grid on
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0g';
xlim([datetime('1-Jul-2021') datetime('today')+100])
legend(hh, 'cases','predicted cases','location','northwest')
title(['Wave V descent, weekly multiplication factor = ',str(round(rat,2))])
set(gcf,'Color','w')

%% 
now1 = y(end-4)/y(end-7-4);
ratall = y(8:end-4)./y(1:end-7-4);
figure;
yyaxis left
plot(listD.date(1:end-1),y)
ylabel cases
yyaxis right
plot(listD.date(8:end-5),ratall)
ylabel('weekly multiplication factor')
xlim([datetime('1-Mar-2020') datetime('today')+5])
set(gcf,'Color','w')
grid on
line([datetime('1-Mar-2020') datetime('today')+5], [now1 now1],'linestyle','--','Color','k')
legend('cases','multiplication factor', ['current descent rate: ', str(round(now1,2))], 'location','northwest')
title('Current descent compared to previous waves')

%%
rat1 = ratall(390:end);
rat1(find(rat1 > 0.92,1):end) = 1;
rat1 = [0.5901;rat1(1:99)];
daysm = 4;
rat1(daysm:end) = movmean(rat1(daysm:end),[daysm daysm]);
rat7 = rat1.^(1/7);
pred1 = zeros(100,1);
for ii = 1:100
    pred1(ii,1) = y(730)*prod(rat7(1:ii));
end
dp = listD.date(730);
dp = dp:dp+length(pred1)-1;
% dp = dp-1;
figure;
plot(listD.date(1:end-1),listD.tests_positive1(1:end-1),'b.')
hold on
hh(1) = plot(listD.date(1:end-1),y,'b');
hh(2) = plot(dp,pred1,'g');
grid on
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0g';
xlim([datetime('1-Jul-2021') datetime('today')+100])
legend(hh, 'cases','predicted cases','location','northwest')
title(['Wave V descent, weekly multiplication factor = ',str(round(rat,2))])
set(gcf,'Color','w')

%%
dp1 = listD.date;
dp1(729:828) = dp;
dp1 = dp1(1:828);
y1 = y;
y1(729:828) = pred1;
y1 = y1(1:828);

R = covid_R31(listD.tests_positive1);
R1 = covid_R31(y1);
R1(1:length(R)) = R;
figure;
yyaxis left
plot(listD.date(1:end-1),y)
hold on
plot(dp1,y1,':')
ylabel cases
yyaxis right
plot(listD.date(19:end-11),R(26:end-4))
hold on
plot(dp1(19:end-11),R1(26:end-4),':')
ylim([0.5 2.5])
ylabel('R')
xlim([datetime('1-Mar-2020') datetime('today')+50])
set(gcf,'Color','w')
grid on
% line([datetime('1-Mar-2020') datetime('today')+5], [now1 now1],'linestyle','--','Color','k')
legend('cases','predicted cases', 'R','predicted R', 'location','northwest')
title('Predicting cases, assuming R will descend as before')