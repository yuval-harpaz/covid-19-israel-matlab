cd /home/innereye/covid-19-israel-matlab/data/Israel
% txt = urlread('https://data.gov.il/dataset/covid-19/resource/9b623a64-f7df-4d0c-9f57-09bd99a88880');
% strfind(txt,'csv')
%  ! wget -O tmp.csv https://data.gov.il/dataset/covid-19/resource/9b623a64-f7df-4d0c-9f57-09bd99a88880/download/cases-among-vaccinated-10.csv
% cases = readtable('tmp.csv','Delimiter',',');
cases = readtable('~/Downloads/cases-among-vaccinated-10.csv','Delimiter',',');
weekk = unique(cases.x_Week);
clear y
for ii = 1:length(weekk)
    for jj = 1:4
        cl = strrep(cases{ismember(cases.x_Week,weekk(ii)),2+jj},'<5','2.5');
        cl(cellfun(@isempty,cl)) = {'0'};
        y(ii,jj) = sum(cellfun(@str2num,cl));
    end
end

col = jet(5);
col = flipud(col(:,[1,3,2]));
col = col([1,3:end],:);
figure;
h = plot(y);
for ii = 1:4
    h(ii).Color = col(ii,:);
end
legend('1 week','2 weeks','3 weeks','4 weeks')
set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
xtickangle(35)
grid on
set(gcf,'Color','w')
title('vaccinated cases: week of positive test from dose I (color) by date (x-axis)')
ylabel('cases')

yy = [y(1:end-3,1),y(2:end-2,2),y(3:end-1,3),y(4:end,4)];
figure;
hh = plot(yy./sum(yy,2))
for ii = 1:4
    hh(ii).Color = col(ii,:);
end

%%
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=57410611-936c-49a6-ac3c-838171055b1f&limit=1000000');
json = strrep(json,'<15','7');
json = jsondecode(json);
vaccA = struct2table(json.result.records);
vaccA.first_dose = cellfun(@str2num,vaccA.first_dose);
vaccA.second_dose = cellfun(@str2num,vaccA.second_dose);
vaccA.VaccinationDate = datetime(vaccA.VaccinationDate);
vaccA.Properties.VariableNames{2} = 'date';
%%
json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
json = jsondecode(json);
t = struct2table(json);
date = datetime(strrep(t.Day_Date,'T00:00:00.000Z',''));
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');

clear eff
for ii = 1:length(weekk)
    for jj = 1:3
        vacRow = find(date == datetime(weekk{ii}(1:10)))-7:find(date == datetime(weekk{ii}(1:10)))-1;
        vacRow = vacRow-7*(jj-1);
        vacRow = vacRow(vacRow > 0);
        vac = sum(t.vaccinated_seconde_dose(vacRow));
        caseRow = ismember(cases.x_Week,weekk(ii));
        cl = strrep(cases{caseRow,6+jj},'<5','2.5');
        cl(cellfun(@isempty,cl)) = {'0'};
        if isempty(vacRow)
            eff(ii,jj) = nan;
        else
            eff(ii,jj) = (sum(cellfun(@str2num,cl))/vac)/...
                (sum(cases.Sum_positive_without_vaccination(caseRow))/(9500000-t.vaccinated_cum(vacRow(min(4,length(vacRow))))));
        end
    end
end
eff(eff > 100) = nan;
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