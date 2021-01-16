cd ~/covid-19-israel-matlab/data/Israel
t = readtable('vent_per_hosp.csv');
t1 = t(ismember(t.date,datetime(2021,1,1)),:)
figure;
h = bar([t1.vent,t1.crit-t1.vent],'stacked'); legend(h([2,1]),'קריטיים לא מונשמים','קריטיים מונשמים')
set(gcf,'Color','w')
set(gca,'XTickLabel',t1.hosp,'xtick',1:height(t1),'ygrid','on')
xtickangle(90)
box off
ylim([0 50])
grid on

t1 = t(ismember(t.date,datetime(2021,1,14)),:)
figure;
h = bar([t1.vent,t1.crit-t1.vent],'stacked'); legend(h([2,1]),'קריטיים לא מונשמים','קריטיים מונשמים')
set(gcf,'Color','w')
set(gca,'XTickLabel',t1.hosp,'xtick',1:height(t1),'ygrid','on')
xtickangle(90)
box off
ylim([0 50])
grid on

figure;
h3 = bar([t1.vent-t1.ecmo,t1.ecmo,t1.crit-t1.vent],'stacked','EdgeColor','none');
tmp = h3(2).FaceColor;
h3(2).FaceColor = h3(3).FaceColor;
h3(3).FaceColor = tmp;
legend(h3([3,2,1]),'ללא הנשמה \ אקמו','אקמו','הנשמה חודרנית')
set(gcf,'Color','w')
set(gca,'XTickLabel',t1.hosp,'xtick',1:height(t1),'ygrid','on')
xtickangle(90)
box off
ylim([0 50])
grid on
title('הטיפול בחולים הקריטיים לפי בית חולים')


t2 = t(ismember(t.date,datetime(2021,1,12)),:)