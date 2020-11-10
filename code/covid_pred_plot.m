cd ~/covid-19-israel-matlab/data/Israel
tests = readtable('tests.csv'); 
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
old = ~ismember(death.age_group,'<65');
prob = movmean(hist(pos2death,1:1000),[3 3]);
iEnd = find(prob < 0.5,1);
prob = prob(1:iEnd-1);
prob = prob/sum(prob);

female = movmean(hist(pos2death(~isMale),1:1000),[3 3]);
iEnd = find(female < 0.5,1);
female = female(1:iEnd-1);
female = female'/sum(female);
male = movmean(hist(pos2death(isMale),1:1000),[3 3]);
iEnd = find(male < 0.5,1);
male = male(1:iEnd-1);
male = male'/sum(male);
all = prob';
male(end+1:length(all)) = 0;
female(end+1:length(all)) = 0;
tProb = table(all,female,male);
writetable(tProb,'positive_to_death.txt','WriteVariableNames',true)
%%

hs = open('pred1.fig');
hp = findobj(gca,'Type','line');
y1oct = hp(2).YData';
x1oct = hp(2).XData';
close(hs)
x = movmean(tests.pos60,[3 3]);
x = [x;(x(end)-85/3:-85/3:0)';0];
predBest =  conv(x,prob);
xf = movmean(tests.pos_f_60,[3 3]);
xf = [xf;(xf(end)-85/3:-85/3:0)';0];
predBestF =  conv(xf,female);
xm = movmean(tests.pos_m_60,[3 3]);
xm = [xm;(xm(end)-85/3:-85/3:0)';0];
predBestM =  conv(xm,male);

xConst = movmean(tests.pos60,[3 3]);
xConst = [xConst;repmat(mean(x(end-7:end)),1000,1)];
xConst = xConst(1:length(x));
predConst =  conv(xConst,prob);

clear h
figPred = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
plot(listD.date,listD.CountDeath,'.b');
hold on;
h(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
h(2) = plot(x1oct(204:end),y1oct(204:end),'r--','linewidth',2);
h(3) = plot(tests.date(1):tests.date(1)+length(predBest)-1,predBest/10,'k','linewidth',1);
grid on
grid minor
ylabel('נפטרים ליום')
legend(h,'נפטרים','ניבוי תמותה מה- 1 לאוק''','ניבוי תמותה מתעדכן','location','northwest')
title('ניבוי תמותה לפי ירידה אופטימלית בתחלואה')
box off
set(gca,'fontsize',13)
set(gca,'XTick',datetime(2020,3:12,1))
xtickangle(45)
xlim([datetime(2020,3,15) datetime(2020,12,15)]);
set(gcf,'color','w')
saveas(figPred,'Oct1prediction.png')
%%
y = movmean(tests.pos60,[3,3]);
figure;
subplot(2,2,1);
plot(y,'b')
hold on
box off
grid on
ylabel('positive tests')
xlabel('days')
title('Positive over 60')
xlim([0 300])
subplot(2,2,2)
plot(prob,'b')
ylabel('deceased')
xlabel('days')
title('probability of death date after positive')
xlim([0 75])
box off
grid on
subplot(2,2,3)
plot(predBest,'b')
box off
grid on
title('death prediction')
ylabel('deaths (daily)')
subplot(2,2,4)
plot(cumsum(predBest/10),'b')
ax = gca;
ax.YRuler.Exponent = 0;

ylim([0 2500])
box off
grid on
title('death prediction (cumulative)')
ylabel('deaths (total)')

%%

xx = movmean(tests.pos60,[3 3]);
xx(234:310) = xx(34:110);
pred2 =  conv(xx,prob);
figPred2 = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
h2(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
hold on
h2(2) = plot(tests.date(233)+1:tests.date(233)+length(pred2)-233,pred2(234:end)/10,'r--','linewidth',2);
grid on
grid minor
ylabel('נפטרים ליום')
legend(h2,'נפטרים','ניבוי תמותה ','location','northwest')
title('ניבוי תמותה לפי ירידה בתחלואה בשיעור דומה לגל הראשון')
box off
set(gca,'fontsize',13)
set(gca,'XTick',[datetime(2020,3:12,1),datetime(2021,1:2,1)])
xtickangle(45)
xlim([datetime(2020,3,1) datetime(2021,3,1)])
set(gcf,'color','w')
saveas(figPred2,'Nov1prediction.png')
saveas(figPred2,'Nov1prediction.fig')