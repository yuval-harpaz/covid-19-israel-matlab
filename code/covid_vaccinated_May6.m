cd /home/innereye/covid-19-israel-matlab/data/Israel
% json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=9b623a64-f7df-4d0c-9f57-09bd99a88880&limit=100000');
% json = jsondecode(json);
% cases = struct2table(json.result.records);
% % cases = readtable('tmp.csv','Delimiter',',');
% % cases = readtable('~/Downloads/cases-among-vaccinated-10.csv','Delimiter',',');
% 
% cells = cases{:,4:end};
% cells(cellfun(@isempty,cells)) = {'0'};
% cells(cellfun(@(x) strcmp(x,'<5'),cells)) = {'2.5'};
% cases{:,4:end} = cells;  % cellfun(@str2num,cells);
% weekk = unique(cases.Week);
%%
% json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=57410611-936c-49a6-ac3c-838171055b1f&limit=1000000');
% json = strrep(json,'<15','7');
% json = jsondecode(json);
% vaccA = struct2table(json.result.records);
vaccA = readtable('~/Downloads/vaccinated-per-day-2021-05-04.csv');
vaccA.first_dose = strrep(vaccA.first_dose,'<15','7');
vaccA.second_dose = strrep(vaccA.second_dose,'<15','7');
vaccA.first_dose = cellfun(@str2num,vaccA.first_dose);
vaccA.second_dose = cellfun(@str2num,vaccA.second_dose);
vaccA.Properties.VariableNames{1} = 'date';
vaccA.VaccinationDate = datetime(vaccA.date);
% vaccA.Properties.VariableNames{2} = 'date';
[~,order] = sort(vaccA.date);
vaccA = vaccA(order,:);
ages = unique(vaccA.age_group);
%%
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
vd = readtable('~/covid-19-israel-matlab/data/Israel/deaths by vaccination status.xlsx');

%%
iAge = 6:9;
vaccX = vaccA(ismember(vaccA.age_group,ages(iAge)),:);
date = unique(vaccX.date);
for ii = 1:length(date)
    vaccII_7(ii,1) = sum(vaccX.second_dose(vaccX.date <= date(ii)-7));
end
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
pop = sum(population(iAge(1):end));
popUV = pop-(vaccII_7(date > datetime(2021,2,6) & date < datetime(2021,5,2)));
deadUV = sum(listD.CountDeath(ismember(listD.date,datetime(2021,2,6):datetime(2021,5,2))))-...
    sum(vd.fullyVaccinated(ismember(vd.date,datetime(2021,2,7):datetime(2021,5,1))));
VE = 1-(103/length(popUV)/1060025)/(sum(deadUV)/sum(popUV))


[agf, agDate] = covid_fix_age('');
clear cases
for ii = 1:length(popUV)+1
    try
        cases(ii,1) = sum(agf{find(ismember(dateshift(agDate,'start','day'),datetime(2021,2,5)+ii),1,'last'),8:11});
    catch
        cases(ii,1) = nan;
    end
