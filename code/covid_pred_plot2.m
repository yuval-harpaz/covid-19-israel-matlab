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
all1 = prob';
male(end+1:length(all1)) = 0;
female(end+1:length(all1)) = 0;
tProb = table(all1,female,male);
writetable(tProb,'positive_to_death.txt','WriteVariableNames',true)
%%

hs = open('pred1.fig');
hp = findobj(gca,'Type','line');
y1oct = hp(2).YData';
x1oct = hp(2).XData';
close(hs)
x = movmean(tests.pos60,[3 3]);
% x = [x;(x(end)-85/3:-85/3:0)';0];
predBest =  conv(x,prob);
% xf = movmean(tests.pos_f_60,[3 3]);
% xf = [xf;(xf(end)-85/3:-85/3:0)';0];
% predBestF =  conv(xf,female);
% xm = movmean(tests.pos_m_60,[3 3]);
% xm = [xm;(xm(end)-85/3:-85/3:0)';0];
% predBestM =  conv(xm,male);

xConst = movmean(tests.pos60,[3 3]);
xConst = [xConst;repmat(mean(x(end-2:end)),1000,1)];

xLin = [x;x(end)+transpose(mean(diff(x(end-7:end))).*(1:30))];
clear hx
figure
hx(2) = plot(tests.date(1):tests.date(1)+length(xLin)-1,xConst(1:length(xLin)),'g');
hold on;
hx(1) = plot(tests.date(1):tests.date(1)+length(xLin)-1,xLin,'r');
hx(3) = plot(tests.date(1):tests.date(1)+length(x)-1,x,'k');
grid on
grid minor
ylabel('מאומתים מעל 60')
legend(hx,'מנבא תמותה לפי קצב העליה הנוכחי','מנבא תמותה לפי R = 1','הנדבקים עד היום','location','northwest')
title('מנבאי תמותה לפי מאומתים מעל גיל 60 (בדיקה ראשונה)')
box off
set(gca,'fontsize',12)
set(gca,'XTick',datetime(2020,3:12,1))
xtickangle(45)
xlim([datetime(2020,3,15) tests.date(end)+30]);


predLin = conv(xLin,prob);
predConst =  conv(xConst,prob);
predConst = predConst(1:length(predLin));
iStart = find(predConst(1:length(predBest) )> predBest,1);

add = 1;
clear h
figPred = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
plot(listD.date,listD.CountDeath,'.b');
hold on;
h(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
h(2) = plot(tests.date(1)+iStart-1:tests.date(1)+length(predLin)-1,predLin(iStart:end)/10+add,'r');
h(4) = plot(tests.date(1):tests.date(1)+length(predBest)-1,predBest/10+add,'k','linewidth',1);
h(3) = plot(tests.date(1)+iStart-1:tests.date(1)+length(predConst)-1,predConst(iStart:end)/10+add,'g','linewidth',1);
grid on
grid minor
ylabel('נפטרים ליום')
legend(h,'נפטרים','ניבוי תמותה לפי קצב העליה הנוכחי','ניבוי תמותה לפי R = 1','ניבוי תמותה לפי הנדבקים עד היום','location','northwest')
title('ניבוי תמותה לפי המשך הדבקה בשיעורים שונים')
box off
set(gca,'fontsize',13)
set(gca,'XTick',datetime(2020,3:12,1))
xtickangle(45)
xlim([datetime(2020,3,15) tests.date(end)+30]);
set(gcf,'color','w')
% saveas(figPred,'Oct1prediction.png')
%% 
crit = diff(listD.CountSeriousCriticalCum(1:end-1));
bad = find(diff(crit)>75)+1;
crit(bad) = (crit(bad-1)+crit(bad+1))/2;
prob6 = [0.0546565127716960,0.0589401872124385,0.0644930985245121,0.0672695541805489,0.0713945740123751,0.0720291924480406,0.0728224654926226,0.0711565920990005,0.0702046644455021,0.0646517531334285,0.0606853879105188,0.0574329684277328,0.0529906393780739,0.0464858004125020,0.0426780897985087,0.0369665238775186,0.0351419958749802];
predCrit = conv(crit,prob6);
predCrit = predCrit(1:end-length(prob6)+1);
predCrit(end+1:end+7) = predCrit(end)+(1:7)*mean(diff(predCrit(end-6:end)));
%%
figCrit = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
plot(listD.date,listD.CountDeath,'.b');
hold on;
hc(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
hc(2) = plot(listD.date(2:end-1)+8,movmean(crit*0.3,[3 3]),'r');
hc(3) = plot(listD.date(2):listD.date(2)+length(predCrit)-1,predCrit*0.31,'g');
legend(hc,'תמותה','הסטה','מודל')

%%
predLin1 = predLin(1:end-length(prob)+1);
figBoth = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor','b','MarkerEdgeAlpha',0.5);
hold on;
hb(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
hb(2) = plot(tests.date(1):tests.date(1)+length(predLin1)-1,predLin1/10+add,'r');
hb(3) = plot(listD.date(2):listD.date(2)+length(predCrit)-1,predCrit*0.31,'g');
legend(hb,'תמותה','ניבוי לפי מאומתים','ניבוי לפי קשים וקריטיים')
