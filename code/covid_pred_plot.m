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
ylabel('נפטרים ליום')
legend(h,'נפטרים','ניבוי תמותה מה- 1 לאוק''','ניבוי תמותה מתעדכן','location','northwest')
title('ניבוי תמותה לפי ירידה בתחלואה בשיעור דומה לגל הראשון')
box off
set(gca,'fontsize',13)
set(gca,'XTick',datetime(2020,3:12,1))
xtickangle(45)
set(gcf,'color','w')

%%
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
plot(cumsum(predBest/20),'b')
ax = gca;
ax.YRuler.Exponent = 0;
open pred1.fig
ylim([0 2500])
box off
grid on
title('death prediction (cumulative)')
ylabel('deaths (total)')