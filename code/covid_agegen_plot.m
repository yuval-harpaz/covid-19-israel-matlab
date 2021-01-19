function covid_agegen_plot

cd ~/covid-19-israel-matlab/data/Israel
agegen = readtable('dashboard_age_gen.csv');
col = [0.259 0.525 0.961;0.063 0.616 0.345;0.961 0.706 0.4;0.988 0.431 0.016;0.863 0.267 0.216];
tit = {'מאומתים','קשים','מונשמים','נפטרים'};
figure;
for iSec = 1:4
    prevCol = iSec*20-20;
    y = [sum(agegen{:,prevCol+(2:5)},2),sum(agegen{:,prevCol+(6:9)},2),sum(agegen{:,prevCol+(10:13)},2),sum(agegen{:,prevCol+(14:17)},2),sum(agegen{:,prevCol+(18:21)},2)];
    if iSec == 2 || iSec == 3
        yd = y(2:end,:);
    else
        yd = diff(y);
    end
    yds = movmean(movmedian(yd,[3 3]),[3 3]);
    ydsp = yds./sum(yds,2)*100;
    sm = sum(cumsum(yd),2);
    sm = sm/max(sm)*100;
    subplot(2,2,iSec)
    hb = bar(agegen.date(2:end),ydsp,20,'stacked','EdgeColor','none');
    for ih = 1:5
        hb(ih).FaceColor = col(ih,:);
    end
    grid on
    xtickformat('MMM')
    ylim([0 100])
    hold on
    hl = plot(agegen.date(2:end),sm,'k')
    title(tit{iSec})
    if iSec == 1
        legend([fliplr(hb),hl],'80+','60-80','40-60','20-40','0-20','סה"כ (מנורמל)');
    end
    
end
set(gcf,'Color','w')