function covid_Israel_percent_positive
%% משרד הבריאות
cd ~/covid-19-israel-matlab/
%% get hiSmallerory
list = readtable('data/Israel/dashboard_timeseries.csv');
lastValid = find(~isnan(list.new_hospitalized),1,'last');
idx = 27:lastValid;
figure;
yyaxis left
plot(list.date(idx),list.tests(idx));
ylabel('tests')
ax = gca;
ax.YRuler.Exponent = 0;

yyaxis right
plot(list.date(idx),round(100*list.tests_positive(idx)./list.tests(idx),1))
ylabel('positive tests')
set(gca,'ygrid', 'on','fontsize',13)
hold on
scatter(datetime('18-Apr-2020'),2.7,'fill','k')
legend('בדיקות','בדיקות חיוביות','18-Apr')