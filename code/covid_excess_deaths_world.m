cd ~/covid-19-israel-matlab/data/
!wget -O tmp.csv https://raw.githubusercontent.com/dkobak/excess-mortality/main/excess-mortality.csv
t = readtable('tmp.csv');
strrep(t.Country,'United Kingdom','UK')
[~,order] = sort(t.ExcessAs_OfAnnualBaseline,'descend');
t = t(order,:);
date = datetime(t.DataUntil,'InputFormat','MMM dd, yyyy');

co = hsv(10);
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
co = repmat(co,2,1);
co(end+1:height(t),1:3) = 0.65;
co(ismember(t.Country,'Israel'),:) = 0;
figure;
for ii = 1:height(t)
%     h(ii) = scatter(date(ii),t.ExcessAs_OfAnnualBaseline(ii),25,'fill');
    h(ii) = scatter(date(ii),t.ExcessAs_OfAnnualBaseline(ii),1,'MarkerEdgeColor','none');
    text(date(ii),t.ExcessAs_OfAnnualBaseline(ii),t.Country{ii},'Color',co(ii,:))
    hold on
end
% xlim([datetime(2020,10,20) datetime('today')+100])
xt = datetime(2020,3:100,1);
xt(xt > dateshift(max(date),'end','month')+31) = [];
set(gca,'XTick',xt)
xtickformat('MMM')
title({'Excess deaths as percents of annual','mortality by date of report               '})
ylabel('% of annual deaths')
set(gcf,'Color','w')
set(gca,'FontSize',13)
%%
lim = datetime(2020,10,20);
tr = t;
tr(date < lim,:) = [];
figure('units','normalized','position',[0,0.25,1,0.5]);
bar(tr.ExcessAs_OfAnnualBaseline)
set(gca,'XTick',1:height(tr),'XTickLabel',tr.Country,'ygrid','on','YTick',-10:10:100)
xtickangle(90)
% grid on
text((1:height(tr))-0.35,repmat(-12,height(tr),1),str((1:height(tr))'))
box off
title('Excess deaths as percents of annual deaths')
set(gcf,'Color','w')