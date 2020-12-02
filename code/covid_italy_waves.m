[ita,popreg,date] = covid_italy;

yy = diff(ita{:,:})./popreg.population';

% [~,order] = sort(ita{190,:}./popreg.population,'descend');
% popreg.region(order(1:10));
% popreg.region(order(1:20));
[dpm,order] = sort(ita{190,:}./popreg.population'.*10^6,'descend');
% col = colormap(jet(21));
yy(106,1) = 0;
yy(yy < 0) = 0;
yy(173,5) = 0;
ysm = movmean(yy,[3 3]);
col = colormap(jet(21));
col = flipud(col);
listD = readtable('data/Israel/dashboard_timeseries.csv');
isr = [nansum(listD.CountDeath(1:140))./9.2,sum(listD.CountDeath(141:end))./9.2];
figure;
h = plot(date(2:end),ysm*10^6);
for ii=1:21
    h(order(ii)).Color = col(ii,:);
end
hold on
h(end+1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3],'omitnan')./9.2,'k');
legend([h(order);h(end)],[popreg.region(order);{'Israel'}])
set(gcf,'Color','w')
box off
grid on
title({'תמותה למליון ליום במחוזות איטליה','ישראל בשחור'})
accum1 = ita{190,:}./popreg.population'*10^6;
accum2 = (ita{end,:}-ita{190,:})./popreg.population'*10^6;
ylabel('מתים למליון')
[r,p] = corr(accum1',accum2');


figure;
scatter(accum1(order),accum2(order),25,col,'fill')
hold on
scatter(isr(1),isr(2),25,'k','fill')
text(accum1(order)+20,accum2(order),popreg.region(order),'rotation',-5)
text(isr(1)+20,isr(2),'Israel','rotation',-5)
ylabel('נפטרים למליון במצטבר מ 1.9')
xlabel('נפטרים למליון במצטבר עד 31.8')
set(gcf,'Color','w')
box off
grid on
title(['קורלציה של ',str(round(r,2)),' (p=',str(round(p,3)),') בין התמותה בגל הראשון לשני במחוזות איטליה'])

%%
[ita,popreg,date] = covid_italy_province;
popreg.Properties.VariableNames{5} = 'population';
yy = diff(ita{:,:})./popreg.population';
isr = [nansum(listD.tests_positive(1:140))./9.2,sum(listD.tests_positive(141:end))./9.2];
% [~,order] = sort(ita{190,:}./popreg.population,'descend');
% popreg.region(order(1:10));
% popreg.region(order(1:20));
[dpm,order] = sort(ita{190,:}./popreg.population'.*10^6,'descend');
% col = colormap(jet(21));
% yy(106,1) = 0;
% yy(yy < 0) = 0;
% yy(173,5) = 0;
% yy(yy < 1/3) = 0;
yy(yy == 227) = 0;
yy(yy < 0) = 0;

ysm = movmean(yy,[3 3]);

% figure;
% h = plot(date(2:end),ysm*10^6);
% for ii=1:21
%     h(order(ii)).Color = col(ii,:);
% end
% legend(h(order),popreg.region(order))
% set(gcf,'Color','w')
% box off
% grid on
% title('תמותה למליון ליום במחוזות איטליה')
accum1 = ita{190,:}./popreg.population'*10^6;
accum2 = (ita{end,:}-ita{190,:})./popreg.population'*10^6;
% ylabel('מתים למליון')
[r,p] = corr(accum1',accum2');
%%

figure;
col = colormap(jet(107));
col = flipud(col);
scatter(accum1(order),accum2(order),15,col,'fill')
hold on
scatter(isr(1),isr(2),15,'k','fill')
text(accum1(order)+200,accum2(order),strrep(popreg.Province(order),'_',' '),'rotation',-5)
text(isr(1)+200,isr(2),'Israel','rotation',-5)
ylabel('מאומתים למליון במצטבר מ 1.9')
xlabel('מאומתים למליון במצטבר עד 31.8')
set(gcf,'Color','w')
box off
grid on
title(['קורלציה של ',str(round(r,2)),' (p=',str(round(p,4)),') בין התחלואה בגל הראשון לשני בנפות איטליה'])
% line([0,20000],[0 20000*(accum1'\accum2')],'color','k','linestyle','--')