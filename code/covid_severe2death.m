json = urlread('https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily');
json = jsondecode(json);
deaths = struct2table(json);
deaths.day_date = datetime(strrep(deaths.day_date,'T00:00:00.000Z',''));
deaths.Properties.VariableNames{1} = 'date';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily');
json = jsondecode(json);
severe = struct2table(json);
severe.day_date = datetime(strrep(severe.day_date,'T00:00:00.000Z',''));
severe.Properties.VariableNames{1} = 'date';

dOld = ismember(deaths.age_group,'מעל גיל 60');
sOld = ismember(severe.age_group,'מעל גיל 60');
dYoung = ismember(deaths.age_group,'מתחת לגיל 60');
cYoung = ismember(deaths.age_group,'מתחת לגיל 60');
ages = {dOld,sOld;dYoung,cYoung};
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


cd3 = severe{ages{iAge,2},12:14};
cd3(1:195,1) = nan;
if iAge == 2
    cd3(196:209,1) = nan;
end
cd3(1:end-1,:) = movmean(cd3(1:end-1,:),[3 3],'omitnan');
cd3(end,:) = nan;
cd3(cd3 == 0) = nan;
if iAge == 1
    dd3 = movmean(deaths{ages{iAge,1},6:8},[3 3]);
else
    dd3 = deaths{ages{iAge,1},6:8};
end
rat = dd3(8:end,:)./cd3(1:end-7,:);
rat(100:153,:) = nan;
rat(195:204,1) = nan;
dt = deaths.date(ages{iAge,1});
dt = dt(8:end);
% plot norm
figure('units','normalized','position',[0.1 0.1 0.65 0.8]);
subplot(2,1,1)
yyaxis left

h = plot(deaths.date(ages{iAge,1}),dd3,'linewidth',2);
if iAge == 1
    ylim([0 9])
else
    ylim([0 18])
end
%             else
%                ylim([0 60])
%                en
ylabel('deaths per 100k')

yyaxis right
h(4:6,1) = plot(severe.date(ages{iAge,2})+7,cd3,'linewidth',2);
if iAge == 1
    legend(flipud(h),fliplr({'deaths, recently vaccinated','deaths, expired vaccine','deaths, unvaccinated',...
        'severe, recently vaccinated','severe, expired vaccine','severe, unvaccinated'}),'location','north')
    %         ylim([0 25])
else
    legend(flipud(h(4:6)),fliplr({'severe, recently vaccinated','severe, expired vaccine','severe, unvaccinated'}),'location','north')
end
grid on

title(tit{iAge})
box off
xlim([datetime(2021,2,15) datetime('today')+14])
ylabel('severe per 100k')
subplot(2,1,2)

yyaxis left
h1 = plot(dt,100*rat,'linewidth',2);
ylabel('deaths to severe ratio (%)')
if iAge == 2
    %         ylim([0 5])
end
yyaxis right
set(gca,'Ytick',[])
legend(flipud(h1),fliplr({'recently vaccinated','expired vaccine','unvaccinated'}),'location','north')
title('deaths to severe ratio')
grid on
box off
set(gcf,'Color','w')
xlim([datetime(2021,2,15) datetime('today')+14])

