cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');

newc = readtable('new_critical.csv');
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = jsondecode(json);
death = json.result.records;
death = struct2table(death);
pos2death = cellfun(@str2num,strrep(death.Time_between_positive_and_death,'NULL','0'));
bad = pos2death < 1 | ismember(death.gender,'לא ידוע');
isMale = ismember(death.gender(~bad),'זכר');
pos2death = pos2death(~bad);
% old = ~ismember(death.age_group,'<65');
hosp = cellfun(@str2num,strrep(death.Length_of_hospitalization,'NULL','0'));
% bad = pos2death < 1 | ismember(death.gender,'לא ידוע');
% isMale = ismember(death.gender(~bad),'זכר');
% pos2death = pos2death(~bad);


prob = movmean(hist(pos2death,1:1000),[3 3]);
iEnd = find(prob < 0.5,1);
prob = prob(1:iEnd-1);
prob = prob/sum(prob);

probH = movmean(hist(hosp,1:1000),[3 3]);
iEnd = find(probH < 0.5,1);
probH = probH(1:iEnd-1);
probH = probH/sum(probH);

critDiff = diff(listD.CountSeriousCriticalCum);
if critDiff(187) > 140
    critDiff(187) = mean(critDiff([186,188]));
else
    error('where is the spike?')
end
col = [0,0.447,0.741;0.850,0.325,0.0980;0.929,0.694,0.125;0.494,0.184,0.556;0.466,0.674,0.188;0.301,0.745,0.933;0.635,0.0780,0.184];

%%
% p1to10 = 1./(1:10);
% p1to10 = p1to10./sum(p1to10);
prob6 = prob(4:20);
prob6 = prob6./sum(prob6);
predCrit = conv(critDiff,prob6);
date = listD.date(2):listD.date(2)+length(predCrit)-1;
death = movmean(listD.CountDeath,[3 3]);
figure;
subplot(1,2,2)
yyaxis right
h(1) = scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor',col(1,:),'MarkerEdgeAlpha',0.5);
hold on
h(2) = plot(listD.date,death,'-','Color',col(1,:),'linewidth',1.5);
h(3) = plot(date,predCrit*5/16,'-k');
line(datetime(2020,10,[20,20]),[0 27],'Color','k','linestyle','--')
ylabel('נפטרים')
yyaxis left
h(4) = scatter(listD.date(2:end),critDiff,'.','MarkerEdgeColor',col(2,:),'MarkerEdgeAlpha',0.5);
hold on
h(5) = plot(listD.date(2:end),movmean(critDiff,[3 3]),'-','Color',col(2,:),'linewidth',1.5);
grid on
ylabel('חולים')
ylim([0 170])
ax = gca;
ax.YAxis(2).Color = col(1,:);
ax.YAxis(1).Color = col(2,:);
set(gca,'YTick',0:17:170)
legend(h([2,3,5]),'נפטרים','צפי תמותה לפי קריטיים חדשים','קריטיים חדשים','location','northwest')
xlim([datetime(2020,8,15) datetime('today')])
set(gcf,'Color','w')
title('תמותה מעבר למצופה אחרי ה 20 לאוק''')


mean(death(251:269)-predCrit(251:269)*5/16)
sum(death(251:269)-predCrit(251:269)*5/16)
%
idx = 188:height(listD);
subplot(1,2,1);
hh(1) = scatter(listD.date(idx),listD.CountBreath(idx),'.','MarkerEdgeColor',col(1,:),'MarkerEdgeAlpha',0.5);
hold on
hh(2) = plot(listD.date(idx),movmean(listD.CountBreath(idx),[3 3]),'-','Color',col(1,:),'linewidth',1.5);
hh(3) = scatter(listD.date(idx),listD.CountCriticalStatus(idx),'.','MarkerEdgeColor',col(2,:),'MarkerEdgeAlpha',0.5);
hh(4) = plot(listD.date(idx),movmean(listD.CountCriticalStatus(idx),[3 3]),'-','Color',col(2,:),'linewidth',1.5);
grid on
ylim([0 350])
line(datetime(2020,10,[20,20]),[0 200],'Color','k','linestyle','--')
% ax = gca;
% ax.YAxis(2).Color = col(1,:);
% ax.YAxis(1).Color = col(2,:);
% set(gca,'YTick',0:17:170)
legend(hh([4,2]),'סך הכל קריטיים','סך הכל מונשמים','location','northwest')
xlim([datetime(2020,8,15) datetime('today')])
set(gcf,'Color','w')
title('פער בין מספר החולים הקריטיים למונשמים בשיא הגל השני')
set(gcf,'Color','w')
ylabel('חולים')
% figure;
% plot(listD.date(idx),listD.CountBreath(idx));
% hold on
% plot(listD.date(idx),listD.CountCriticalStatus(idx))
% plot(listD.date(idx),listD.CountDeath(idx),'k')
% plot(listD.date(idx),diff(listD.CountSeriousCriticalCum([idx(1)-1,idx])))

