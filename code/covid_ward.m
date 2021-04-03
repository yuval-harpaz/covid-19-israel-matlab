t = readtable('~/covid-19-israel-matlab/data/Israel/crit_by_ward.xlsx');
figure
yyaxis left
plot(t.date,[t.corona,t.all-t.corona])
ylim([-100 500])
ylabel('patients    חולים')
yyaxis right
plot(t.date,100*t.corona./t.all)
ylim([40 100])
ylabel('ratio of positive patients  (%)  שיעור החולים החיוביים')
grid on
xtickformat('MMM')
xlim([t.date(1),datetime('tomorrow')])
legend('Corona ward       חולים במחלקת קורונה','Other wards       חולים במחלקות אחרות','Ratio of corona-active   שיעור חולי הקורונה הפעילים')
set(gcf,'Color','w')
title({'חולים במצב קריטי פעילים (במחלקת קורונה) ובהתאוששות','Critical patients - active (Corona ward) and in recovery'})
