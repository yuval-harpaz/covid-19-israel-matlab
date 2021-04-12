cd ~/covid-19-israel-matlab/data/Israel
listD = readtable('dashboard_timeseries.csv');
newc = readtable('new_critical.csv');
ward = readtable('crit_by_ward.xlsx');
col = [0,0.447,0.741;0.850,0.325,0.0980;0.929,0.694,0.125;0.494,0.184,0.556;0.466,0.674,0.188;0.301,0.745,0.933;0.635,0.0780,0.184];
death = movmean(listD.CountDeath,[3 3]);
idx = 188:height(listD);
%%
figure;
hh(1) = scatter(listD.date(idx),listD.CountBreath(idx),'.','MarkerEdgeColor',col(1,:),'MarkerEdgeAlpha',0.5);
hold on
hh(2) = plot(listD.date(idx),movmean(listD.CountBreath(idx),[3 3]),'-','Color',col(1,:),'linewidth',1.5);
hh(3) = scatter(listD.date(idx),listD.CountCriticalStatus(idx),'.','MarkerEdgeColor',col(2,:),'MarkerEdgeAlpha',0.5);
hh(4) = plot(listD.date(idx),movmean(listD.CountCriticalStatus(idx),[3 3]),'-','Color',col(2,:),'linewidth',1.5);
hh(5) = plot(ward.date,ward.corona,'--','Color',col(2,:),'linewidth',1.5);
hh(6) = plot(listD.date,death,'k');
grid on
% ylim([0 350])
legend(hh([4,5,2,6]),'all critical        סך הכל קריטיים','corona ward     מחלקת קורונה',...
    'all on vent      סך הכל מונשמים','deaths                         תמותה','location','northwest')
xlim([datetime(2020,8,15) datetime('today')])
set(gcf,'Color','w')
title({'חולים במצב קריטי','critical patients'})
ylabel('patients  חולים')
set(gca,'xtick',datetime(2020,4:30,1))
xtickformat('MMM')
ylim([0 450])