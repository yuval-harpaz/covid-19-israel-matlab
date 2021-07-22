listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');

recov = listD.CountHardStatus(1:end-1)-...
    (listD.CountHardStatus(2:end)-listD.serious_critical_new(2:end))-listD.CountDeath(2:end);
figure; plot(listD.date,movmean([listD.serious_critical_new],[3 3]))
hold on
plot(listD.date(2:end),movmean(recov,[3 3]))
plot(listD.date,movmean(listD.CountDeath,[3 3]),'k')
legend('severe','recovered','deceased')
set(gca,'xtick',datetime(2020,4:30,1))
xtickangle(30)
grid on
xlim([datetime(2020,3,1),datetime('tomorrow')])
title('New severe, recovered (from severe) and deaths')

outcome = recov+listD.CountDeath(2:end);

outsm = movmean(movmean(outcome,[3 3]),[3 3]);
sevsm = movmean(movmean(listD.serious_critical_new(2:end),[3 3]),[3 3]);
%%
days = nan(length(recov),1);
for ii = 6:length(recov)
    if sevsm(ii)-sevsm(ii-5) > 2
        d = find(outsm(ii:end) > 0.9*sevsm(ii),1);
        if ~isempty(d)
            days(ii,1) = d;
        end
    end
end
days(days > 50) = nan;
days(days == 1) = nan;

figure;
yyaxis left
plot(listD.date,movmean([listD.serious_critical_new],[3 3]))
hold on
plot(listD.date(2:end),movmean(outcome,[3 3]))
ylabel('patients')
yyaxis right
plot(listD.date(2:end),movmedian(days,[1 1],'omitnan'))
ylabel('days to outcome')
ylim([0 11])