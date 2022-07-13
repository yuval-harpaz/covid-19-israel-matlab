listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
death = listD.CountDeath;
death(isnan(death)) = 0;
deathCum = cumsum(death);
deathSm = movmean(death,[3 3]);

deathPred = deathSm;
for ii = 733:803
    deathPred(ii) = deathPred(ii-1)*(1.6^(1/7))^-1;
end
deathPredCum = cumsum(deathPred);
dp = listD.date(1);
dp = dp:dp+length(deathPredCum)-1;

wi = [34;128;290;507;681;842;height(listD)+1];
wx = [67;240;349;568;757;870];
for iw = 1:length(wx)
    wd(iw,1) = sum(listD.CountDeath(wi(iw):wi(iw+1)-1));
end
%%
figure;
yyaxis left;
hh(1) = plot(listD.date,deathSm);
hold on
% plot(dp(730:end),deathPred(730:end))
ylabel('deaths')
yyaxis right
hh(2) = plot(listD.date,deathCum);
hold on
% plot(dp(730:end),deathPredCum(730:end));
ylabel('cumulative deaths')
ylim([0 14000])
grid on
for iw = 1:length(wx)
    text(listD.date(wx(iw)),400,str(wd(iw)),'FontSize',12,'HorizontalAlignment','Center');
end
set(gca,'XTick',datetime(2020,3:50,1),'FontSize',13)
xtickangle(90)
xtickformat('MMM-yy')
xlim([dp(1) dp(end)+5])

idx = wi(2:end)-1;
plot(listD.date(idx),deathCum(idx),'.','MarkerSize',15)
% plot(dp(end),deathPredCum(end),'.','MarkerSize',15)
for iw = 1:length(wx)
    text(listD.date(idx(iw))-7,deathCum(idx(iw))+300,str(deathCum(idx(iw))),'FontSize',12,'HorizontalAlignment','Right','Color',hh(2).Color);
end
% text(dp(end)-7,deathPredCum(end)+550,str(round(deathPredCum(end))),'FontSize',12,'HorizontalAlignment','Right','Color',hh(2).Color);
legend(hh,'deaths                                 תמותה','cumulative deaths  תמותה מצטברת','location','northwest')
title({'deaths by wave      תמותה לפי גל'})
set(gcf,'Color','w')