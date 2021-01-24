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


%%
t14 = t(t.date == datetime(2021,1,14),:);
t22 = t(t.date == datetime(2021,1,22),:);
t24 = t(t.date == datetime(2021,1,24),:);
% t24(t24.crit == 0,:) = [];
% t22(t22.crit == 0,:) = [];
% t14(t14.crit == 0,:) = [];

figure;
subplot(2,1,1)
h = bar([t14.crit,t22.crit,t24.crit],'EdgeColor','none');
set(gca,'XTickLabel',t22.hosp,'xtick',1:height(t22),'ygrid','on')
xtickangle(90)
box off
col =  [0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250];
col = col([1,3,2],:);
for ii = 1:3
    h(ii).FaceColor = col(ii,:);
end
legend('14/1/21','22/1/21','24/1/21')
title('קריטיים')
subplot(2,1,2)
h = bar([t14.vent,t22.vent],'EdgeColor','none');
set(gca,'XTickLabel',t22.hosp,'xtick',1:height(t22),'ygrid','on')
xtickangle(90)
box off
for ii = 1:2
    h(ii).FaceColor = col(ii,:);
end
ylim([0 50])
title('מונשמים')
% figure;
% h22 = bar([t1.vent-t1.ecmo,t1.ecmo,t1.crit-t1.vent],'stacked','EdgeColor','none');
% tmp = h3(2).FaceColor;
% h3(2).FaceColor = h3(3).FaceColor;
% h3(3).FaceColor = tmp;

