txt = urlread('https://raw.githubusercontent.com/hodcroftlab/covariants/master/web/data/perCountryDataCaseCounts.json');
json = jsondecode(txt);
iIsr = find(ismember({json.regions.distributions(:).country}','Israel'));
isr = struct2table(json.regions.distributions(iIsr).distribution);
week = cellfun(@datetime, isr.week);
variant = fieldnames(isr.stand_estimated_cases);
tt = struct2table(isr.stand_estimated_cases(:));

prc = tt{:,:};
prc(prc < 0) = 0;
prc = prc./sum(prc,2);
prc(isnan(prc)) = 0;
json = urlread('https://datadashboardapi.health.gov.il/api/queries/deadPatientsPerDate');
json = jsondecode(json);
death = struct2table(json);
death.date = datetime(strrep(death.date,'T00:00:00.000Z',''));

json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectedPerDate');
json = jsondecode(json);
cases = struct2table(json);
cases.date = datetime(strrep(cases.date,'T00:00:00.000Z',''));
%%

shift_cases = 14;
shift = shift_cases+14;
death2w = nan(length(week),1);
cases2w = nan(length(week),1);
for ii = 1:height(tt)
    row = find(death.date == week(ii));
    row = (row-13):row;
    row = row + shift;
    if row(end) <= height(death)
        death2w(ii,1) = sum(death.amount(row));
    else
        death2w(ii,1) = nan;
    end
    
    row = find(cases.date == week(ii));
    row = (row-13):row;
    row = row + shift_cases;
    cases2w(ii,1) = sum(cases.amount(row));
end

dbv = prc.*death2w;
cbv = prc.*cases2w;
figure;
bar(week,cbv,1,'stacked','EdgeColor','none')
%%
figure;
plot(week,cbv)

figure;
bar(week,prc,1,'stacked','EdgeColor','none')

figure;
plot(week,dbv)

%%
tot = round(nansum(dbv));
yy = [tot(7);tot(16)+tot(17);tot(18);tot(19);tot(20)];
figure;
pie(yy,{['Alpha ',str(yy(1))],['Delta ',str(yy(2))],['Omicron BA1 ',str(yy(3))],...
    ['Omicron BA2 ',str(yy(4))],['Other ',str(yy(5))]})
%%
txt = urlread('https://raw.githubusercontent.com/hodcroftlab/covariants/master/web/data/perClusterData.json');
jsonClust = jsondecode(txt);
weekk = cellfun(@datetime, {jsonClust.distributions(end).distribution(:).week}');
jvr = [1,6:8];
isr = nan(length(weekk),length(jvr));
for iVar = 1:length(jvr)
    fr = {jsonClust.distributions(jvr(iVar)).distribution(:).frequencies}';
    for ii = 1:length(fr)
        if isfield(fr{ii},'Israel')
            isr(ii,iVar) = fr{ii}.Israel;
        end
    end
end

figure;bar(weekk,isr,1,'stacked','EdgeColor','none')
legend({jsonClust.distributions(jvr).cluster}')

%%
jvr = 7:11;
omi = nan(length(weekk),length(jvr));
for iVar = 1:length(jvr)
    fr = {jsonClust.distributions(jvr(iVar)).distribution(:).frequencies}';
    for ii = 1:length(fr)
        if isfield(fr{ii},'Israel')
            omi(ii,iVar) = fr{ii}.Israel;
        end
    end
end
%%
figure('position',[100,100,1000,700]);
subplot(2,1,1)
ho = bar(weekk,100*omi,1,'stacked','EdgeColor','none');
tit = {'22C BA.2.12.1';'22B BA.5';'22A BA.4';'21L BA.2';'21K BA.1'};
lh1 = legend(fliplr(ho),tit);
lh1.Position(1) = 0.6; 
lh1.Position(2) = 0.7;
lh1.EdgeColor = 'none';
xlim([datetime(2021,12,1) weekk(end)-3])
grid on
set(gca,'XTick',datetime(2021,1:50,1),'layer','top')
xtickformat('MMM')
box off
title('Omicron sub-variants in Israel (%, stacked)')
hold on
ylabel('%')

subplot(2,1,2)
hol = plot(weekk,100*omi);
lh = legend(flipud(hol),tit);
lh.Position(1) = 0.6; 
lh.Position(2) = 0.2;
lh.EdgeColor = 'none';
xlim([datetime(2021,12,1) weekk(end)-3])
grid on
set(gca,'XTick',datetime(2021,1:50,1),'layer','top')
xtickformat('MMM')
box off
title('Omicron sub-variants in Israel (%)')
hold on
set(gcf,'Color','w')
ylabel('%')
%%

%%

[~,~] = system('wget -O tmp.csv https://covid19.who.int/WHO-COVID-19-global-data.csv');
whoData = readtable('tmp.csv');
whoData.Country = strrep(whoData.Country,'Republic of Korea','South Korea');
whoData.Country = strrep(whoData.Country,'The United Kingdom','United Kingdom');
whoData.Country = strrep(whoData.Country,'Russian Federation','Russia');
whoData.Country = strrep(whoData.Country,'United States of America','USA');
okayCountry = find(ismember(jsonClust.country_names,whoData.Country));
% jsonClust.country_names(~okayCountry)
casesCountryW = nan(length(weekk),length(okayCountry));
shiftCases = 14;
for ii = 1:length(weekk)
    for jj = 1:length(okayCountry)
        row = find(whoData.x_Date_reported < weekk(ii)+1-shiftCases & ...
            whoData.x_Date_reported > weekk(ii)-7-shiftCases & ...
            ismember(whoData.Country,jsonClust.country_names{okayCountry(jj)}));
        if length(row) == 7
            casesCountryW(ii,jj) = sum(whoData.New_cases(row));
        else
            error('no 7 days');
        end
    end
end

figure;
for iVar = 1:length(jvr)
    fr = {jsonClust.distributions(jvr(iVar)).distribution(:).frequencies}';
    prcc = nan(length(weekk),length(okayCountry));
    casc = nan(length(weekk),length(okayCountry));
    for iCountry = 1:length(okayCountry)
        for ii = 1:length(fr)
            cc = jsonClust.country_names{okayCountry(iCountry)};
            if isfield(fr{ii},cc)
                prcc(ii,iCountry) = eval(['fr{ii}.',cc,';']);
                casc(ii,iCountry) = casesCountryW(ii,iCountry).*prcc(ii,iVar);
            end
        end
    end
    subplot(2,2,iVar)
    plot(weekk,casc)
    title({jsonClust.distributions(jvr(iVar)).cluster}');
    if iVar == 1
        legend(jsonClust.country_names(okayCountry))
    end
    ratio = casc(2:end,:)./casc(1:end-1,:);
    ratio = movmean(ratio,[2,2],'omitnan');
    ratio(isinf(ratio)) = 0;
    ratVar(1:length(okayCountry),iVar) = nanmax(ratio);
end

nonan = ~any(isnan(ratVar),2);
figure;
bar(ratVar(nonan,:))
set(gca,'Ygrid','on','Xtick',1:sum(nonan),'XTickLabel',jsonClust.country_names(okayCountry(nonan)))
legend({jsonClust.distributions(jvr).cluster}')
xtickangle(90)
title('Maximum weekly multiplication per variant')
box off
ylabel('weekly multiplication')

figure;
bar(mean(ratVar(nonan,:)),'EdgeColor','none','FaceColor','b')
hold on
errorbar(median(ratVar(nonan,:)),std(ratVar(nonan,:)),'Color','k','linestyle','none')
title('Maximum weekly multiplication per variant')
set(gca,'YGrid','on','XTickLabel',{jsonClust.distributions(jvr).cluster})
ylabel('weekly multiplication')
xtickangle(45)
