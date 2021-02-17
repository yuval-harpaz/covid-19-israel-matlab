cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
ncba = readtable('crit_by_age.csv');
col = [0,0.447,0.741;0.850,0.325,0.0980;0.929,0.694,0.125;0.494,0.184,0.556;0.466,0.674,0.188;0.301,0.745,0.933;0.635,0.0780,0.184];


figure;
hcc(1) = scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor',col(1,:),'MarkerEdgeAlpha',0.5);
hold on
hcc(2) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'-','Color',col(1,:),'linewidth',1.5);
ylabel('נפטרים')
% hcc(3) = scatter(listD.date(2:end)+7,critDiff*0.3,'.','MarkerEdgeColor',col(2,:),'MarkerEdgeAlpha',0.5);
% hold on
hcc(3) = plot(listD.date(1:end-1)+7,movmean(listD.serious_critical_new(1:end-1),[3 3])*0.3,'-','Color',col(2,:),'linewidth',1);
hcc(4) = plot(ncba.date+7,movmean(ncba.over60,[3 3])*0.47,'-','Color',col(3,:),'linewidth',1.5);
grid on
legend(hcc([2:4]),'נפטרים','צפי תמותה לפי קשים חדשים','צפי תמותה לפי קשים חדשים מעל 60','location','northwest')
set(gcf,'Color','w')
title('ניבוי תמותה שבוע קדימה לפי חולים חדשים במצב קשה וקריטי')
xtickformat('MMM')
xlim([datetime(2020,7,1) datetime('today')+7])