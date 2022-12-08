listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');

json = urlread('https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily');
json = jsondecode(json);
deathsm = struct2table(json);
deathsm.day_date = datetime(strrep(deathsm.day_date,'T00:00:00.000Z',''));
deathsm.Properties.VariableNames{1} = 'date';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily');
json = jsondecode(json);
severe = struct2table(json);
severe.day_date = datetime(strrep(severe.day_date,'T00:00:00.000Z',''));
severe.Properties.VariableNames{1} = 'date';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily');
json = jsondecode(json);
cases = struct2table(json);
cases.day_date = datetime(strrep(cases.day_date,'T00:00:00.000Z',''));
cases.Properties.VariableNames{1} = 'date';
age = 'מעל גיל 60';  % age = 'מתחת לגיל 60';
ccc = ismember(cases.age_group,age);
sss = ismember(severe.age_group,age);
ddd = ismember(deathsm.age_group,age);
if ~isequal(ccc,ddd) && ~isequal(ccc,sss)
    error('not same index')
end
mn = dateshift(cases.date,'start','month');
mnu = unique(mn);

emp = cellfun(@isempty, cases.verified_expired_normalized);
cases.verified_expired_normalized(emp) = {nan};
cases.verified_expired_normalized = cellfun(@(x) x,cases.verified_expired_normalized);
emp = cellfun(@isempty, cases.verified_vaccinated_normalized);
cases.verified_vaccinated_normalized(emp) = {nan};
cases.verified_vaccinated_normalized = cellfun(@(x) x,cases.verified_vaccinated_normalized);

emp = cellfun(@isempty, severe.serious_expired_normalized);
severe.serious_expired_normalized(emp) = {nan};
severe.serious_expired_normalized = cellfun(@(x) x,severe.serious_expired_normalized);
emp = cellfun(@isempty, severe.serious_vaccinated_normalized);
severe.serious_vaccinated_normalized(emp) = {nan};
severe.serious_vaccinated_normalized = cellfun(@(x) x,severe.serious_vaccinated_normalized);

emp = cellfun(@isempty, deathsm.death_expired_normalized);
deathsm.death_expired_normalized(emp) = {nan};
deathsm.death_expired_normalized = cellfun(@(x) x,deathsm.death_expired_normalized);
emp = cellfun(@isempty, deathsm.death_vaccinated_normalized);
deathsm.death_vaccinated_normalized(emp) = {nan};
deathsm.death_vaccinated_normalized = cellfun(@(x) x,deathsm.death_vaccinated_normalized);


clear ve2 ve3
for ii = 1:12+month(datetime('today'))
    im = ismember(mn,mnu(ii));
    y = nanmean(cases.verified_expired_normalized(ccc & im));
    yso(ii,1) = y;
%     if y < 1
%         y = nan;
%     end
    veOld(ii,1) = 100*(1-(y./nanmean(cases.verified_not_vaccinated_normalized(ccc & im))));
    y = mean(severe.serious_expired_normalized(ccc & im));
    yso(ii,2) = y;
    veOld(ii,2) = 100*(1-(y./mean(severe.serious_not_vaccinated_normalized(ccc & im))));
    y = mean(deathsm.death_expired_normalized(ccc & im));
    yso(ii,3) = y;
    veOld(ii,3) = 100*(1-(y./mean(deathsm.death_not_vaccinated_normalized(ccc & im))));
    y = nanmean(cases.verified_vaccinated_normalized(ccc & im));
    yso(ii,4) = y;
    veNew(ii,1) = 100*(1-(y./nanmean(cases.verified_not_vaccinated_normalized(ccc & im))));
    boost(ii,1) = 100*(1-(y./nanmean(cases.verified_expired_normalized(ccc & im))));
    y = mean(severe.serious_vaccinated_normalized(ccc & im));
    yso(ii,5) = y;
    veNew(ii,2) = 100*(1-(y./mean(severe.serious_not_vaccinated_normalized(ccc & im))));
    boost(ii,2) = 100*(1-(y./mean(severe.serious_expired_normalized(ccc & im))));
    y = mean(deathsm.death_vaccinated_normalized(ccc & im));
    yso(ii,6) = y;
    veNew(ii,3) = 100*(1-(y./mean(deathsm.death_not_vaccinated_normalized(ccc & im))));
    boost(ii,3) = 100*(1-(y./mean(deathsm.death_expired_normalized(ccc & im))));
    
    
end
veNew(5:6,:) = nan;
veOld(1:7,:) = nan;
boost(1:7,:) = nan;
dd = movmean(diff(listD.CountSeriousCriticalCum),[3 3]);
%%
figure('position',[100,100,1200,1200]);
subplot(3,1,1)
hb = bar(mnu,veNew,'EdgeColor','none');
hb(1).FaceColor = [0,0.492,0.353];
hb(2).FaceColor = [0.786,0.327,0.327];
hb(3).FaceColor = 0.5*[0.7,0.098,0.5];
ylim([-10 100])
hold on
plot(listD.date(2:end)-15,dd/max(dd)*100,'k')
if day(datetime('today')) > 7
    xl = [datetime(2020,12,1) datetime('today')]+15;
else
    xl = [datetime(2020,12,1) dateshift(datetime('today')-8,'start','month')]+15;
end
xlim(xl);
legend('VE for positive tests','VE for severe illness','VE for deaths','new severe cases (normalized)','location','north')
xtickformat('MMM')
xtickangle(0)
set(gca,'ygrid','on','YTick',0:10:100,'XTick',datetime(2021,1:50,1))
title('VE for 60+ by month, recently vaccinated')
set(gcf,'Color','w')
box off

subplot(3,1,2)
hb2 = bar(mnu,veOld,'EdgeColor','none');
hb2(1).FaceColor = [0,0.492,0.353];
hb2(2).FaceColor = [0.786,0.327,0.327];
hb2(3).FaceColor = 0.5*[0.7,0.098,0.5];
% hb(2).FaceColor = [0.439,0.427,0.686];
% hb(3).FaceColor = [0.541,0.098,0.353];
ylim([-10 100])
hold on
plot(listD.date(2:end)-15,dd/max(dd)*100,'k')
xlim(xl);
% legend('VE for positive tests','VE for severe illness','VE for deaths','new severe cases (normalized)')
xtickformat('MMM')
xtickangle(0)
set(gca,'ygrid','on','YTick',0:10:100,'XTick',datetime(2021,1:50,1))
title('VE for 60+ by month, expired vaccination')
set(gcf,'Color','w')
box off

subplot(3,1,3)
hb3 = bar(mnu,boost,'EdgeColor','none');
hb3(1).FaceColor = [0,0.492,0.353];
hb3(2).FaceColor = [0.786,0.327,0.327];
hb3(3).FaceColor = 0.5*[0.7,0.098,0.5];
% hb(2).FaceColor = [0.439,0.427,0.686];
% hb(3).FaceColor = [0.541,0.098,0.353];
ylim([-10 100])
hold on
plot(listD.date(2:end)-15,dd/max(dd)*100,'k')
xlim(xl);
% legend('VE for positive tests','VE for severe illness','VE for deaths','new severe cases (normalized)')
xtickformat('MMM')
xtickangle(0)
set(gca,'ygrid','on','YTick',0:10:100,'XTick',datetime(2021,1:50,1))
title('VE for 60+ by month, valid vaccine compared to expired')
set(gcf,'Color','w')
box off
%%

