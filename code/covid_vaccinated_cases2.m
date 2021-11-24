cd /home/innereye/covid-19-israel-matlab/data/Israel
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=9b623a64-f7df-4d0c-9f57-09bd99a88880&limit=100000');
json = jsondecode(json);
cases = struct2table(json.result.records);
% cases = readtable('tmp.csv','Delimiter',',');
% cases = readtable('~/Downloads/cases-among-vaccinated-10.csv','Delimiter',',');

cells = cases{:,4:end};
cells(cellfun(@isempty,cells)) = {'0'};
cells(cellfun(@(x) strcmp(x,'<5'),cells)) = {'2.5'};
cases{:,4:end} = cells;  % cellfun(@str2num,cells);
weekk = unique(cases.Week);
%%
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=57410611-936c-49a6-ac3c-838171055b1f&limit=1000000');
json = strrep(json,'<15','7');
json = jsondecode(json);
vaccA = struct2table(json.result.records);
vaccA.first_dose = cellfun(@str2num,vaccA.first_dose);
vaccA.second_dose = cellfun(@str2num,vaccA.second_dose);
vaccA.third_dose = cellfun(@str2num,vaccA.third_dose);
vaccA.VaccinationDate = datetime(vaccA.VaccinationDate);
vaccA.Properties.VariableNames{2} = 'date';
[~,order] = sort(vaccA.date);
vaccA = vaccA(order,:);
ages = unique(vaccA.age_group);

%%
iAge = 6:9;
vaccX = vaccA(ismember(vaccA.age_group,ages(iAge)),:);
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
pop = sum(population(iAge(1):end));
dose2 = sum(cellfun(@str2num, [cases.positive_14_30_days_after_2nd_dose,...
    cases.positive_31_90_days_after_2nd_dose,cases.positive_above_90_days_after_2nd_dose]),2);
dose3 = cellfun(@str2num, cases.positive_above_20_days_after_3rd_dose);
unvacc = cellfun(@str2num, cases.Sum_positive_without_vaccination);
clear ve2 ve3
for ii = 1:length(weekk)
    date1 = datetime(weekk{ii}(1:10));
    caseRow = ismember(cases.Week,weekk(ii)) & ismember(cases.Age_group,ages(iAge));
    idx = vaccX.date < (date1-7+3);
    if sum(idx) == 0
        vacc1 = 0;
    else
        vacc1 = sum(vaccX.first_dose(idx));
    end
    idx = vaccX.date < (date1-20+3);
    if sum(idx) == 0
        vacc3 = 0;
    else
        vacc3 = sum(vaccX.third_dose(idx));
    end
    ve3(ii,1) = 100*(1-(sum(dose3(caseRow))/vacc3)/(sum(unvacc(caseRow))/(pop-vacc1)));
    idx = vaccX.date < (date1-14+3);
    if sum(idx) == 0
        vacc2 = 0;
    else
        vacc2 = sum(vaccX.second_dose(idx))-vacc3;
    end
    ve2(ii,1) = 100*(1-(sum(dose2(caseRow))/vacc2)/(sum(unvacc(caseRow))/(pop-vacc1)));
    if ~isnan(ve2(ii))
        a=1;
    end
    
end
% eff(eff > 100) = nan;


figure;
bar([ve2,ve3])
set(gca,'fontsize',13,'ygrid','on','XTick',6:length(ve2),'XTickLabel',weekk(6:length(ve2)))
xtickangle(90)
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
legend('Dose II','Dose III')
grid minor
set(gcf,'Color','w')
xlim([5,length(ve2)+1])
box off
title('vaccine effectiveness for 60+ cases')
