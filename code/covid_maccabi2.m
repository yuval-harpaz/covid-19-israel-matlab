cd /home/innereye/covid-19-israel-matlab/data/Israel
y = [667,98;434,71;285,43;150,34;61,12;48,8;31,6;51,14];
listD = readtable('dashboard_timeseries.csv');

figure;
subplot(2,1,1)
yyaxis right
plot(2:9,y(:,1),'Color',[0.2,0.7,0.2])
ylabel('Positive')
yyaxis left
plot(2:9,y(:,2))
ax = gca;
ax.YAxis(2).Color = [0.2,0.7,0.2];
grid on
grid minor
title({'Positive and hospitalized vaccinated cases','over 60 years old'})
xlabel('weeks from dose I')
ylabel('Hospitalized')

subplot(2,1,2)
% plot(listD.date,movmean(listD.tests_positive,[3 3]))
% xlim([datetime(2021,1,9) datetime(2021,3,11)])
 set(gcf,'Color','w')
% 
% 
% grid on

yyaxis right
plot(listD.date,movmean(listD.tests_positive,[3 3]),'Color',[0.2,0.7,0.2])
ylabel('Positive')
ylim([0 9000])
xlim([datetime(2021,1,9) datetime(2021,3,11)])
yyaxis left
plot(listD.date,movmean(listD.new_hospitalized,[3 3]))
ax = gca;
ax.YAxis(2).Color = [0.2,0.7,0.2];
grid on
grid minor
ylim([0 300])
title('New positive cases and hospitalized for all Israel')
% xlabel('weeks from dose I')
ylabel('Hospitalized')