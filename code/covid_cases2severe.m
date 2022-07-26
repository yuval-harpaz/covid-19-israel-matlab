% json = urlread('https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily');
% json = jsondecode(json);
% deaths = struct2table(json);
% deaths.day_date = datetime(strrep(deaths.day_date,'T00:00:00.000Z',''));
% deaths.Properties.VariableNames{1} = 'date';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily');
json = jsondecode(json);
severe = struct2table(json);
severe.day_date = datetime(strrep(severe.day_date,'T00:00:00.000Z',''));
severe.Properties.VariableNames{1} = 'date';
noempty = severe.new_serious_vaccinated_normalized;
noempty(cellfun(@isempty, noempty)) = {nan};
severe.new_serious_vaccinated_normalized = [noempty{:}]';
noempty = severe.new_serious_expired_normalized;
noempty(cellfun(@isempty, noempty)) = {nan};
severe.new_serious_expired_normalized = [noempty{:}]';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily');
json = jsondecode(json);
cases = struct2table(json);
cases.day_date = datetime(strrep(cases.day_date,'T00:00:00.000Z',''));
cases.Properties.VariableNames{1} = 'date';
noempty = cases.verified_vaccinated_normalized;
noempty(cellfun(@isempty, noempty)) = {nan};
cases.verified_vaccinated_normalized = [noempty{:}]';
noempty = cases.verified_expired_normalized;
noempty(cellfun(@isempty, noempty)) = {nan};
cases.verified_expired_normalized = [noempty{:}]';
dOld = ismember(severe.age_group,'מעל גיל 60');
cOld = ismember(cases.age_group,'מעל גיל 60');
dYoung = ismember(severe.age_group,'מתחת לגיל 60');
cYoung = ismember(cases.age_group,'מתחת לגיל 60');
ages = {dOld,cOld;dYoung,cYoung};
shift = 7;
sst = str(shift);
tit = {{'Cases vs severe for 60+ by vaccination status',['cases shifted by ',sst,' days']};...
    {'Cases vs severe for <60 by vaccination status',['cases shifted by ',sst,' days']}};
%% plot abs
iAge = 1;
% figure;
% yyaxis left
% plot(deaths.date(ages{iAge,1}),movmean(deaths{dOld,3:5},[3 3]))
% ylim([0 30])
% yyaxis right
% plot(cases.date(ages{iAge,2})+14,movmean(cases{cOld,3:5},[3 3]))
% legend('deaths dose III','deaths dose II','deaths unvacc',...
%     'cases dose III','cases dose II','cases unvacc','location','north')
% % preprocess


cd3 = cases{ages{iAge,2},6:8};
cd3(1:195,1) = nan;
if iAge == 2
    cd3(196:209,1) = nan;
end
cd3(1:end-1,:) = movmean(cd3(1:end-1,:),[3 3],'omitnan');
cd3(end,:) = nan;
cd3(cd3 == 0) = nan;
if iAge == 1
    sd3 = movmean(severe{ages{iAge,1},12:14},[3 3]);
else
    sd3 = severe{ages{iAge,1},12:14};
end
rat = sd3(shift+1:end,:)./cd3(1:end-shift,:);
rat(110:170,:) = nan;
rat(85:152,2) = nan;
dt = severe.date(ages{iAge,1});
dt = dt(shift+1:end);
% plot norm
figure('units','normalized','position',[0.1 0.1 0.65 0.8]);
subplot(2,1,1)
yyaxis left

h = plot(severe.date(ages{iAge,1}),sd3,'linewidth',2);
if iAge == 1
    ylim([0 100])
else
    ylim([0 18])
end
%             else
%                ylim([0 60])
%                en
ylabel('severe per 100k')

yyaxis right
h(4:6,1) = plot(cases.date(ages{iAge,2})+shift,cd3,'linewidth',2);
if iAge == 1
    legend(flipud(h),fliplr({'severe, recently vaccinated','severe, expired vaccine','severe, unvaccinated',...
        'cases, recently vaccinated','cases, expired vaccine','cases, unvaccinated'}),'location','north')
    ylim([0 1000])
else
    legend(flipud(h(4:6)),fliplr({'cases, recently vaccinated','cases, expired vaccine','cases, unvaccinated'}),'location','north')
end
grid on

title(tit{iAge})
box off
xlim([datetime(2021,2,1) datetime('today')+shift])
ylabel('cases per 100k')
subplot(2,1,2)

yyaxis left
h1 = plot(dt,100*rat,'linewidth',2);
ylabel('severe to cases ratio (%)')
if iAge == 2
    ylim([0 5])
end
yyaxis right
set(gca,'Ytick',[])
legend(flipud(h1),fliplr({'recently vaccinated','expired vaccine','unvaccinated'}),'location','north')
title('severe to cases ratio')
grid on
box off
set(gcf,'Color','w')
xlim([datetime(2021,2,1) datetime('today')+shift])

