tests = readtable('tests.csv');
perSym = 100*(tests.symptoms_pos_f_60+tests.symptoms_pos_m_60)./(tests.nosymptoms_pos_m+tests.nosymptoms_pos_f);
perSmSm = perSym;
perSmSm(1:end-6) = movmean(perSmSm(1:end-6),[3 3],'omitnan');
figure;plot(tests.date,perSmSm)
xlim([datetime(2020,6,15) datetime('today')])
grid on
box off
ylim([0 25])
set(gcf,'Color','w')
ylabel('אחוז הסימפטומאטיים')
title('אחוז החיוביים הסימטומאטיים מתוך החיוביים')