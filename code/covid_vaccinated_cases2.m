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
ages = unique(vaccA.age_group);

%%
iAge = 6:9;
vaccX = vaccA(ismember(vaccA.age_group,ages(iAge)),:);
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
pop = sum(population(iAge(1):end));
clear eff60
for ii = 1:length(weekk)
    date1 = datetime(weekk{ii}(1:10));
    vacc1 = zeros(7,1);
    for iDate = 1:7
        uvr = ismember(vaccX.date,date1+iDate-1);
        if sum(uvr) > 0
            vacc1(iDate,1) = sum(vaccX.first_dose(1:find(uvr,1,'last')));
        end
    end
    for jj = 1:3
        w = [1:6,7:-1:1];
        if jj == 1
            dates = date1-6:date1+5;
            w = [1:6,6:-1:1];
        else
            dates = date1-1-7*(jj-2);
            dates = dates-12:dates;
        end
%     end
% end   
        vrw = zeros(height(vaccX),1);
        
        for iDate = 1:length(dates)
            vr = ismember(vaccX.date,dates(iDate));
            if ~isempty(vr)
                vrw(vr) = w(iDate);
                %vacc1(iDate,1) = sum(vaccX.first_dose(1:find(vr,1,'last')));
            end
        end
                
%         vacRow = find(ismember(vaccX.date,dates)); 
        % & ismember(vaccA.age_group,ages(iAge)));
        % vacRow = -7:find(vaccA.date == datetime(weekk{ii}(1:10)))-1;
        % vacRow = vacRow-7*(jj-1);
%         vacRow = vacRow(vacRow > 0);
%         dateM = median(vaccX.date(vacRow));
%         vacCumRow = find(vaccX.date == dateM,1,'last');
%         vaccCum1 = sum(vaccX.first_dose(1:vacCumRow));
%         vaccCum1 = sum(vaccX.first_dose(ismember(vaccX.date,date1+3)));
        vac = sum(vaccX.second_dose.*vrw);
        caseRow = ismember(cases.x_Week,weekk(ii));
        cl = strrep(cases{caseRow,6+jj},'<5','2.5');
        cl(cellfun(@isempty,cl)) = {'0'};
        if sum(vrw) == 0
            eff60(ii,jj) = nan;
        else
            eff60(ii,jj) = (sum(cellfun(@str2num,cl))/vac)/...
                (sum(cases.Sum_positive_without_vaccination(caseRow))/sum(pop-vacc1));
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
