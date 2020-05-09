cd ~/covid-19_data_analysis/
vent = readtable('data/Israel/Israel_ventilators.csv');

%t0 = [14,24,height(vent)-10,height(vent)-5];
t0 = [14,height(vent)-5];
for ii = 1:length(t0)
    a(ii,1) = mean(diff(vent.vent_used(t0(ii):end)));
    b(ii,1) = vent.vent_used(t0(ii))-(a(ii)*t0(ii));
end

maxX = max(ceil((5000-b)./a));
%maxX = ceil((5000)/a)+1;
pred = nan(maxX,length(t0));
for ii = 1:length(t0)
    pred(t0(ii):maxX,ii) = (a(ii).*(t0(ii):maxX)+b(ii))';
end


timeVec = vent.date(1);
timeVec = timeVec:timeVec+maxX-1;

xl = [length(vent.vent_used)+10,length(pred)]; % xlim
yt = [1437,5000]';
xt = nan(length(yt),length(t0));
for ii = 1:length(yt)
    for jj = 1:length(t0)
        xt(ii,jj) = find(pred(:,jj) > yt(ii),1);
    end
end
daysLeft = minmax(xt(1,:)-length(vent.vent_used));
%%
fig7 = figure('units','normalized','position',[0,0,1,0.5]);
for iPlot = 1:2
    subplot(1,2,iPlot)
    h1 = plot(timeVec(1:length(vent.vent_used)),vent{:,2},'linewidth',2);
    hold on;
    h2 = plot(timeVec,pred,'k--');
    xlim([timeVec(1),timeVec(xl(iPlot))])
    if iPlot == 1
        % legend([h1,h2(1)],'חולים מונשמים','קווי ניבוי לשימוש במכונות הנשמה','location','northwest');
        set(gca,'XTick',[timeVec(1),timeVec(t0),timeVec(length(vent.vent_used))],'FontSize',13)
        ylim([0 max(pred(xl(iPlot),:))])
        title('ניבוי השימוש במכונות הנשמה')
    else
        h3 = plot(timeVec(xt(1,:)),yt(1,:),'*r');
        h4 = plot(timeVec(xt(2,:)),yt(2,:),'*b');
        set(gca,'XTick',unique(timeVec(xt)),'YTick',unique(yt),'FontSize',13)
        xtickangle(40)
        title(['מצוקה צפויה במכונות הנשמה עוד ',str(daysLeft(1)),' - ',str(daysLeft(2)),' יום'])
        ylim([0 5010])
        legend([h1,h2(1),h3(1),h4(1)],...
            'חולים מונשמים','קווי ניבוי לשימוש במכונות הנשמה',...
            'כל 1437 מכונות ההנשמה בשימוש','5000 מכונות הנשמה בשימוש','location','northwest');
    end
    ylabel('מכונות בשימוש')
    box off
    grid on
end
%% 
saveas(fig7,['archive/myCountryVents_',datestr(datetime('today'),'dd_mm_yyyy'),'.png'])
saveas(fig7,'docs/myCountryVents.png')