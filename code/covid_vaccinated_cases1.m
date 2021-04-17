cd /home/innereye/covid-19-israel-matlab/data/Israel
% txt = urlread('https://data.gov.il/dataset/covid-19/resource/9b623a64-f7df-4d0c-9f57-09bd99a88880');
% strfind(txt,'csv')
%  ! wget -O tmp.csv https://data.gov.il/dataset/covid-19/resource/9b623a64-f7df-4d0c-9f57-09bd99a88880/download/cases-among-vaccinated-10.csv
% cases = readtable('tmp.csv','Delimiter',',');
cases = readtable('~/Downloads/cases-among-vaccinated-10.csv','Delimiter',',');
weekk = unique(cases.x_Week);
col = jet(5);
col = flipud(col(:,[1,3,2]));
col = col([1,3:end],:);

%%
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=57410611-936c-49a6-ac3c-838171055b1f&limit=1000000');
json = strrep(json,'<15','7');
json = jsondecode(json);
vaccA = struct2table(json.result.records);
vaccA.first_dose = cellfun(@str2num,vaccA.first_dose);
vaccA.second_dose = cellfun(@str2num,vaccA.second_dose);
vaccA.VaccinationDate = datetime(vaccA.VaccinationDate);
vaccA.Properties.VariableNames{2} = 'date';
[~,order] = sort(vaccA.date);
vaccA = vaccA(order,:);

%%
json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
json = jsondecode(json);
t = struct2table(json);
date = datetime(strrep(t.Day_Date,'T00:00:00.000Z',''));
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
ages = unique(vaccA.age_group);

clear eff
for ii = 1:length(weekk)
    for jj = 1:3
        dates = datetime(weekk{ii}(1:10));
        dates = dates:dates+6;
        dates = dates-7*jj;
        
        vacRow = find(ismember(vaccA.date,dates)); 
        % & ismember(vaccA.age_group,ages(iAge)));
        % vacRow = -7:find(vaccA.date == datetime(weekk{ii}(1:10)))-1;
        % vacRow = vacRow-7*(jj-1);
        vacRow = vacRow(vacRow > 0);
        dateM = median(vaccA.date(vacRow));
        vacCumRow = find(vaccA.date == dateM,1,'last');
        vaccCum1 = sum(vaccA.first_dose(1:vacCumRow));
        vac = sum(vaccA.second_dose(vacRow));
        caseRow = ismember(cases.x_Week,weekk(ii));
        cl = strrep(cases{caseRow,6+jj},'<5','2.5');
        cl(cellfun(@isempty,cl)) = {'0'};
        if isempty(vacRow) || isequal(unique(cl),{'0'})
            eff(ii,jj) = nan;
        else
            eff(ii,jj) = (sum(cellfun(@str2num,cl))/vac)/...
                (sum(cases.Sum_positive_without_vaccination(caseRow))/(9500000-vaccCum1));
        end
    end
end
% eff(eff > 100) = nan;
eff = 1-eff;
figure;
plot(eff)
set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
xtickangle(35)
grid on
set(gcf,'Color','w')
legend('1 week','2 weeks','3 weeks')
% title('vaccinated cases: week of positive test from dose I (color) by date (x-axis)')
% ylabel('cases')
%%
iAge = 6:9;
vaccX = vaccA(ismember(vaccA.age_group,ages(iAge)),:);
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
pop = sum(population(iAge(1):end));
clear eff60
for ii = 1:length(weekk)
    for jj = 1:3
        dates = datetime(weekk{ii}(1:10));
        dates = dates:dates+6;
        dates = dates-7*jj;
        
        vacRow = find(ismember(vaccX.date,dates)); 
        % & ismember(vaccA.age_group,ages(iAge)));
        % vacRow = -7:find(vaccA.date == datetime(weekk{ii}(1:10)))-1;
        % vacRow = vacRow-7*(jj-1);
        vacRow = vacRow(vacRow > 0);
        dateM = median(vaccX.date(vacRow));
        vacCumRow = find(vaccX.date == dateM,1,'last');
        vaccCum1 = sum(vaccX.first_dose(1:vacCumRow));
        vac = sum(vaccX.second_dose(vacRow));
        caseRow = ismember(cases.x_Week,weekk(ii));
        cl = strrep(cases{caseRow,6+jj},'<5','2.5');
        cl(cellfun(@isempty,cl)) = {'0'};
        if isempty(vacRow)
            eff60(ii,jj) = nan;
        else
            eff60(ii,jj) = (sum(cellfun(@str2num,cl))/vac)/...
                (sum(cases.Sum_positive_without_vaccination(caseRow))/(pop-vaccCum1));
        end
    end
