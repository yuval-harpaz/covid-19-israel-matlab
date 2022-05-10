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
sd3 = [sum([severe{ages{2,2},6:8}],2),sum([severe{ages{1,2},6:8}],2)];
sd3(end,:) = nan;
sd3 = movmean(sd3,[3 3],'omitnan');
dd3 = [sum(deathsm{ages{2,1},3:5},2),sum(deathsm{ages{1,1},3:5},2)];
dd3(end,:) = nan;
dd3 = movmean(dd3,[3 3],'omitnan');

facSev = [0.08,0.37];

figure('position',[100,100,900,700]);
h1 = plot(severe.date(ages{1,1}),dd3,'k');
h1(1).LineWidth = 1.5;
hold on
h2 = plot(severe.date(ages{1,1})+7,sd3.*facSev,'r');
h2(1).LineWidth = 1.5;
legend([h1(2),h2(2),h1(1),h2(1)],'deaths 60+','predicted deaths 60+','deaths <60','predicted deaths <60')
title('Deaths and predicted deaths for older and younger than 60','FontSize',13)
axis tight
set(gca,'FontSize',13)
grid on
set(gcf,'Color','w')



predSev = sum(sd3.*facSev,2);
sd6 = [severe{ages{2,2},6:8},severe{ages{1,2},6:8}];
sd6(end,:) = nan;
sd6 = movmean(sd6,[3 3],'omitnan');
dd6 = [deathsm{ages{2,1},3:5},deathsm{ages{1,1},3:5}];
dd6(end,:) = nan;
dd6 = movmean(dd6,[3 3],'omitnan');

% figure;
% plot(severe.date(ages{1,1}),dd6)
% colorset;
% hold on
% plot(severe.date(ages{1,1})+7,sd6.*[facSev(1),facSev(1),facSev(1),facSev(2),facSev(2),facSev(2)],':')
% % plot(severe.date(ages{1,1})+7,sd6.*[0.05,0.05,0.05,0.5,0.5,0.5],':')
% legend('young vacc','young exp','young unvacc', 'old vacc','old exp','old unvacc')
% title('severe')

cd6 = [cases{ages{2,3},3:5},cases{ages{1,3},3:5}];
cd6(end,:) = nan;
cd6 = movmean(cd6,[3 3],'omitnan');
facD = [0.0002,0.0003,0.0005,0.025,0.035,0.1];
figure('position',[100,100,900,700]);
plot(severe.date(ages{1,1}),dd6)
colorset;
hold on
plot(severe.date(ages{1,3})+14,cd6.*facD,':')
legend('young dose III','young dose II','young unvacc', 'old dose III','old dose II','old unvacc')
title('cases')

facO = [0.00005,0.00015,0.00008,0.0047,0.02,0.035];
figure('position',[100,100,900,700]);
plot(severe.date(ages{1,1}),dd6)
colorset;
hold on
plot(severe.date(ages{1,3})+14,cd6.*facO,':')
legend('young dose III','young dose II','young unvacc', 'old dose III','old dose II','old unvacc')
title('cases')

predCasesD = sum(cd6.*facD,2);
% predCasesO = sum(cd6(:,[1,2,3,5,6]).*facO([1,2,3,5,6]),2);
% predCasesO(1:end-4) = predCasesO(1:end-4) + cd6(5:end,4)*facO(4);
predCasesO = sum(cd6.*facO,2);
predCases = predCasesO;
predCases(1:337) = predCasesD(1:337);


