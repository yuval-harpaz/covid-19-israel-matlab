vent = readtable('Israel_ventilators.csv');

t0 = 24;
a = mean(diff(vent.vent_used(t0:end)));
b = vent.vent_used(t0)-(a*t0);

maxX = ceil((5000-b)/a);
%maxX = ceil((5000)/a)+1;
pred = nan(maxX,1);
pred(t0:maxX) = a*(t0:maxX)+b;


timeVec = datetime(vent.date(1));
timeVec = timeVec:timeVec+maxX-1;

xl = [length(vent.vent_used)+10,length(pred)];
yt = [1000,1437,2000:1000:5000]';
xt = nan(size(yt));
for ii = 1:length(yt)
    xt(ii,1) = find(pred > yt(ii),1);
end
daysLeft = xt(2)-length(vent.vent_used);
%%
figure;
for iPlot = 1:2
    subplot(1,2,iPlot)
    plot(timeVec(1:length(vent.vent_used)),fliplr(vent{:,2:3}),'linewidth',2);
    hold on;
    plot(timeVec,pred,'k--')
    xlim([timeVec(1),timeVec(xl(iPlot))])
    if iPlot == 1
        legend('חולים מונשמים','מתים',['כל יום נוספות ',...
            str(round(a,1)),' מכונות חדשות לשימוש'],'location','northwest');
        set(gca,'XTick',[timeVec(1),timeVec(t0),timeVec(length(vent.vent_used))])
        title('ניבוי השימוש במכונות הנשמה')
    else
        plot(timeVec(xt(2)),yt(2),'*r')
        plot(timeVec(xt(end)),yt(end),'*r')
        set(gca,'XTick',timeVec(xt),'YTick',yt)
        xtickangle(40)
        title(['מצוקה צפויה במכונות הנשמה עוד ',str(daysLeft),' יום'])
        ylim([0 5010])
    end
    ylabel('מכונות בשימוש')
    box off
    grid on
end