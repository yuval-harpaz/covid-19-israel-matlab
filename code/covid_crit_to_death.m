!wget --no-check-certificate -O ~/covid-19-israel-matlab/data/Israel/delta.csv 'https://docs.google.com/spreadsheets/d/1kiOrQxOtBg0__IoLkEZgqhMDpIQCXbBxEE78BwqcOs4/export?gid=472501586&format=csv'
delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);
deaths = [delta.deathsVacc60_, delta.deaths60_-delta.deathsVacc60_];
severe = [delta.severeVacc60_, delta.severe60_-delta.severeVacc60_];
tit = {'Vaccinated','Unvaccinated'};
figure;
for sp = 1:2
    subplot(2,1,sp)
    plot(delta.date-3,movmean(deaths(:,sp),[6 0]),'k')
    hold on
    plot(delta.date+7-3,movmean(severe(:,sp)*0.47,[6 0]),'r')
    title(tit{sp})
    if sp == 1
        legend('deaths 60+','predictor (severe 60+)','location','northwest')
    end
    grid on
    box off
    ylabel('deaths')
    set(gca,'FontSize',13)
end
set(gcf,'Color','w')