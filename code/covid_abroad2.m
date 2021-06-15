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
if sum(abroad{end,4:5}) == 0
    abroad(end,:) = [];
end
writetable(abroad,'infected_abroad.xlsx')
%%

%%
figure;
h1 = bar(abroad.date,abroad{:,4:5},'stacked');
h1(1).FaceColor = [0.847, 0.435, 0.227];
h1(2).FaceColor = [0.588, 0.247, 0.239];
xt = dateshift(datetime('today'),'start','week');
xt = fliplr(xt:-7:abroad.date(1));
title({'מאומתים לפי מקור הדבקה','cases by infection source'})
legend('local     מקומי','abroad   חו"ל')
set(gca,'XTick',xt)
grid on
xlim([abroad.date(1)-1,abroad.date(end)+1])
text(abroad.date-0.4,sum(abroad{:,4:5},2)+10,cellstr(str(abroad{:,5})),'Color','k')

%%
figure;
yy = abroad{:,5}./(abroad{:,4}+abroad{:,5})*100;
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


%%
yy = abroad{:,5}./abroad{:,6}*100;
% yys = nan(size(yy));
% idx = ~isnan(yy);
yys = movmean(yy,[3 3],'omitnan');
yys(1:find(~isnan(yy),1)) = nan;
figure;
% plot(abroad.date,yy,'.','Color',[0.85, 0.247, 0.239])
hold on
hl(1) = plot(abroad.date,yys,'Color',[0.85, 0.247, 0.239],'linewidth',1)

yy = (abroad{:,3}-abroad{:,5})./(abroad{:,2}-abroad{:,6})*100;
% yys = nan(size(yy));
% idx = ~isnan(yy);
yys = movmean(yy,[3 3],'omitnan');
yys(1:find(~isnan(yy),1)) = nan;
% plot(abroad.date,yy,'.','Color',[0.847, 0.435, 0.227],'MarkerSize',10)
hold on
hl(2) = plot(abroad.date,yys,'Color',[0.847, 0.435, 0.227],'linewidth',2);
legend(hl(2:-1:1),'local     מקומי','abroad   חו"ל')
ylim([0 1])
grid on
title('positive tests (%) בדיקות חיוביות')
set(gca,'XTick',xt)
ylabel('%')
% ylabel('%')
set(gcf,'Color','w')
xlim([abroad.date(12),abroad.date(end)+1])
%%
figure;
yyaxis left
h3 = bar(abroad.date-0.1,abroad{:,6});
ylim([0 6000])
% h3.FaceColor = [0.847, 0.435, 0.227];
yyaxis right
h4 = bar(abroad.date+0.1,abroad{:,5});
ylim([0 60])

title({'בדיקות ותוצאות חיוביות לבאים מחו"ל','tests and cases for incoming passengers'})
legend('tests     בדיקות','positive   חיוביים','location','northwest')
set(gca,'XTick',xt)
grid on
xlim([abroad.date(1)-1,abroad.date(end)+1])
set(gcf,'Color','w')

RR = (sum(abroad.local(end-7:end-1))/sum(abroad.local(end-14:end-8)))^0.65;