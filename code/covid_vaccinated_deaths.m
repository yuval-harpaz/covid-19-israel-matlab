
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=8a51c65b-f95a-4fb8-bd97-65f47109f41f&limit=100000');
json = jsondecode(json);
t = struct2table(json.result.records);

cells = t{:,5:end};
cells(cellfun(@isempty,cells)) = {'0'};
cells(cellfun(@(x) strcmp(x,'<5'),cells)) = {'2.5'};
t{:,5:end} = cells;  % cellfun(@str2num,cells);
tH = t(contains(t.Type_of_event,'Hosp'),:);
tD = t(contains(t.Type_of_event,'Dea'),:);
weekk = unique(t.Week);
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


vaccX = vaccA(ismember(vaccA.age_group,ages(iAge)),:);
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
pop = sum(population(iAge(1):end));
tt = {tD;tH};
tit = {'Vaccine Effectiveness for Deaths';'Vaccine Effectiveness for Hospitalizations'};
figure;
for it = 1:2
    clear eff60
    for ii = 1:length(weekk)
        date1 = datetime(weekk{ii}(1:10));
        vacc = zeros(7,2);
        for iDate1 = 1:7  % N vaccinated by date
            uvr = ismember(vaccX.date,date1+iDate1-2);  % rows with relevant dates
            if sum(uvr) > 0
                vacc(iDate1,1) = sum(vaccX.first_dose(1:find(uvr,1,'last')));
                vacc(iDate1,2) = sum(vaccX.second_dose(1:find(uvr,1,'last')));
            end
        end
        %     for jj = 1:2
        w = 7:-1:1;  % weight per date (person-days)
        
        dates = date1-1:date1+5;
        %             w = [1:6,6:-1:1];
        %         else
        %             dates = date1-1-7*(jj-2);
        %             dates = dates-12:dates;
        %         end
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
        caseRow = ismember(tt{it}.Week,weekk(ii)) & ismember(tt{it}.Age_group,ages(iAge));
        cl = tt{it}{caseRow,4+1};
        cl(:,2) = tt{it}{caseRow,4+2};
        %         cl = strrep(cases{caseRow,6+jj},'<5','2.5');
        %         cl(cellfun(@isempty,cl)) = {'0'};
        if sum(vrw) == 0
            eff60(ii,kk) = nan;
            %             ppv60(ii,jj) = nan;
            %             ppu60(ii,jj) = nan;
            %             vv60(ii,jj) = nan;
            %             uu60(ii,jj) = nan;
        else
            for kk = 1:2
                eff60(ii,kk) = (sum(cellfun(@str2num,cl(:,kk)))/vac(kk))/...
                    (sum(cellfun(@str2num,tt{it}.event_for_not_vaccinated(caseRow)))/sum(pop-vacc(:,kk)));
                %                 ppv60(ii,jj) = sum(cellfun(@str2num,cl(:,kk)))/vac;
                %                 ppu60(ii,jj) = sum(cellfun(@str2num,tD.event_for_not_vaccinated(caseRow)))/sum(pop-vacc1);
                %                 vv60(ii,jj) = sum(cellfun(@str2num,cl(:,kk)));
                %                 uu60(ii,jj) = sum(cellfun(@str2num,tD.event_for_not_vaccinated(caseRow)));
            end
        end
    end
    % eff(eff > 100) = nan;
    eff60_ = 100-eff60;
    subplot(2,1,it)
    plot(eff60_)
    set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
    xtickangle(35)
    grid on
    set(gcf,'Color','w')
    legend('dose I','dose II','location','northwest')
    ylim([0 100])
    set(gca,'YTick',0:10:100,'YTickLabel',0:10:100)
    xlim([1,19])
    ylabel('VE (%)')
    
    title(tit{it})
end