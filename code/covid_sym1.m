tests = readtable('tests.csv');
figure;
subplot(2,1,1)
yyaxis left;
sp60 = tests.symptoms_pos_f_60+tests.symptoms_pos_m_60;
plot(tests.date,sp60);
yyaxis right;
plot(tests.date,tests.symptoms_pos_f+tests.symptoms_pos_m-sp60)
xtickformat('MMM')
grid on
set(gcf,'Color','w')
title('מאומתים סימפטומטיים')
legend('מבוגרים מ 60','צעירים מ 60')



rat = sp60./(tests.symptoms_pos_f+tests.symptoms_pos_m);
rat(rat == 0) = nan;
rat = movmean(rat,[3 3],'omitnan');
subplot(2,1,2)
plot(tests.date,rat)
xtickformat('MMM')
grid on
set(gcf,'Color','w')
title('שיעור המבוגרים מ- 60 במאומתים סימפטומטיים')