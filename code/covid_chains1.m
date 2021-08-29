tt = readtable('~/Downloads/chains_report_2021-08-25.xlsx');
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


avgAge = cellfun(@str2num, strrep(tt{2:end,20},'-','0'));
avgAge(avgAge == 0) = nan;
figure;scatter(round(avgAge),tt{2:end,2},'.')
vac = tt{2:end,13};
ia = find(avgAge > 12 & avgAge < 30);

iH = find(tt{2:end,2} > 1000);
chainLength = tt{2:end,2};
chainLength(iH) = nan;
figure;
scatter3(avgAge,100*vac,chainLength,5,sectorW,'filled')
axis square
xlabel('Age (years)')
ylabel('Vaccination (%)')
zlabel('Chain size (people)')
set(gca,'XTick',0:10:100,'YTick',0:10:100)
set(gca,'View',[-18 4])

ylim([0 70])
xlim([12 35])

ages = (16:3:85)';
ages(:,2) = ages + 2;
mn = 0.65;
clear M P per
% per = [0.25 0.5];
for iAge = 1:15  % length(ages)
    idx = sectorW(:,3) > 0.9 & avgAge > ages(iAge,1) & avgAge < ages(iAge,2);
    per(iAge,1:2) = prctile(vac(idx),[100/3 100/3*2]);
%     if per(iAge,1) > 1/3
%         per(iAge,1) = 1/3;
%     end
%     if per(iAge,2) > 2/3
%         per(iAge,2) = 2/3;
%     end
    per(per(:,1) > mn,1) = mn;
    grV = tt{find(idx & vac >= per(iAge,2))+1,2};
    grU = tt{find(idx & vac < per(iAge,1))+1,2};
    M(iAge,1:2) = [mean(grV),mean(grU)];
    [~,P(iAge,1)] = ttest2(grV,grU);
end
%% 
figure;
hh = bar(M,'EdgeColor','none');
xt = cellstr(str(ages(1:15,:)));
xt = strrep(xt,'  ','-');
set(gca,'XTickLabel',xt)
zz = floor(abs(log10(P)));
xtt = cell(size(P));
for iz = 1:length(zz)
    if zz(iz) >= 2
        xtt{iz} = [str(zz(iz)),'*'];
    else
        xtt{iz} = ' ';
    end
end
text(1:length(P),M(:,2)+0.25,xtt)

ylabel('Chain length  אורך שרשרת')
legend('High vaccination  התחסנות גבוהה','Low vaccination  התחסנות נמוכה')
xlabel({'Chain mean age   גיל ממוצע לשרשרת','3* means p<0.001, 4* means p<0.0001 etc.'})
title({'אורך שרשרת לפי גיל, להתחסנות מעל אחוזון 67 ומתחת 33','Chain length by age for vaccination over percentile 67 and below 33'})
set(gca,'FontSize',13,'ygrid','on')
set(gcf,'Color','w')
box off
hh(1).FaceColor = [0.05 0.50 0.05];
hh(2).FaceColor = [0.7 0.050 0.05];

% %%
% figure;
% scatter(round(avgAge),tt{2:end,2},'.')
% set(gca,'YScale','log','FontSize',13)
% grid on
% xlabel('mean age of chain   גיל ממוצע בשרשרת')
% ylabel('chain length   אורך השרשרת')
% title({'אורך שרשרת ההדבקה לפי הגיל הממוצע','Infections chain length by mean age'})
% set(gcf,'color','w')
% figure;
% hist(round(avgAge))
% 
% 
% figure;
% scatter(round(100*vac(ia)),tt{ia + 1,2},'.')
% set(gca,'YScale','log','FontSize',13)
% grid on
% xlabel('mean vaccination of chain   התחסנות ממוצעת בשרשרת')
% ylabel('chain length   אורך השרשרת')
% title({'אורך שרשרת ההדבקה לפי מצב ההתחסנות, גיל 12-30','Infections chain length by by vaccination status, age 12-30'})
% set(gcf,'color','w')