end
% eff(eff > 100) = nan;
eff60 = 1-eff60;
figure;
plot(eff60)
set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
xtickangle(35)
grid on
set(gcf,'Color','w')
legend('1 week','2 weeks','3 weeks')
ylim([0 1])
set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)


%%
iAge = 6;
vaccX = vaccA(ismember(vaccA.age_group,ages(iAge)),:);
pop = sum(population(iAge(1)));
clear effX
for ii = 1:length(weekk)
    for jj = 1:3
        dates = datetime(weekk{ii}(1:10));
        dates = dates:dates+6;
        dates = dates-7*jj;
        
        vacRow = find(ismember(vaccX.date,dates)); 
        % & ismember(vaccA.age_group,ages(iAge)));
        % vacRow = -7:find(vaccA.date == datetime(weekk{ii}(1:10)))-1;
        % vacRow = vacRow-7*(jj-1);
        vacRow = vacRow(vacRow > 0);
        dateM = median(vaccX.date(vacRow));
        vacCumRow = find(vaccX.date == dateM,1,'last');
        vaccCum1 = sum(vaccX.first_dose(1:vacCumRow));
        vac = sum(vaccX.second_dose(vacRow));
        caseRow = ismember(cases.x_Week,weekk(ii));
        cl = strrep(cases{caseRow,6+jj},'<5','2.5');
        cl(cellfun(@isempty,cl)) = {'0'};
        if isempty(vacRow) || isequal(unique(cl),{'0'})
            effX(ii,jj) = nan;
        else
            effX(ii,jj) = (sum(cellfun(@str2num,cl))/vac)/...
                (sum(cases.Sum_positive_without_vaccination(caseRow))/(pop-vaccCum1));
        end
    end
end
% eff(eff > 100) = nan;
effX = 1-effX;
figure;
plot(effX)
set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
xtickangle(35)
grid on
set(gcf,'Color','w')
legend('1 week','2 weeks','3 weeks')
ylim([0 1])
set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)

%%
iAge = 6:9;
vaccX = vaccA(ismember(vaccA.age_group,ages(iAge)),:);
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
pop = sum(population(iAge(1):end));
clear eff60_2
for ii = 1:length(weekk)
    for jj = 1:3
        dates = datetime(weekk{ii}(1:10));
        dates = dates:dates+6+6;
        dates = dates-7*jj;
        
        vacRow = find(ismember(vaccX.date,dates)); 
        % & ismember(vaccA.age_group,ages(iAge)));
        % vacRow = -7:find(vaccA.date == datetime(weekk{ii}(1:10)))-1;
        % vacRow = vacRow-7*(jj-1);
        vacRow = vacRow(vacRow > 0);
        dateM = median(vaccX.date(vacRow));
        vacCumRow = find(vaccX.date == dateM,1,'last');
        vaccCum1 = sum(vaccX.first_dose(1:vacCumRow));
        vac = sum(vaccX.second_dose(vacRow));
        caseRow = ismember(cases.x_Week,weekk(ii));
        cl = strrep(cases{caseRow,6+jj},'<5','2.5');
        cl(cellfun(@isempty,cl)) = {'0'};
        if isempty(vacRow) || isequal(unique(cl),{'0'})
            eff60_2(ii,jj) = nan;
        else
            eff60_2(ii,jj) = (sum(cellfun(@str2num,cl))/vac)/...
                (sum(cases.Sum_positive_without_vaccination(caseRow))/(pop-vaccCum1));
        end
    end
end
% eff(eff > 100) = nan;
eff60_2 = 1-eff60_2;
figure;
plot(eff60_2)
set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
xtickangle(35)
grid on
set(gcf,'Color','w')
legend('1 week','2 weeks','3 weeks')
ylim([0 1])
set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)
