[itaD,popD,dateD] = covid_italy;
[itaC,popC,dateC] = covid_italy_province;
if ~isequal(dateC,dateD)
    error('not the same dates')
end
popD.region = strrep(popD.region,'P.A. ','');
popC.Region = strrep(popC.Region,'Lombardy','Lombardia');
popC.Region = strrep(popC.Region,'Tuscany','Toscana');
popC.Region = strrep(popC.Region,'Sicily','Sicilia');
popC.Region = strrep(popC.Region,'Sardinia','Sardegna');
popC.Region = strrep(popC.Region,'Apulia','Puglia');
popC.Region = strrep(popC.Region,'Trento','Trentino-South Tyrol');
popC.Region = strrep(popC.Region,'Friuli-Venezia Giulia','Friuli Venezia Giulia');
% popC.Region = strrep(popC.Region,'Friuli Venezia Giulia','Veneto');
% popC.Region = strrep(popC.Region,'Veneto','Friuli Venezia Giulia');
popC.Region = strrep(popC.Region,'Aosta Valley',['Valle d''','Aosta']);
popC.Region = strrep(popC.Region,'Piedmont','Piemonte');
popC.Region{ismember(popC.Code,'BZ')} = 'Bolzano';
popC.Region{ismember(popC.Code,'TN')} = 'Trento';
popD.region(~ismember(popD.region,popC.Region))

cpm = itaC{:,:}./popC.Population2019'*10^6;
bad = cpm(2:end,:) < cpm(1:end-1,:);
[x,y] = find(bad);
for ii = 1:length(x)
    cpm(x(ii),y(ii)) = nan;
    cpm(x(ii)+1,y(ii)) = nan;
end


% cpm(121,:) = nan;
cpm = movmean(cpm,[7 7],'omitnan');
cpm = diff(cpm);
cpm(cpm < 0) = 0;

dpmD = diff(itaD{:,:})./popD.population'*10^6;
dpmD(dpmD < 0) = 0;
dpmD(106,1) = 0;
dpmD(173,5) = 0;
dpmD = movmean(dpmD,[3 3]);
dpm = nan(size(cpm));
for ii = 1:21
    prov = find(ismember(popC.Region,popD.region{ii}));
    w = cpm(:,prov)./sum(cpm(:,prov),2);
    dpm(:,prov) = w.*dpmD(:,ii);
end

%%
% 
% popreg.Properties.VariableNames{5} = 'population';
% yy = diff(ita{:,:})./popreg.population';
% isr = [nansum(listD.tests_positive(1:140))./9.2,sum(listD.tests_positive(141:end))./9.2];
% [~,order] = sort(ita{190,:}./popreg.population,'descend');
% popreg.region(order(1:10));
% popreg.region(order(1:20));
[wave1,order] = sort(nansum(dpm(1:190,:)),'descend');
wave2 = nansum(dpm(191:end,order));

[r,p] = corr(wave1',wave2');
%%

figure;
col = colormap(jet(107));
col = flipud(col);
scatter(wave1,wave2,15,col,'fill')
text(wave1+5,wave2,strrep(popC.Province(order),'_',' '),'rotation',-5)

ylabel('מאומתים למליון במצטבר מ 1.9')
xlabel('מאומתים למליון במצטבר עד 31.8')
set(gcf,'Color','w')
box off
grid on
title(['קורלציה של ',str(round(r,2)),' (p=',str(round(p,4)),') בין התחלואה בגל הראשון לשני בנפות איטליה'])
% line([0,20000],[0 20000*(wave1'\wave2')],'color','k','linestyle','--')
%%
[~,ord] = sort(itaD{end,:}./popD.population','descend');
figure;
plot(dateD,itaD{:,ord}./popD.population(ord)'*10^6)
legend(popD.region(ord),'location','northwest');
grid on
box off
ax = gca;
ax.YRuler.Exponent = 0;
set(gcf,'Color','w')
ylabel('מתים למליון')
ax.FontSize = 13;
title('תמותה למליון מצטברת באיטליה')