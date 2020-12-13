us_state = urlread('https://raw.githubusercontent.com/jeffcore/covid-19-usa-by-state/master/COVID-19-Deaths-USA-By-State.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,us_state);
fclose(fid);
us_state = readtable('tmp.csv');
date = datetime(cellfun(@(x) [x(1:end-2),'2020'],us_state{1,2:end}','UniformOutput',false));
us_state(1,:) = [];
writetable(us_state,'tmp.csv','WriteVariableNames',false)
deaths = readtable('tmp.csv');
!rm tmp.csv

us_state = urlread('https://raw.githubusercontent.com/jeffcore/covid-19-usa-by-state/master/COVID-19-Cases-USA-By-State.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,us_state);
fclose(fid);
us_state = readtable('tmp.csv');
us_state(1,:) = [];
writetable(us_state,'tmp.csv','WriteVariableNames',false)
cases = readtable('tmp.csv');
!rm tmp.csv

pop = readtable('data/us_state_population.csv');
[~,idx] = ismember(pop.State,cases.Var1);
cases = cases(idx,:);
deaths = deaths(idx,:);

cas = diff(cases{:,2:end}');
cas(cas < 0) = nan;
for iState = 1:56
    iBad = find(diff(cas(:,iState)) < -10000);
    cas(iBad,iState) = nan;
end

dat = diff(deaths{:,2:end}');
dat = dat./pop.population'*10^6;
dat(dat < 0) = nan;
for iState = 1:56
    iBad = find(diff(dat(:,iState)) < -40);
    dat(iBad,iState) = nan;
end

cas = movmean(cas,[6 0],'omitnan');
dat = movmean(dat,[6 0],'omitnan');

cas = cas./pop.population'*10^6;



nyc = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/data-by-day.csv');
% nyc = strrep(nyc,'/20,','/2020,');
fid = fopen('tmp.csv','w');
fwrite(fid,nyc);
fclose(fid);
nyc = readtable('tmp.csv');
!rm tmp.csv

nycas = nyc.CASE_COUNT_7DAY_AVG./8336830*10^6;
nydat = nyc.DEATH_COUNT_7DAY_AVG./8336830*10^6;
%%
figure;
subplot(2,1,1)
h1 = plot(date(2:end),cas,'k');
hold on
h2 = plot(nyc.date_of_interest,nycas,'r','linewidth',2);
xlim([datetime(2020,3,1) datetime('today')+15])
title('מאומתים למליון')
legend([h1(1),h2(1)],'מדינות ארה"ב','ניו יורק סיטי')
set(gca,'FontSize',13)
grid on
box off
subplot(2,1,2)
plot(date(2:end),dat,'k')
hold on
plot(nyc.date_of_interest,nydat,'r','linewidth',2)
title('נפטרים למליון')
xlim([datetime(2020,3,1) datetime('today')+15])
set(gcf,'Color','w')
set(gca,'FontSize',13)
grid on
box off

figure;
scatter(cas(end,:),dat(end,:),25,'k','fill')
text(cas(end,:)'+20,dat(end,:)',cases.Var1,'rotation',-5)
hold on
scatter(nycas(end),nydat(end),25,'r','fill')
text(nycas(end)+20,nydat(end),'NYC','Color','r')
axis square
grid on
title('Cases vs Deaths')
ylabel('deaths per million')
xlabel('cases per million')

d2c = [dat(end,:)./cas(end-10,:),nydat(end)/nycas(end-10)];
[d2c,order] = sort(d2c);
order(d2c == 0 | isnan(d2c)) = [];
d2c(d2c == 0 | isnan(d2c)) = [];
figure;
hb = bar(d2c,'EdgeColor','none','FaceColor','k');
hold on
hbr = bar(find(order == 57),d2c(find(order == 57)),'FaceColor','r','EdgeColor','none');
xt = [cases.Var1;'NYC'];
set(gca,'Xtick',1:length(d2c),'XTickLabel',xt(order))
xtickangle(90)
title('Deaths (today) per Cases (10 days before)')
%%
col = colormap(jet(size(dat,2)));
col = flipud(col);
[dpm,order1] = sort(deaths{:,161}./pop.population.*10^6,'descend');
[~,order2] = sort(dat(end,:),'descend');
figure;
hcAll = plot(date(2:end),dat,'k');
for ic = 1:56
    hcAll(order1(ic)).Color = col(ic,:);
end
hold on
hcN = plot(nyc.date_of_interest,nydat,'r','linewidth',2);
legend([hcN;hcAll(order2)],[{'NYC'};deaths.Var1(order2)])
title({'נפטרים למליון','הצבע מקודד את הפטירה בגל הראשון, המקרא מסודר לפי פטירה בשבוע הנוכחי'})
xlim([datetime(2020,3,1) datetime('today')+15])
set(gcf,'Color','w')
set(gca,'FontSize',13)
grid on
box off

[~,p] = corr(deaths{:,161},deaths{:,end}-deaths{:,161});

