tt = webread('https://data.gov.il/api/3/action/datastore_search?resource_id=bd7b8fa9-7120-4e8d-933f-a1449dae8dad&limit=5000');
tt = struct2table(tt.result.records);
yy = tt;
yy(:,1:3) = [];
yy = cellfun(@(x) str2num(strrep(x,'<5','2.5')),yy{:,:});
ages = unique(tt.Age_group);

for ia = 1:length(ages)
    idx = find(ismember(tt.Age_group,ages(ia)));
    for col = 1:6
        for ja = 2:length(idx)-1
            if yy(idx(ja),col) == 2.5 && yy(idx(ja)+1,col) == 2.5 && yy(idx(ja)-1,col) == 2.5
                disp('fix')
                yy(idx(ja),col) = 1;
            end
        end
    end
end

% set1 = yy == 2.5;
% set1(2:end,:) = set1(2:end,:) & set1(1:end-1,:);
% yy(set1) = 1;
dateAll = cellfun(@(x) datetime(x(1:10))+3,tt.Week);
date = unique(dateAll);
for iDate = 1:length(date)
    row = ismember(dateAll,date(iDate)) & ismember(tt.Age_group,ages(6:8));
    old(iDate,1:4) = sum(yy(row,[7,5,9,8]-3));
end

figure;
plot(date,old)
legend(strrep(tt.Properties.VariableNames([7,5,9,8]),'_',' '))

json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=57410611-936c-49a6-ac3c-838171055b1f&limit=1000000');
json = strrep(json,'<15','7');
json = jsondecode(json);
vaccA = struct2table(json.result.records);
vaccA.first_dose = cellfun(@str2num,vaccA.first_dose);
vaccA.second_dose = cellfun(@str2num,vaccA.second_dose);
vaccA.VaccinationDate = datetime(vaccA.VaccinationDate);
vaccA.Properties.VariableNames{2} = 'date';
% for ii = 1
    

