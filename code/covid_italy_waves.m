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

figure;
h = plot(date(2:end),ysm*10^6);
for ii=1:21
    h(order(ii)).Color = col(ii,:);
end
legend(h(order),popreg.region(order))
set(gcf,'Color','w')
box off
grid on
title('תמותה למליון ליום במחוזות איטליה')
accum1 = ita{190,:}./popreg.population'*10^6;
accum2 = (ita{end,:}-ita{190,:})./popreg.population'*10^6;
ylabel('מתים למליון')
[r,p] = corr(accum1',accum2');
figure;
scatter(accum1(order),accum2(order),25,col,'fill')
text(accum1(order)+20,accum2(order),popreg.region(order),'rotation',-5)
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
col = colormap(jet(107));
col = flipud(col);

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
scatter(accum1(order),accum2(order),15,col,'fill')
text(accum1(order)+200,accum2(order),strrep(popreg.Province(order),'_',' '),'rotation',-5)
ylabel('מאומתים למליון במצטבר מ 1.9')
xlabel('מאומתים למליון במצטבר עד 31.8')
set(gcf,'Color','w')
box off
grid on
title(['קורלציה של ',str(round(r,2)),' (p=',str(round(p,3)),') בין התחלואה בגל הראשון לשני בנפות איטליה'])