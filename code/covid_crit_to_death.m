!wget --no-check-certificate -O ~/covid-19-israel-matlab/data/Israel/delta.csv 'https://docs.google.com/spreadsheets/d/1kiOrQxOtBg0__IoLkEZgqhMDpIQCXbBxEE78BwqcOs4/export?gid=472501586&format=csv'
delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);
deaths = [delta.deathsVacc60_, delta.deaths60_-delta.deathsVacc60_];
severe = [delta.severeVacc60_, delta.severe60_-delta.severeVacc60_];
tit = {'Vaccinated','Unvaccinated'};
sevuv = movmean(severe(:,2)*0.47,[6 0]);
sevuv = sevuv(1:end-7);
detuv = movmean(deaths(:,2),[6 0]);
detuv = detuv(8:end);
% err = abs(sevuv-detuv);
% err = err(12:end);
% err = fliplr(err(end:-7:1));
err = abs(detuv-sevuv)./sevuv;
err = err(12:end);
err(isnan(err)) = 1;
err = fliplr(err(end:-7:1));

idx = 1:length(detuv);
idx = idx(12:end);
idx = fliplr(idx(end:-7:1));
sd = std(err);
%%
t1 = delta.date-3;
t2 = delta.date+7-3;
t3 = delta.date(idx)+7-3;

figure;
for sp = 1:2
    subplot(2,1,sp)
    plot(1:length(t1),movmean(deaths(:,sp),[6 0]),'k')
    hold on
    sv = movmean(severe(:,sp)*0.47,[6 0]);
    plot(8:length(t1)+7,sv,'r')
    if sp == 1
        mx = ceil(max(sv)/10)*10;
        errorbar(idx+7,sv(idx), repmat(sd*5,length(idx),1),repmat(sd*5,length(idx),1),...
            'LineStyle','none','LineWidth',2)
    end
    title(tit{sp})
    ylim([0 mx])
    if sp == 1
        legend('deaths 60+','predictor (severe 60+)','5 SD','location','northwest')
    end
    grid on
    box off
    ylabel('deaths')
    set(gca,'FontSize',13,'XTick',idx+7,'XTickLabel',datestr(delta.date(idx)+7,'dd/mm'))
    xtickangle(90)
    xlim([idx(1) idx(end)+14])
end
set(gcf,'Color','w')