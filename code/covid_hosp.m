% called from covid_Israel
if newFig
    if exist('fig9','var')
        fig10 = figure('units','normalized','position',[0,0,1,1]);
    else
        fig9 = figure('units','normalized','position',[0,0,1,1]);
    end
else
    subplot(1,2,1)
end
hh(9) = scatter(list.date(list.CountDeath > 0),list.CountDeath(list.CountDeath > 0),'k.','MarkerEdgeAlpha',alf);
hold on
hh(10) = plot(list.date(1:end-1),movmean(list.CountDeath(1:end-1),[3 3]),'k','linewidth',1.5);
hh(1) = scatter(list.date(2:end),diff(list.CountBreathCum(1:end)),'.','MarkerEdgeAlpha',alf);
hh(1).MarkerEdgeColor = ccc(1,:);
hh(2) = plot(list.date(2:end-1),movmean(diff(list.CountBreathCum(1:end-1)),[3 3]),'linewidth',1.5);
hh(2).Color = ccc(1,:);
commonDate = datetime(2020,8,18):newc.date(end);
crit = list.serious_critical_new(2:end) - diff(list.CountSeriousCriticalCum);
hh(3) = scatter(list.date(2:end),crit,'.','MarkerEdgeAlpha',alf);
hh(3).MarkerEdgeColor = ccc(2,:);
crit = movmean(crit,[3 3]);
hh(4) = plot(list.date(2:end),crit,'linewidth',1.5);
hh(4).Color = ccc(2,:);
hh(5) = scatter(list.date,list.serious_critical_new,'.','MarkerEdgeAlpha',alf);
hh(5).MarkerEdgeColor = ccc(3,:);
severe = movmean(list.serious_critical_new(1:end),[3 3]);
hh(6) = plot(list.date(1:end),severe,'linewidth',1.5);
hh(6).Color = ccc(3,:);
hh(7) = scatter(list.date,list.new_hospitalized,'.','MarkerEdgeAlpha',alf);
hh(7).MarkerEdgeColor = ccc(4,:);
hh(8) = plot(list.date(1:end-1),movmean(list.new_hospitalized(1:end-1),[3 3]),'linewidth',1.5);
hh(8).Color = ccc(4,:);
dates = [dateSeger;list.date(end)];
iDates = find(ismember(list.date,dates));
critSeger = round(crit(iDates-1));
severeSeger = round(severe(iDates));
% text(dates,critSeger,str(critSeger),'Color',[0,0,0],'FontWeight','Bold')

title('New Patients    חולים חדשים')
legend(hh([8,6,4,2,10]),'hospitalized מאושפזים','severe                קשה','critical               קריטי',...
    'on vent          מונשמים','deceased        נפטרים','location','northwest')
% end  
grid on
box off
set(gcf,'Color','w')
grid minor
set(gca,'fontsize',13,'XTick',datetime(2020,3:50,1))

xlim([list.date(1) datetime('tomorrow')])
xtickformat('MMM')
if isLog
    set(gca, 'YScale', 'log')
    ylim([2 300])
else
    ylim([0 300])
    text(dates,critSeger-[2,7,7,7]',str(critSeger),'Color',ccc(2,:))
    text(dates,severeSeger-7,str(severeSeger),'Color',ccc(3,:))
end
if newFig
    figure('units','normalized','position',[0,0,1,1]);
else
    subplot(1,2,2)
end
hh1(1) = scatter(listE.date,listE.CountBreath,'.','MarkerEdgeAlpha',alf);
hold on
hh1(2) = plot(listE.date(1:end-1),movmean(listE.CountBreath(1:end-1),[3 3]),'linewidth',1.5);
hh1(2).Color = ccc(1,:);
listE.CountCriticalStatus(1:find(listE.CountCriticalStatus > 10,1)-1) = nan;
hh1(3) = scatter(listE.date,listE.CountCriticalStatus,'.','MarkerEdgeAlpha',alf);
hh1(3).MarkerEdgeColor = ccc(2,:);
hh1(4) = plot(listE.date(1:end-1),movmean(listE.CountCriticalStatus(1:end-1),[3 3]),'linewidth',1.5);
hh1(4).Color = ccc(2,:);
hh1(5) = scatter(listE.date,listE.CountHardStatus,'.','MarkerEdgeAlpha',alf);
hh1(5).MarkerEdgeColor = ccc(3,:);
hh1(6) = plot(listE.date(1:end-1),movmean(listE.CountHardStatus(1:end-1),[3 3]),'linewidth',1.5);
hh1(6).Color = ccc(3,:);
hh1(7) = scatter(listE.date,listE.CountHospitalized,'.','MarkerEdgeAlpha',alf);
hh1(7).MarkerEdgeColor = ccc(4,:);
hh1(8) = plot(listE.date(1:end-1),movmean(listE.CountHospitalized(1:end-1),[3 3]),'linewidth',1.5);
hh1(8).Color = ccc(4,:);
critSeger = listE.CountCriticalStatus(iDates);
severeSeger = listE.CountHardStatus(iDates);
% text(dates,critSeger,str(critSeger),'Color',[0,0,0],'FontWeight','Bold')

title('Patients    חולים')
legend(hh1([8,6,4,2]),'hospitalized מאושפזים','severe                קשה','critical               קריטי',...
    'on vent          מונשמים','location','northwest')
% end  
grid on
box off
set(gcf,'Color','w')
set(gca,'fontsize',13)

grid minor

xlim([listE.date(1) datetime('tomorrow')])
xtickformat('MMM')
set(gca,'fontsize',13,'XTick',datetime(2020,3:50,1))
if isLog
    set(gca, 'YScale', 'log')
    ylim([10 2600])
else
    ylim([0 2600])
    text(dates,critSeger-7,str(critSeger),'Color',ccc(2,:))
    text(dates,severeSeger-7,str(severeSeger),'Color',ccc(3,:))
end
