
cd ~/covid-19-israel-matlab/data/Israel
tests = readtable('tests.csv');
perSym = 100*(tests.symptoms_pos_f_60+tests.symptoms_pos_m_60)./(tests.pos_f_60+tests.pos_m_60);
perSym(:,2) = 100*(tests.symptoms_pos_f+tests.symptoms_pos_m-tests.symptoms_pos_f_60-tests.symptoms_pos_m_60)./(tests.pos_f+tests.pos_m-tests.pos_f_60-tests.pos_m_60);
perSmSm = perSym;
perSmSm(1:end-6,:) = movmean(perSmSm(1:end-6,:),[3 3],'omitnan');
figure;plot(tests.date,perSmSm)
% xlim([datetime(2020,6,15) datetime('today')])
grid on
box off
% ylim([0 25])
set(gcf,'Color','w')
ylabel('אחוז הסימפטומאטיים')
title('אחוז החיוביים הסימטומאטיים מתוך החיוביים')