cd ~/covid-19-israel-matlab/data/Israel
ncba = readtable('crit_by_age.csv');
col = [0.906 0.329 0.357;0.271 0.478 0.647;0.439 0.718 0.698];
listD = readtable('dashboard_timeseries.csv');
newc = readtable('new_critical.csv');
figure;
subplot(2,1,1)
h1 = bar(ncba.date,ncba{:,2:4},'stacked','EdgeColor','none');
for ii = 1:3
    h1(ii).FaceColor = col(ii,:);
end
set(gca,'ygrid','on','XTick',ncba.date)
xtickformat('dd/MM')
xtickangle(90)
i = 2;
y = 0.5*ncba{:,i};
t = str(round(ncba{:,i}));
text(ncba.date-0.3,y,t,'Color','w')
i = 3;
y = ncba{:,i-1}+0.5*ncba{:,i};
t = str(round(ncba{:,i}./sum(ncba{:,2:4},2)*100));
text(ncba.date-0.3,y,t,'Color','w')
title('קשים וקריטיים חדשים לפי גיל')
box off
hold on
idx = find(ismember(listD.date,ncba.date));
plot(listD.date(idx),listD.serious_critical_new(idx))
plot(listD.date(idx(2:end)),diff(listD.CountSeriousCriticalCum(idx)))
jdx = find(ismember(newc.date,ncba.date));
plot(newc.date(jdx),newc.new_critical(jdx),'k')
plot(datetime(2021,1,21:35),[123,125,136,127,164,156,126,133,98,88,116,125,134,152,124],'Color',[0.82,0.561,0.369])
legend('60+','40-60','<40','serious critical new','CountSeriousCriticalCum','מאגר מידע','דו"ח יומי')
subplot(2,1,2)
h2 = bar(ncba.date,ncba{:,2:4}./sum(ncba{:,2:4},2)*100,'stacked','EdgeColor','none');
for ii = 1:3
    h2(ii).FaceColor = col(ii,:);
end
i = 2;
y = 0.5*ncba{:,i};
t = str(round(ncba{:,i}./sum(ncba{:,2:4},2)*100));
text(ncba.date-0.3,y,t,'Color','w')
i = 3;
y = ncba{:,i-1}./sum(ncba{:,2:4},2)*100+0.5*ncba{:,i};
t = str(round(ncba{:,i}./sum(ncba{:,2:4},2)*100));
text(ncba.date-0.3,y,t,'Color','w')
set(gca,'ygrid','on','XTick',ncba.date)
ylim([0 100])
xtickformat('dd/MM')
xtickangle(90)
set(gcf,'Color','w')
box off
title('קשים וקריטיים חדשים לפי גיל (%)')