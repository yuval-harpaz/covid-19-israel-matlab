t = readtable('~/Downloads/vent_per_hosp - Sheet1.csv');
t = t(ismember(t.date,datetime(2021,1,1)),:)
% figure
% 
% bar([t.vent,t.crit-t.vent],'stacked')
% set(gcf,'Color','w')
% legend('קריטיים מונשמים','קריטיים לא מונשמים')
% figure;h = bar([t.vent,t.crit-t.vent],'stacked');legend(h([2,1],'קריטיים מונשמים','קריטיים לא מונשמים')
% figure; h = bar([t.vent,t.crit-t.vent],'stacked'); legend(h([2,1],'קריטיים מונשמים','קריטיים לא מונשמים'))
% h
% figure; h = bar([t.vent,t.crit-t.vent],'stacked'); legend(h([2,1]),'קריטיים מונשמים','קריטיים לא מונשמים')
figure; h = bar([t.vent,t.crit-t.vent],'stacked'); legend(h([2,1]),'קריטיים לא מונשמים','קריטיים מונשמים')
% covid_Israel
% set(gca,'XTickLabel',t.hosp)
% set(gca,'XTickLabel',t.hosp,'xtick',1:height(t))

set(gcf,'Color','w')
set(gca,'XTickLabel',t.hosp,'xtick',1:height(t),'ygrid','on')
xtickangle(90)
box off
ylim([0 40])