figure('position',[100,100,900,700]);
plot(severe.date(ages{1,1}),sum(dd3,2),'k','linewidth',2)
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
% facSev = [0.05,0.35];
% 
% listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
% listD = listD(1:end-1,:);
% deathsmm = movmean(listD.CountDeath,[3 3]);
% sevAge = readtable('~/covid-19-israel-matlab/data/Israel/severe60.csv');
% sevAge = sevAge(1:end-1,:);
% predSev1 = sum(sevAge{:,[3,2]}.*facSev,2);
% figure;
% plot(listD.date,deathsmm,'k')
% hold on
% plot(sevAge.date+8,movmean(predSev1,[3 3]),'r')
% 
% facSev2 = [-0.1,0.4];
% predSev2 = sum(sevAge{:,[3,2]}.*facSev2,2);
% shift = 10;
% 
% figure;
% plot(listD.date,deathsmm,'k')
% hold on
% plot(sevAge.date+shift,movmean(predSev2,[3 3]),'r')
% 
% 
% idx = find(ismember(listD.date,sevAge.date));
% sevsm = movmean(sevAge{:,[3,2]},[3 3]);
% % b = sevsm(1:end-shift,:)\deathsm(idx(shift+1:end));
% 
% 
% 
% figure;
% plot(listD.date,deathsmm,'k','linewidth',2)
% hold on
% plot(listD.date(2:end)+shift,0.35*movmean(diff(listD.CountSeriousCriticalCum),[3 3]),'b')
% plot(sevAge.date+shift,0.47*sevsm(:,2),'r')
% plot(sevAge.date+shift,0.47*sevsm(:,2),'r')
% grid on
% set(gcf,'Color','w')
% % plot(sevAge.date+shift,bb'*xx','g')
% % plot(sevAge.date+shift,b'*xx','c')
% legend('deaths','severe x 0.35','old severe x 0.47')
% %%
% lowRisk = sevAge.over60vacc2;
% lowRisk(200:end) = sevAge.over60vacc3(200:end);
% lowRisk = lowRisk+sevAge.below60;
% highRisk = sevAge.total-lowRisk;
% xx = movmean([lowRisk,highRisk],[3 3]);
% bb = xx(1:end-shift,:)\deathsmm(idx(shift+1:end));
% lr2 = zeros(size(lowRisk));
% lr3 = lr2;
% % lry = lr2;
% % hr0 = lr2;
% % hr1 = lr2;
% hr2 = lr2;
% lr2(1:199) = sevAge.over60vacc2(1:199);
% lr3(200:end) = sevAge.over60vacc3(200:end);
% lry = sevAge.below60;
% hr0 = sevAge.over60unvacc;
% hr2(200:end) = sevAge.over60vacc2(200:end);
% hr1 = highRisk-hr2-hr0;
% hr1(hr1 < 10) = 0;
% figure('position',[100,100,900,600]);
% hb = bar(sevAge.date,movmean([hr0,hr1,lr2,hr2,lr3,...
%     sevAge.below60unvacc,lry-sevAge.below60unvacc],[3 3]),1,'stacked','EdgeColor','none');
% % hb = bar(sevAge.date,movmean([hr0,hr1,lr2,hr2,lr3,lry],[3 3]),1,'stacked','EdgeColor','none');
% % hold on
% % plot(sevAge.date,sevAge.total);
% 
% grid on
% box off
% set(gcf,'Color','w')
% title('New severe patients by risk group')
% hb(1).FaceColor = [0.3 0.3 0.3];
% hb(2).FaceColor = [0.7 0.0 0.0];
% hb(3).FaceColor = [0.2 0.6 0.2];
% hb(5).FaceColor = [0.1 0.9 0.1];
% hb(4).FaceColor = [0.9 0.2 0.2];
% hb(7).FaceColor = [0.2 0.2 1];
% legend(fliplr(hb),fliplr(...
%     {'0 doses, 60+','1 dose, 60+','2 doses 60+, fresh vaccine','2 doses 60+, old vaccine','3 doses','<60 unvaccinated','<60 dose 1 or more'}))
% xtickformat('MMM')
% %%
% % xxx = movmean([[10;10;10;10;10;10;10;lowRisk(8:end)],highRisk],[3 3]);
% ns = 15;
% push = repmat(10,ns,1); % move young ns days further than old
% raw = [[push;lowRisk(1:end-ns)],highRisk];
% xxx = movmean(raw,[3 3]);
% % xxx(end,:) = raw(end,:);
% % xxx(end-1,:) = mean(raw(end-2:end,:));
% % xxx(end-2,:) = mean(raw(end-4:end,:));
% 
% last = xxx(end-2:end,:);
% xxx(end-2:end,:) = nan;
% % xxx(end) = movmean([[10;10;10;10;10;10;10;lowRisk(8:end)],highRisk],[3 3]);
% % bbb = xxx(1:end-shift,:)\deathsm(idx(shift+1:end));
% % bbb = 0.9*bbb;
% % bbb = 0.9*[0.0275;0.533];
% % bbb = [0;0.5];
% % bbb = [0.0363;0.4779];
% bbb = [0.08;0.47];
% 
% figure('position',[100,100,900,600]);
% h(1) = plot(listD.date,deathsmm,'k','linewidth',2);
% hold on
% h(2) = plot(sevAge.date+shift,bbb'*xxx','m');
% plot(sevAge.date(end-2:end)+shift,bbb'*last','m.');
% legend('deaths',['low risk x ',str(round(bbb(1),3)),' + high risk x ',str(round(bbb(2),3))],'Location','west')
% ylim([0 60])
% xlim([datetime(2020,9,15) datetime('today')+14])
% grid on
% set(gcf,'Color','w')
% title('deaths prediction by high and low risk patient in severe condition')
% 
% 
% %% 
% % lry = sevAge.below60;
% % predlr = [lry,lr2,lr3]*bbb(1);
% % predhr = [hr0,hr1,hr2]*bbb(2);
% % pred = lry*0.08+hr2*0.1;
% % pred(ns+1:end) = pred(ns+1:end) + predlr(1:end-ns);
% % figure;
% % plot(sevAge.date+shift,movmean(lry,[3 3])*0.08,'m')
% % hold on
% % plot(deathsm.date(dYoung),movmean(sum(deathsm{dYoung,3:5},2),[3 3]),'b')
% % 
% % figure;
% % plot(sevAge.date+shift,movmean(lr2,[3 3])*bbb(2),'m')
% % hold on
% % plot(deathsm.date(dYoung),movmean(sum(deathsm.death_amount_vaccinated(dOld),2),[3 3]),'b')
% % 
% % figure;
% % plot(sevAge.date+shift,movmean(hr2,[3 3])*0.3,'m')
% % hold on
% % plot(deathsm.date(dOld),movmean(sum(deathsm.death_amount_vaccinated(dOld),2),[3 3]),'b')
% % 
% % figure;
% % plot(sevAge.date+shift,movmean(lr3,[3 3])*0.4,'m')
% % hold on
% % plot(deathsm.date(dOld),movmean(sum(deathsm.death_amount_boost_vaccinated(dOld),2),[3 3]),'b')
% 
% % plot(sum(xxx.*bbb