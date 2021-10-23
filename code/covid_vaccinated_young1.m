
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=8a51c65b-f95a-4fb8-bd97-65f47109f41f&limit=100000');
json = jsondecode(json);
t = struct2table(json.result.records);

cells = t{:,5:end};
cells(cellfun(@isempty,cells)) = {'0'};
cells(cellfun(@(x) strcmp(x,'<5'),cells)) = {'2.5'};
t{:,5:end} = cells;  % cellfun(@str2num,cells);
tH = t(contains(t.Type_of_event,'Hosp'),:);
% tD = t(contains(t.Type_of_event,'Dea'),:);
weekk = unique(t.Week);
wk = datetime(cellfun(@(x) x(14:end),weekk,'UniformOutput',false));
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
% vaccA.age_group = strrep(strrep(vaccA.age_group,'80-89','80+'),'90+','80+');
ages = unique(vaccA.age_group);

% population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
population = [3229633;1319364;1207243;1110965;874608;747217;526929;238729;58687];
% pop = sum(population(iAge(1):end));
% tt = {tD;tH};
% tit = {'Vaccine Effectiveness for Deaths';'Vaccine Effectiveness for Hospitalizations'};


for iAge = 1:length(ages)
    vaccX = vaccA(ismember(vaccA.age_group,ages(iAge)),:);
    pop = population(iAge);
    for ii = 1:length(weekk)
        date1 = datetime(weekk{ii}(1:10));
        vacc = zeros(7,2);
        for iDate1 = 1:7  % N vaccinated by date
            uvr = ismember(vaccX.date,date1+iDate1-2);  % rows with relevant dates
            if sum(uvr) > 0
                vacc(iDate1,1) = sum(vaccX.first_dose(1:find(uvr,1,'last')));
                vacc(iDate1,2) = sum(vaccX.second_dose(1:find(uvr,1,'last')));
                vacc(iDate1,3) = sum(vaccX.third_dose(1:find(uvr,1,'last')));
            end
        end
        w = 7:-1:1;  % weight per date (person-days)
        dates = date1-1:date1+5;
        vrw = zeros(height(vaccX),1);
        
        for iDate = 1:length(dates)
            vr = ismember(vaccX.date,dates(iDate));
            if ~isempty(vr)
                vrw(vr) = w(iDate);
                %vacc1(iDate,1) = sum(vaccX.first_dose(1:find(vr,1,'last')));
            end
        end
        vac = sum(vaccX.first_dose.*vrw);
        vac(:,2) = sum(vaccX.second_dose.*vrw);
        vac(:,3) = sum(vaccX.third_dose.*vrw);
        caseRow = ismember(tH.Week,weekk(ii)) & ismember(tH.Age_group,ages(iAge));
        cl = tH{caseRow,4+1};
        cl(:,2) = tH{caseRow,4+2};
        cl(:,3) = tH{caseRow,4+3};
        %         cl = strrep(cases{caseRow,6+jj},'<5','2.5');
        %         cl(cellfun(@isempty,cl)) = {'0'};
        if sum(vrw) == 0
            eff60(ii,iAge,kk) = nan; %#ok<*SAGROW>
            evtVacc(ii,iAge,kk) = nan;
            persondaysVacc(ii,iAge,kk) = nan;
            evtNoVacc(ii,iAge,kk) = nan;
            persondaysNoVacc(ii,iAge,kk) = nan;
        else
            for kk = 1:3 % shot
                eff60(ii,iAge,kk) = (sum(cellfun(@str2num,cl(:,kk)))/vac(kk))/...
                    (sum(cellfun(@str2num,tH.event_for_not_vaccinated(caseRow)))/sum(pop-vacc(:,kk)));
                evtVacc(ii,iAge,kk) = sum(cellfun(@str2num,cl(:,kk)));
                persondaysVacc(ii,iAge,kk) = vac(kk);
                evtNoVacc(ii,iAge,kk) = sum(cellfun(@str2num,tH.event_for_not_vaccinated(caseRow)));
                persondaysNoVacc(ii,iAge,kk) = sum(pop-vacc(:,kk));
            end
        end
    end
    % eff(eff > 100) = nan;
    %     sum
    %     eff60_ = 100-eff60;
end

figure;
plot(wk,eff60(:,:,3))
ylim([0 100])

figure
y1 = [sum(evtVacc(:,:,1))',sum(evtNoVacc(:,:,1))'];
bar(y1)
set(gca,'XTickLabel',ages,'xtick',1:length(weekk))
legend('vacc','not vacc','location','northwest')
xtickangle(90)
grid on
set(gcf,'Color','w')
%     legend('dose I','dose II','location','northwest')
%     ylim([0 100])
%     set(gca,'YTick',0:10:100,'YTickLabel',0:10:100)
%     xlim([1,19])
ylabel('events')
title(tit{it})
y2 = y1./[sum(persondaysVacc(:,:,1))',sum(persondaysNoVacc(:,:,1))'];
subplot(2,1,2)
bar(y2)