%%




% listD.CountCriticalStatus
% x = movmean(tests.pos60,[3 3]);
% x = [x;(x(end)-85/3:-85/3:0)';0];
% predBest =  conv(x,prob);
% xf = movmean(tests.pos_f_60,[3 3]);
% xf = [xf;(xf(end)-85/3:-85/3:0)';0];
% predBestF =  conv(xf,female);
% xm = movmean(tests.pos_m_60,[3 3]);
% xm = [xm;(xm(end)-85/3:-85/3:0)';0];
% predBestM =  conv(xm,male);
% 
% xConst = movmean(tests.pos60,[3 3]);
% xConst = [xConst;repmat(mean(x(end-7:end)),1000,1)];
% predConst =  conv(xConst,prob);
% predConst = predConst(1:length(predBest));
% 
% clear h
% figPred = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
% plot(listD.date,listD.CountDeath,'.b');
% hold on;
% h(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
% h(2) = plot(x1oct(204:end),y1oct(204:end),'r--','linewidth',2);
% h(3) = plot(tests.date(1):tests.date(1)+length(predBest)-1,predBest/10,'k','linewidth',1);
% grid on
% grid minor
% ylabel('נפטרים ליום')
% legend(h,'נפטרים','ניבוי תמותה מה- 1 לאוק''','ניבוי תמותה מתעדכן','location','northwest')
% title('ניבוי תמותה לפי ירידה אופטימלית בתחלואה')
% box off
% set(gca,'fontsize',13)
% set(gca,'XTick',datetime(2020,3:12,1))
% xtickangle(45)
% xlim([datetime(2020,3,15) datetime(2020,12,15)]);
% set(gcf,'color','w')
% saveas(figPred,'Oct1prediction.png')
% %%
% y = movmean(tests.pos60,[3,3]);
% figure;
% subplot(2,2,1);
% plot(y,'b')
% hold on
% box off
% grid on
% ylabel('positive tests')
% xlabel('days')
% title('Positive over 60')
% xlim([0 300])
% subplot(2,2,2)
% plot(prob,'b')
% ylabel('deceased')
% xlabel('days')
% title('probability of death date after positive')
% xlim([0 75])
% box off
% grid on
% subplot(2,2,3)
% plot(predBest,'b')
% box off
% grid on
% title('death prediction')
% ylabel('deaths (daily)')
% subplot(2,2,4)
% plot(cumsum(predBest/10),'b')
% ax = gca;
% ax.YRuler.Exponent = 0;
% 
% ylim([0 2500])
% box off
% grid on
% title('death prediction (cumulative)')
% ylabel('deaths (total)')
% 
% %%
% 
% xx = movmean(tests.pos60,[3 3]);
% xx(234:310) = xx(34:110);
% pred2 =  conv(xx,prob);
% figPred2 = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
% h2(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
% hold on
% h2(2) = plot(tests.date(233)+1:tests.date(233)+length(pred2)-233,pred2(234:end)/10,'r--','linewidth',2);
% grid on
% grid minor
% ylabel('נפטרים ליום')
% legend(h2,'נפטרים','ניבוי תמותה ','location','northwest')
% title('ניבוי תמותה לפי ירידה בתחלואה בשיעור דומה לגל הראשון')
% box off
% set(gca,'fontsize',13)
% set(gca,'XTick',[datetime(2020,3:12,1),datetime(2021,1:2,1)])
% xtickangle(45)
% xlim([datetime(2020,3,1) datetime(2021,3,1)])
% set(gcf,'color','w')
% % saveas(figPred2,'Nov1prediction.png')
% % saveas(figPred2,'Nov1prediction.fig')
% 
% 
% %% const
% iStart = find(predConst > predBest,1);
% clear hc
% figConst = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
% plot(listD.date,listD.CountDeath,'.b');
% hold on;
% hc(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
% hc(2) = plot(tests.date(1):tests.date(1)+length(predBest)-1,predBest/10,'k','linewidth',1);
% hc(3) = plot(tests.date(1)+iStart-1:tests.date(1)+length(predBest)-1,predConst(iStart:end)/10,'r','linewidth',1);
% grid on
% grid minor
% ylabel('נפטרים ליום')
% legend(hc,'נפטרים','ניבוי תמותה לפי החולים עד כה','ניבוי תמותה לפי R = 1','location','northwest')
% title('ניבוי תמותה לפי מאומתים מעל 60')
% box off
% set(gca,'fontsize',13)
% set(gca,'XTick',datetime(2020,3:12,1))
% xtickangle(45)
% xlim([datetime(2020,3,15) datetime(2020,12,15)]);
% set(gcf,'color','w')
% % saveas(figPred,'Oct1prediction.png')