tot = covid_pred_vax2(30000,datetime(2021,1,7),'steep');
tot(2,1:3) = covid_pred_vax2(45000,datetime(2021,1,7),'steep');
tot(3,1:3) = covid_pred_vax2(60000,datetime(2021,1,7),'steep');
tot(4,1:3) = covid_pred_vax2(30000,datetime(2021,1,7),'current');
tot(5,1:3) = covid_pred_vax2(45000,datetime(2021,1,7),'current');
tot(6,1:3) = covid_pred_vax2(60000,datetime(2021,1,7),'current');

figure;
h = bar(tot);
legend('חיסון','סגר','חיסון+סגר')
set(gca,'XTickLabel',1000*[30,45,60,30,45,60,],'ygrid','on')
xlabel('התחלואה עולה בקצב הנוכחי          העליה בתחלואה מתגברת')
set(gcf,'Color','w')
box off
title('התמותה שתתווסף בהתאם לאמצעים (צבע), חיסונים ליום וקצב תחלואה (ציר X)')
h(1).FaceColor = [0 1 0];
h(2).FaceColor = [1 0 0];
h(3).FaceColor = [0 0 0];
ylabel('תמותה מהיום עד ה- 1.4')
grid minor