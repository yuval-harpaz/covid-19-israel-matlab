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
legend(h([2,3,5]),'נפטרים','צפי תמותה לפי קשים + קריטיים חדשים','קשים + קריטיים חדשים','location','northwest')
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
commonDate = listD.date(ismember(listD.date,newc.date));
crit = critDiff(ismember(listD.date(2:end),commonDate))-newc.new_critical(ismember(newc.date,commonDate));
figure;
plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b')
hold on
plot(listD.date(2:end-1)+7,movmean(critDiff(1:end-1)*0.3,[3 3]),'r')
% plot(newc.date+9,movmean(newc.new_critical,[3 3])*0.35,'g')
% plot(commonDate(175:end)+6,movmean(crit(175:end)*1.5,[3 3]),'k')

%%
figure;
hcc(1) = scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor',col(1,:),'MarkerEdgeAlpha',0.5);
hold on
hcc(2) = plot(listD.date,death,'-','Color',col(1,:),'linewidth',1.5);
ylabel('נפטרים')
hcc(3) = scatter(listD.date(2:end)+7,critDiff*0.3,'.','MarkerEdgeColor',col(2,:),'MarkerEdgeAlpha',0.5);
hold on
hcc(4) = plot(listD.date(2:end-1)+7,movmean(critDiff(1:end-1),[3 3])*0.3,'-','Color',col(2,:),'linewidth',1.5);
grid on
legend(hcc([2,4]),'נפטרים','צפי תמותה לפי קשים + קריטיים חדשים','location','northwest')
set(gcf,'Color','w')
title('ניבוי תמותה שבוע קדימה לפי חולים חדשים במצב קשה וקריטי')