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
sev = sd3;
sd3(end,:) = nan;
sd3 = movmean(sd3,[3 3],'omitnan');
dd3 = [sum(deathsm{ages{2,1},3:5},2),sum(deathsm{ages{1,1},3:5},2)];
det = dd3;
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

plt = false;
if plt
    ratioSev =  sd3(:,1)./sd3(:,2);
    ratioDeath = dd3(:,1)./dd3(:,2);
    tonan = find(sd3(:,1) < 3);
    tonan(tonan > length(dd3)-7) = [];
    ratioDeath(tonan+7) = nan;
    ratioSev(tonan) = nan;
    ratioDeath = movmean(ratioDeath,[3 3],'omitnan');
    ratioSev = movmean(ratioSev,[3 3],'omitnan');

    figure;
    plot(severe.date(ages{1,1}),ratioDeath,'k')
    hold on
    plot(severe.date(ages{1,1})+7,ratioSev,'r')
    idx = [1,142;143, 336; 337, 422; 423,496;497,length(sd3)-7];
    d = severe.date(ages{1,1});
    figure;
    plot(d,sd3(:,2));
    hold on;
    plot(d,sd3(:,1))
    %plot(d(idx(:,1)),sd3(idx(:,1),2),'.g');
    plot(d(idx(:,2)),sd3(idx(:,2),2),'.r','markersize',10);
    grid on
    title('new severe')
    legend('old','young')
    text(d([50,200,365,440,510]),[40, 40, 40,40,40],{'Alpha','Delta','BA.1','BA.2','BA.5'})
    ylabel('new patients')
    for iWave = 1:length(idx) 
        ratio(iWave,1) = sum(sev(idx(iWave,1):idx(iWave,2),1))/sum(sum(sev(idx(iWave,1):idx(iWave,2),:)));
        ratio(iWave,2) = sum(det(idx(iWave,1):idx(iWave,2),1))/sum(sum(det(idx(iWave,1):idx(iWave,2),:)));
        sumS(iWave,1:2) = [sum(sev(idx(iWave,1):idx(iWave,2),2)),sum(sev(idx(iWave,1):idx(iWave,2),1))];
        sumD(iWave,1:2) = [sum(det(idx(iWave,1):idx(iWave,2),2)),sum(det(idx(iWave,1):idx(iWave,2),1))];
    end
    ratio = round(100*ratio,1);

    figure;
    bar(ratio)
    legend('Severe','Deaths')
    set(gca,'XTickLabel',{'Alpha','Delta','BA.1','BA.2','BA.5'},'FontSize',13)
    ylabel('% young')
    title('younger than 60 / all')
    grid on
    set(gcf,'COLOR','W')
    predSev = sum(sd3.*facSev,2);
    sd6 = [severe{ages{2,2},6:8},severe{ages{1,2},6:8}];
    sd6(end,:) = nan;
    sd6 = movmean(sd6,[3 3],'omitnan');
    dd6 = [deathsm{ages{2,1},3:5},deathsm{ages{1,1},3:5}];
    dd6(end,:) = nan;
    dd6 = movmean(dd6,[3 3],'omitnan');
    text((1:5)-0.33,ratio(:,1)+2,str(ratio(:,1)))
    text((1:5),ratio(:,2)+2,str(ratio(:,2)))

    data = {sumS,sumD};
    tit = {'severe','deaths'};
    figure;
    for ip = 1:2
        subplot(1,2,ip)
        bar(data{ip}(2:end,:))
        set(gca,'XTickLabel',{'Delta','BA.1','BA.2','BA.5'},'FontSize',13)
        ylabel(tit{ip})
        title(tit{ip})
        grid on
        text((1:4)-0.25,data{ip}(2:end,1)+(3-ip)*40,str(data{ip}(2:end,1)))
        text((1:4),data{ip}(2:end,2)+(3-ip)*40,str(data{ip}(2:end,2)))
    end
    legend('60+','<60')
    set(gcf,'COLOR','W')
end
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
fac = [0.0002,0.0003,0.0005,0.025,0.035,0.1];
% figure('position',[100,100,900,700]);
% plot(severe.date(ages{1,1}),dd6)
% colorset;
% hold on
% plot(severe.date(ages{1,3})+14,cd6.*fac,':')
% legend('young dose III','young dose II','young unvacc', 'old dose III','old dose II','old unvacc')
% title('cases')
predCases = sum(cd6.*fac,2);

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
