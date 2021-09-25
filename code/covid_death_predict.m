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

cOld = ismember(cases.age_group,'מעל גיל 60');
sOld = ismember(severe.age_group,'מעל גיל 60');
dOld = ismember(deathsm.age_group,'מעל גיל 60');
cYoung = ismember(cases.age_group,'מתחת לגיל 60');
sYoung = ismember(severe.age_group,'מתחת לגיל 60');
dYoung = ismember(deathsm.age_group,'מתחת לגיל 60');
ages = {dOld,sOld,cOld;dYoung,sYoung,cYoung};
tit = {{'Severe vs deaths for 60+ by vaccination status','severe shifted by 7 days'};...
    {'Severe vs deaths for <60 by vaccination status','severe shifted by 7 days'}};
%% plot abs
iAge = 1;
% figure;
% yyaxis left
% plot(deaths.date(ages{iAge,1}),movmean(deaths{dOld,3:5},[3 3]))
% ylim([0 30])
% yyaxis right
% plot(cases.date(ages{iAge,2})+14,movmean(cases{sOld,3:5},[3 3]))
% legend('deaths dose III','deaths dose II','deaths unvacc',...
%     'cases dose III','cases dose II','cases unvacc','location','north')
% % preprocess


sd3 = [sum([severe{ages{2,2},6:8}],2),sum([severe{ages{1,2},6:8}],2)];
sd3(end,:) = nan;
sd3 = movmean(sd3,[3 3],'omitnan');
dd3 = [sum(deathsm{ages{2,1},3:5},2),sum(deathsm{ages{1,1},3:5},2)];
dd3(end,:) = nan;
dd3 = movmean(dd3,[3 3],'omitnan');

figure;
h1 = plot(severe.date(ages{1,1}),dd3,'k');
hold on
h2 = plot(severe.date(ages{1,1})+7,sd3.*[0.05,0.35],'r');
legend([h1(1),h2(1)],'deaths','predicted deaths')
text([0,0],[35,33.2],{'Deaths and predicted deaths for older (top)',...
    'and younger than 60 (bottom)'},'FontSize',13)
axis tight
set(gca,'FontSize',13)
grid on
set(gcf,'Color','w')
facSev = [0.05,0.35];
predSev = sum(sd3.*facSev,2);
sd6 = [severe{ages{2,2},6:8},severe{ages{1,2},6:8}];
sd6(end,:) = nan;
sd6 = movmean(sd6,[3 3],'omitnan');
dd6 = [deathsm{ages{2,1},3:5},deathsm{ages{1,1},3:5}];
dd6(end,:) = nan;
dd6 = movmean(dd6,[3 3],'omitnan');
figure;
plot(severe.date(ages{1,1}),dd6)
colorset;
hold on
plot(severe.date(ages{1,1})+7,sd6.*[facSev(1),facSev(1),facSev(1),facSev(2),facSev(2),facSev(2)],':')
% plot(severe.date(ages{1,1})+7,sd6.*[0.05,0.05,0.05,0.5,0.5,0.5],':')
legend('young dose III','young dose II','young unvacc', 'old dose III','old dose II','old unvacc')
title('severe')

cd6 = [cases{ages{2,3},3:5},cases{ages{1,3},3:5}];
cd6(end,:) = nan;
cd6 = movmean(cd6,[3 3],'omitnan');
fac = [0,0.0002,0.0004,0.025,0.025,0.1];
figure;
plot(severe.date(ages{1,1}),dd6)
colorset;
hold on
plot(severe.date(ages{1,3})+14,cd6.*fac,':')
legend('young dose III','young dose II','young unvacc', 'old dose III','old dose II','old unvacc')
title('cases')
predCases = sum(cd6.*fac,2);

figure;
plot(severe.date(ages{1,1}),sum(dd3,2),'k')
hold on
plot(severe.date(ages{1,1})+8,predSev,'r')
plot(severe.date(ages{1,1})+11,predCases,'b')
legend('deaths','severe-predicted','cases-predicted')
grid on
title('predict deaths by cases or new severe patients')
set(gcf,'Color','w')
set(gca,'FontSize',13)
ylabel('deaths')
%%
facSev = [0.05,0.35];

listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
listD = listD(1:end-1,:);
deathsm = movmean(listD.CountDeath,[3 3]);
sevAge = readtable('~/covid-19-israel-matlab/data/Israel/severe60.csv');
sevAge = sevAge(1:end-1,:);
predSev1 = sum(sevAge{:,[3,2]}.*facSev,2);
figure;
plot(listD.date,deathsm,'k')
hold on
plot(sevAge.date+8,movmean(predSev1,[3 3]),'r')

facSev2 = [-0.1,0.4];
predSev2 = sum(sevAge{:,[3,2]}.*facSev2,2);
shift = 10;

figure;
plot(listD.date,deathsm,'k')
hold on
plot(sevAge.date+shift,movmean(predSev2,[3 3]),'r')


idx = find(ismember(listD.date,sevAge.date));
sevsm = movmean(sevAge{:,[3,2]},[3 3]);
% b = sevsm(1:end-shift,:)\deathsm(idx(shift+1:end));


lowRisk = sevAge.over60vacc2;
lowRisk(200:end) = sevAge.over60vacc3(200:end);
lowRisk = lowRisk+sevAge.below60;
highRisk = sevAge.total-lowRisk;
xx = movmean([lowRisk,highRisk],[3 3]);
bb = xx(1:end-shift,:)\deathsm(idx(shift+1:end));
figure;
plot(listD.date,deathsm,'k','linewidth',2)
hold on
plot(listD.date(2:end)+shift,0.35*movmean(diff(listD.CountSeriousCriticalCum),[3 3]),'b')
plot(sevAge.date+shift,0.47*sevsm(:,2),'r')
grid on
set(gcf,'Color','w')
% plot(sevAge.date+shift,bb'*xx','g')
% plot(sevAge.date+shift,b'*xx','c')
legend('deaths','severe x 0.35','old severe x 0.47')
xxx = movmean([[10;10;10;10;10;10;10;lowRisk(8:end)],highRisk],[3 3]);
bbb = xxx(1:end-shift,:)\deathsm(idx(shift+1:end));
figure;
plot(listD.date,deathsm,'k','linewidth',2)
hold on
plot(sevAge.date+shift,0.9*bbb'*xxx','m')
legend('deaths','low risk x 0.025 + high risk x 0.53','Location','west')
ylim([0 60])
grid on
set(gcf,'Color','w')
title('deaths prediction by high and low risk patient in severe condition')
% 
% rat = dd3(8:end,:)./sd3(1:end-7,:);
% rat(100:153,:) = nan;
% rat(195:204,1) = nan;
% dt = deaths.date(ages{iAge,1});
% dt = dt(8:end);
% % plot norm
% figure('units','normalized','position',[0.1 0.1 0.65 0.8]);
% subplot(2,1,1)
% yyaxis left
% 
% h = plot(deaths.date(ages{iAge,1}),dd3,'linewidth',2);
% if iAge == 1
%     ylim([0 9])
% else
%     ylim([0 18])
% end
% %             else
% %                ylim([0 60])
% %                en
% ylabel('deaths per 100k')
% 
% yyaxis right
% h(4:6,1) = plot(severe.date(ages{iAge,2})+7,sd3,'linewidth',2);
% if iAge == 1
%     legend(flipud(h),fliplr({'deaths dose III','deaths dose II','deaths unvacc',...
%         'severe dose III','severe dose II','severe unvacc'}),'location','north')
%     %         ylim([0 25])
% else
%     legend(flipud(h(4:6)),fliplr({'severe dose III','severe dose II','severe unvacc'}),'location','north')
% end
% grid on
% 
% title(tit{iAge})
% box off
% xlim([datetime(2021,2,15) datetime('today')+14])
% ylabel('severe per 100k')
% subplot(2,1,2)
% 
% yyaxis left
% h1 = plot(dt,100*rat,'linewidth',2);
% ylabel('deaths to severe ratio (%)')
% if iAge == 2
%     %         ylim([0 5])
% end
% yyaxis right
% set(gca,'Ytick',[])
% legend(flipud(h1),fliplr({'dose III','dose II','unvacc'}),'location','north')
% title('deaths to severe ratio')
% grid on
% box off
% set(gcf,'Color','w')
% xlim([datetime(2021,2,15) datetime('today')+14])
% 
