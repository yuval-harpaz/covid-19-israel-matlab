tt = readtable('~/Downloads/chains_report_2021-08-24.xlsx');
sector = tt{2:end,3:5};
sectorW = sector./sum(sector,2);
oneSec = sectorW == 1;
oneSecRatio = sum(sectorW > 0 & oneSec)./sum(sectorW > 0);
figure;
bar(oneSecRatio)
set(gca,'XTickLabel',{'Arab','Haredi','general'},'YTick',0:0.1:1,...
    'YTickLabel',0:10:100,'FontSize',13,'ygrid','on')
rt = str(round(oneSecRatio'*100));
rt(:,end+1) = '%';
text((1:3)-0.1,[0.15 0.15 0.15],rt,'FontSize',13,'Color','w')
title({'שיעור ההדבקות בתוך מגזר','Ratio of within sector chains'})
sz = [4:50];
bigRat = [];
for ii = 1:3
    tmp = tt{2:end,2}(sectorW(:,ii) > 0.9);
    secMean(ii,1) = mean(tmp);
    secMed(ii,1) = median(tmp);
    secSD(ii,1) = std(tmp);
    n(ii,1) = length(tmp);
    bigRat(ii,1:length(sz)) = mean(tmp > sz);
end
figure;
plot(sz,100*bigRat)
grid on
ylabel('ratio of chains > x    (%)')
title({'הסיכוי ששרשרת הדבקה תהיה גבוהה מ X, לפי מגזר','Chances for infection chain to be larger than X, by sector'})
legend('Arab','Haredi','general')
xlabel('chain size  גודל שרשרת')

figure;
bar(secMean)
hold on
plot(secMed,'o','MarkerFaceColor','r','MarkerEdgeColor','none')
errorbar(1:3,secMean,secSD./sqrt(n),secSD./sqrt(n),'LineStyle','none','Color','k')
set(gca,'XTickLabel',{'Arab','Haredi','general'},'YTick',0:5,'FontSize',13,'ygrid','on')
rt = str(round(secMean,1));
text((1:3)-0.1,[0.15 0.15 0.15],rt,'FontSize',13,'Color','w')
title({'גודל שרשרת למגזר','Chain size per sector'})
legend('Mean','Median','Standard Error: SD/N^0^.^5','location','west')



big = [];
for jj = 1:length(sz)
    tmp = sectorW(tt{2:end,2} > sz(jj),:);
    big(jj,1:3) = mean(tmp == 1);
end
big(:,4) = 1-sum(big,2);
figure;
h = bar(big*100,'stacked');
hold on

set(gca,'XTickLabel',{'Arab','Haredi','general'},'YTick',0:10:100,'FontSize',13,'ygrid','on')
% rt = str(round(secMean,1));
% text((1:3)-0.1,[0.15 0.15 0.15],rt,'FontSize',13,'Color','w')
title({'שיוך שרשראות ארוכות למגזר','Sector-related long chanes'})
legend('Arab','Haredi','general','mixed')
