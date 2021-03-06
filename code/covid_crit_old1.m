cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
ncba = readtable('crit_by_age.csv');
col = [0,0.447,0.741;0.850,0.325,0.0980;0.929,0.694,0.125;0.494,0.184,0.556;0.466,0.674,0.188;0.301,0.745,0.933;0.635,0.0780,0.184];
col3 = [0.906 0.329 0.357;0.271 0.478 0.647;0.439 0.718 0.698];
%%
figure('units','normalized','position',[0.1,0.1,0.4,0.8]);
subplot(2,1,1)
h1 = plot(ncba.date,ncba{:,2:4});
for ii = 1:3
    h1(ii).Color = col3(ii,:);
end
legend('60+','40-60','<40','location','northwest');
grid on
% xtickformat('MMM')
title(['new severe patients by age    ','חולים קשים חדשים לפי גיל'])
set(gca,'xtick',datetime('today')-7^3:7:datetime('today'))
xtickformat('dd/MM')
xlim([ncba.date(1)-1 ncba.date(end)+1])
subplot(2,1,2)
yy = ncba{:,2:4}./sum(ncba{:,2:4},2)*100;
h2 = plot(ncba.date,yy,'.');
hold on
h3 = plot(ncba.date,movmean(yy,[3 3]));
for ii = 1:3
    h2(ii).Color = col3(ii,:);
    h3(ii).Color = col3(ii,:);
end
% legend('60+','40-60','<40','location','northwest');
grid on
% xtickformat('MMM')
title(['new severe patients by age  (%)  ','חולים קשים חדשים לפי גיל '])
set(gcf,'Color','w')
set(gca,'xtick',datetime('today')-7^3:7:datetime('today'))
xtickformat('dd/MM')
xlim([ncba.date(1)-1 ncba.date(end)+1])
%% 
figure;
hcc(1) = scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor',[0,0,0],'MarkerEdgeAlpha',0.5);
hold on
hcc(2) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'-','Color',[0,0,0],'linewidth',1.5);
ylabel('נפטרים')
% hcc(3) = scatter(listD.date(2:end)+7,critDiff*0.3,'.','MarkerEdgeColor',col(2,:),'MarkerEdgeAlpha',0.5);
% hold on
% hcc(3) = plot(listD.date(1:end-1)+7,movmean(listD.serious_critical_new(1:end-1),[3 3])*0.3,'-','Color',col(2,:),'linewidth',1);
hcc(3) = plot(ncba.date+7,movmean(ncba.over60,[3 3])*0.47,'-','Color',col3(1,:),'linewidth',1.5);
grid on
legend(hcc([2:3]),['נפטרים',' deceased'],['צפי לפי ','prediction by >60'],'location','northwest')
set(gcf,'Color','w')
title({'ניבוי תמותה שבוע קדימה לפי חולים חדשים במצב קשה וקריטי בני 60+','A week ahead death prediction by new critical patients 60+y/o'})
xtickformat('MMM')
xlim([datetime(2020,7,1) datetime('today')+7])

