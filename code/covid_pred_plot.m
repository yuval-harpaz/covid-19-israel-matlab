cd ~/covid-19-israel-matlab/data/Israel
if ~exist('symp','var')
    load symp t
end  
listD = readtable('dashboard_timeseries.csv');
newc = readtable('new_critical.csv');
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = jsondecode(json);
death = json.result.records;
death = struct2table(death);
pos2death = cellfun(@str2num,strrep(death.Time_between_positive_and_death,'NULL','0'));
bad = pos2death < 1 | ismember(death.gender,'לא ידוע');
male = ismember(death.gender(~bad),'זכר');
pos2death = pos2death(~bad);
old = ~ismember(death.age_group,'<65');
prob = movmean(hist(pos2death,1:1000),[3 3]);
iEnd = find(prob < 0.5,1);
prob = prob(1:iEnd-1);
prob = prob/sum(prob);


% predict deaths by infected
ratio60 = mean((t.pos_f_60(end-3:end)+t.pos_m_60(end-3:end))./(t.pos_f(end-3:end)+t.pos_m(end-3:end)));
missingDates = find(ismember(listD.date,t.date),1,'last')+1;
missingDates = missingDates:height(listD)-1;
missing60 = listD.tests_positive(missingDates)*ratio60;
predInfected = conv(movmean([t.pos_m_60+t.pos_f_60;missing60],[3 3]),prob);
% predict deaths by critical
% probCrit = prob(11:end);
% probCrit = probCrit/sum(probCrit);
% predCrit = conv(newc.new_critical,probCrit);
%probCrit = [0,0,0,1,0,0,0];
probCrit = normpdf(-2:20,1,3);
probCrit = probCrit/sum(probCrit);
predCrit = movmean(conv(movmean(newc.new_critical,[3 3]),probCrit),[3 3]);
% predCritTot = conv(movmean(listD.CountHardStatus(1:end-1),[3 3]),[0,0,0,1]);
%%

