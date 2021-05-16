cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
abroad = readtable('infected_abroad.xlsx');
listD = listD(find(ismember(listD.date,abroad.date),1):end,:);
extra = height(listD)-height(abroad);
if extra > 0
    row = height(abroad)+1:height(abroad)+extra;
    abroad.date(end+1:end+extra) = listD.date(row);
end
abroad.tests = listD.tests;
abroad.positive = listD.tests_positive;
writetable(abroad,'infected_abroad.xlsx')
%%
figure;
subplot(2,1,1)
h1 = bar(abroad.date,abroad{:,4:5},'stacked');
h1(1).FaceColor = [0.847, 0.435, 0.227];
h1(2).FaceColor = [0.588, 0.247, 0.239];
xt = dateshift(datetime('today'),'start','week');
xt = fliplr(xt:-7:abroad.date(1));
title({'מאומתים לפי מקור הדבקה','cases by infection source'})
legend('local     מקומי','abroad   חו"ל')
set(gca,'XTick',xt)
grid on
xlim(abroad.date([1,end]))
subplot(2,1,2)
yy = abroad{:,5}./abroad{:,4}*100;
yys = nan(size(yy));
idx = ~isnan(yy);
yys(idx) = movmean(yy(idx),[3 3]);
plot(abroad.date,yy,'.b')
hold on
plot(abroad.date,yys,'b')
set(gca,'XTick',xt)
title('infected abroad (%) נדבקו בחו"ל')
set(gca,'XTick',xt)
grid on
box off
ylabel('%')
set(gcf,'Color','w')
xlim(abroad.date([1,end]))