end
cases(isnan(cases)) = (cases(find(isnan(cases))-1)+cases(find(isnan(cases))-1))/2;
cases = diff(cases);
casesAll = listD.tests_positive(ismember(listD.date,datetime(2021,2,7):datetime(2021,5,1)));
cases(71:end) = 0.3*casesAll(71:end);
cases = round(cases);
op = table([datetime(2021,2,7):datetime(2021,5,1)]',popUV,cases);

cases(cases == 0) = nan;
cases = movmean(cases,[1 1],'omitnan')

figure;
line(op.Var1([1,end]),[1060025 1060025],'Color','b')
hold on
plot(op.Var1,op.popUV,'r')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
y = [1060025,103;mean(popUV),sum(deadUV)];
y = y./sum(y);
plot(op.Var1,movmean(cases*2*1000,[3 3]),'k')
legend('vaccinated','unvaccinated','2000*cases 60+')
grid on
title('group size over time vs cases')
figure;
bar(100*y','stacked')
ylim([0 100])
set(gca,'XTickLabel',{'People','Deaths'},'FontSize',13,'YGrid','on')
set(gcf,'Color','w')
title({'Deaths by vaccination status and group size','VE = 97.2%'})
legend('Vaccinated','Unvaccinated')
ylabel('%')

% 
% clear eff60
% for ii = 1:length(weekk)
%     date1 = datetime(weekk{ii}(1:10));
%     vacc1 = zeros(7,1);
%     for iDate1 = 1:7
%         uvr = ismember(vaccX.date,date1+iDate1-1);
%         if sum(uvr) > 0
%             vacc1(iDate1,1) = sum(vaccX.first_dose(1:find(uvr,1,'last')));
%         end
%     end
%     for jj = 1:3
%         w = [1:6,7:-1:1];
%         if jj == 1
%             dates = date1-6:date1+5;
%             w = [1:6,6:-1:1];
%         else
%             dates = date1-1-7*(jj-2);
%             dates = dates-12:dates;
%         end
%         vrw = zeros(height(vaccX),1);
%         
%         for iDate = 1:length(dates)
%             vr = ismember(vaccX.date,dates(iDate));
%             if ~isempty(vr)
%                 vrw(vr) = w(iDate);
%                 %vacc1(iDate,1) = sum(vaccX.first_dose(1:find(vr,1,'last')));
%             end
%         end
%         vac = sum(vaccX.second_dose.*vrw);
%         caseRow = ismember(cases.Week,weekk(ii)) & ismember(cases.Age_group,ages(iAge));
%         cl = cases{caseRow,7+jj};
% %         cl = strrep(cases{caseRow,6+jj},'<5','2.5');
% %         cl(cellfun(@isempty,cl)) = {'0'};
%         if sum(vrw) == 0
%             eff60(ii,jj) = nan;
%             ppv60(ii,jj) = nan;
%             ppu60(ii,jj) = nan;
%             vv60(ii,jj) = nan;
%             uu60(ii,jj) = nan;
%         else
%             eff60(ii,jj) = (sum(cellfun(@str2num,cl))/vac)/...
%                 (sum(cellfun(@str2num,cases.Sum_positive_without_vaccination(caseRow)))/sum(pop-vacc1));
%             ppv60(ii,jj) = sum(cellfun(@str2num,cl))/vac;
%             ppu60(ii,jj) = sum(cellfun(@str2num,cases.Sum_positive_without_vaccination(caseRow)))/sum(pop-vacc1);
%             vv60(ii,jj) = sum(cellfun(@str2num,cl));
%             uu60(ii,jj) = sum(cellfun(@str2num,cases.Sum_positive_without_vaccination(caseRow)));
%         end
%     end
% end
% % eff(eff > 100) = nan;
% eff60 = 1-eff60;
% figure;
% plot(eff60)
% set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
% xtickangle(35)
% grid on
% set(gcf,'Color','w')
% legend('1 week','2 weeks','3 weeks')
% ylim([0 1])
% set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)
% xlim([4,length(eff60)-2])
% %%
% pop = sum(population);
% clear eff
% for ii = 1:length(weekk)
%     date1 = datetime(weekk{ii}(1:10));
%     vacc1 = zeros(7,1);
%     for iDate1 = 1:7
%         uvr = ismember(vaccA.date,date1+iDate1-1);
%         if sum(uvr) > 0
%             vacc1(iDate1,1) = sum(vaccA.first_dose(1:find(uvr,1,'last')));
%         end
%     end
%     for jj = 1:3
%         w = [1:6,7:-1:1];
%         if jj == 1
%             dates = date1-6:date1+5;
%             w = [1:6,6:-1:1];
%         else
%             dates = date1-1-7*(jj-2);
%             dates = dates-12:dates;
%         end
%         vrw = zeros(height(vaccA),1);
%         
%         for iDate = 1:length(dates)
%             vr = ismember(vaccA.date,dates(iDate));
%             if ~isempty(vr)
%                 vrw(vr) = w(iDate);
%                 %vacc1(iDate,1) = sum(vaccA.first_dose(1:find(vr,1,'last')));
%             end
%         end
%         vac = sum(vaccA.second_dose.*vrw);
%         caseRow = ismember(cases.Week,weekk(ii));
%         cl = cases{caseRow,7+jj};
% %         cl = strrep(cases{caseRow,6+jj},'<5','2.5');
% %         cl(cellfun(@isempty,cl)) = {'0'};
%         if sum(vrw) == 0
%             eff(ii,jj) = nan;
%             ppv(ii,jj) = nan;
%             ppu(ii,jj) = nan;
%             vv(ii,jj) = nan;
%             uu(ii,jj) = nan;
%         else
%             eff(ii,jj) = (sum(cellfun(@str2num,cl))/vac)/...
%                 (sum(cellfun(@str2num,cases.Sum_positive_without_vaccination(caseRow)))/sum(pop-vacc1));
%             ppv(ii,jj) = sum(cellfun(@str2num,cl))/vac;
%             ppu(ii,jj) = sum(cellfun(@str2num,cases.Sum_positive_without_vaccination(caseRow)))/sum(pop-vacc1);
%             vv(ii,jj) = sum(cellfun(@str2num,cl));
%             uu(ii,jj) = sum(cellfun(@str2num,cases.Sum_positive_without_vaccination(caseRow)));
%         end
%     end
% end
% % eff(eff > 100) = nan;
% eff = 1-eff;
% figure;
% plot(eff)
% set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
% xtickangle(35)
% grid on
% set(gcf,'Color','w')
% legend('1 week','2 weeks','3 weeks')
% ylim([0 1])
% set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)
% xlim([4,length(eff)-2])
% %%
% figure;bar([nansum(vv)',nansum(vv60)'])
% legend('All ages','Over 60')
% set(gca,'ygrid','on')
% title('vaccinated cases')
% 
% 
% %%
% numbers = cellfun(@str2num,cells);
% yy = round([sum(numbers(:,1:4))',sum(numbers(:,5:8))']);
% figure;
% bar(yy)
% set(gca,'fontsize',13,'ygrid','on','XTickLabel',{'1-6','7-13','14-20','20+'})
% xlabel('Days from vaccination')
% ax = gca;
% ax.YRuler.Exponent = 0;
% ax.YAxis.TickLabelFormat = '%,.0f';
% legend('Dose I','Dose II')
% grid minor
% set(gcf,'Color','w')