open pred1.fig
hp = findobj(gca,'Type','line');
y1oct = hp(2).YData';
x1oct = hp(2).XData';
x = movmean(t.pos_m_60+t.pos_f_60,[3 3]);
x = [x;(x(end)-85/3:-85/3:0)';0];
predBest =  conv(x,prob);
clear h
figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
plot(listD.date,listD.CountDeath,'.b');
hold on;
h(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
h(2) = plot(x1oct(204:end),y1oct(204:end),'r--','linewidth',2);
h(3) = plot(t.date(1):t.date(1)+length(predBest)-1,predBest/20,'k','linewidth',1);
grid on
grid minor
ylabel('נפטרים')
legend(h,'נפטרים','ניבוי תמותה מה- 1 לאוק''','ניבוי תמותה מתעדכן','location','northwest')
title('ניבוי תמותה לפי ירידה בתחלואה בשיעור דומה לגל הראשון')
set(gca,'fontsize',13)
box off

% h(2) = plot(listD.date(end),listD.CountDeath(end),'*b','linewidth',2);
% h(3) = plot(newc.date(1):(newc.date(1)+length(predCrit))-1,predCrit*0.3,'r-.');
% h(4) = plot(newc.date(end),predCrit(height(newc))*0.3,'*r','linewidth',2);
% h(3) = plot(t.date(1):(t.date(1)+length(predInfected))-1,predInfected*0.05,'k');


% h(6) = plot(t.date(end),predInfected(height(t))*0.05,'*k','linewidth',2);
% plot(listD.date(1):(listD.date(1)+length(predCritTot)-1),predCritTot*0.035,'g','linewidth',1);
% xlim([datetime(2020,7,1) datetime(2020,12,31)])




% legend(h,'נפטרים','נפטרים היום','ניבוי לפי חולים קשים חדשים','נתוני חולים קשים קיימים עד יום זה','ניבוי לפי נדבקים מעל גיל 60','נתוני נידבקים לפי גיל קיימים עד יום זה')
%%

% figure;
% h(1) = plot(listD.date,listD.CountDeath,'.b');
% hold on;
% h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
% h(3) = plot(newc.date+4,movmean(newc.new_critical*0.3,[3 3]),'r');
% h(4) = plot(listD.date,movmean(listD.CountHardStatus*0.035,[3 3]),'k');
% grid on
% box off
% ylabel('daily deaths')
% legend(h(2:4),'deaths','new critical x 0.3, 4 days before','total critical x 0.035, the same day')
% 
% %% pos > 60
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% % pos2death65 = cellfun(@str2num,strrep(t.Time_between_positive_and_death,'NULL','0'));
% % pos2death65 = pos2death65(~bad & old);
% % prob65 = movmean(hist(pos2death,1:1000),[3 3]);
% % iEnd = find(prob65 < 0.5,1);
% % prob65 = prob65(1:iEnd-1);
% % prob65 = prob65/sum(prob65);
% % figure;
% % plot([prob;prob65]')
% trend = movmean(t.pos_m_60(end-17:end-4)+t.pos_f_60(end-17:end-4),[3 3]);
% b = regressBasic((1:14)',trend);
% next2w = [ones(14,1),(15:28)']*b;
% predLin =  conv([movmean(t.pos_m_60+t.pos_f_60,[3 3]);next2w],prob);
% lag = 12;
% fac = 20;
% pred = conv(movmean(t.pos_m_60+t.pos_f_60,[3 3]),prob);
% ratio60 = mean((t.pos_f_60(end-3:end)+t.pos_m_60(end-3:end))./(t.pos_f(end-3:end)+t.pos_m(end-3:end)));
% missingDates = find(ismember(listD.date,t.date),1,'last')+1;
% missingDates = missingDates:height(listD)-1;
% missing60 = listD.tests_positive(missingDates)*ratio60;
% pred = conv(movmean([t.pos_m_60+t.pos_f_60;missing60],[3 3]),prob);
% 
% figure;
% h(1) = plot(listD.date(1:end-1),listD.CountDeath(1:end-1),'.b');
% hold on;
% h(2) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
% h(3) = plot(t.date+lag,movmean(t.pos_m_60+t.pos_f_60,[3 3])/20,'k--');
% h(4) = plot(t.date(2):t.date(1)+length(pred),pred/20,'r--');
% h(5) = plot(t.date(2):t.date(1)+length(predLin),predLin/20,'r-.');
% h(6) = plot(t.date(1:end-lag)+lag,movmean(t.pos_m_60(1:end-lag)+t.pos_f_60(1:end-lag),[3 3])/20,'k','linewidth',2);
% h(7) = plot(t.date(2:end),pred(1:end-length(prob)-length(missing60))/20,'r','linewidth',1);
% legend(h([2,3,4,5]),'נפטרים',...
%     ['12 יום קודם: ',str(fac),'/','(חיוביים מעל גיל 60)'],...
%     'מודל (מחר יש 0 חיוביים)','מודל (ממשיכים שבועיים באותו הקצב)','location','west')
% box off
% grid on
% title('ניבוי תמותה לפי מספר הנבדקים החיוביים מעל גיל 60')
% ylabel('נפטרים ליום')
% set(gcf,'Color','w')
% set(gca,'FontSize',12)
% 
% nWeeks = 2;
% next2w = [ones(nWeeks*7,1),(15:(14+nWeeks*7))']*b;
% next2w = [next2w;(next2w(end)-85/6:-85/6:0)';0];
% predLin =  conv([movmean(t.pos_m_60+t.pos_f_60,[3 3]);next2w],prob);
% x = movmean(t.pos_m_60+t.pos_f_60,[3 3]);
% x = [x;(x(end)-85/3:-85/3:0)';0];
% predBest =  conv(x,prob);
% %% final plot
% figure;
% h(1) = plot(listD.date(1:end-1),listD.CountDeath(1:end-1),'.b');
% hold on;
% h(2) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
% % h(4) = plot(t.date(2):t.date(1)+length(pred),pred/20,'r--');
% h(5) = plot(t.date(2):t.date(1)+length(predBest),predBest/20,'r--','linewidth',2);
% xLin = t.date(2):t.date(1)+length(predLin);
% h(6) = plot(xLin,predLin/20,'r:','linewidth',2);
% h(7) = plot(t.date(2:end),pred(1:end-length(prob)-length(missing60))/20,'r','linewidth',1);
% i1 = height(t)+length(missing60);
% xx = [xLin(i1:end),fliplr(xLin(i1:end))]';
% yy = predLin(i1:end)/20;
% yy2 = predBest(i1:end)/20;
% yy2(end+1:length(yy)) = 0;
% yy = [yy;flipud(yy2)];
% fill(xx,yy,[0.8,0.8,0.8],'linestyle','none')
% legend(h([2,6,5]),'נפטרים','בעוד שבועיים מתחילה ירידה מתונה','מחר מתחילה ירידה בקצב גבוה',...
%    'location','west')
% box off
% grid on
% title('ניבוי תמותה לפי מספר הנבדקים החיוביים מעל גיל 60')
% ylabel('נפטרים ליום')
% set(gcf,'Color','w')
% set(gca,'FontSize',12)
% text(xx(45),20,str(round(sum(yy(1:length(xx)/2))-sum(yy(length(xx)/2+1:end)))))
