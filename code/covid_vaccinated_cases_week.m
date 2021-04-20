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
clear ins*
for ii = 1:length(weekk)
    date1 = datetime(weekk{ii}(1:10));
%     vacc1 = zeros(7,1);
%     for iDate = 1:7
%         uvr = ismember(vaccX.date,date1+iDate-1);
%         if sum(uvr) > 0
%             vacc1(iDate,1) = sum(vaccX.first_dose(1:find(uvr,1,'last')));
%         end
%     end
    for jj = 1:3
        if jj == 1
            dates = date1-6:date1+5;
        else
            dates = date1-1-7*(jj-2);
            dates = dates-12:dates;
        end
        vr = ismember(vaccX.date,dates);
        vac2 = sum(vaccX.second_dose(vr));
        vac1 = sum(vaccX.first_dose(vr));
        caseRow = ismember(cases.x_Week,weekk(ii));
        cl2 = strrep(cases{caseRow,6+jj},'<5','2.5');
        cl2(cellfun(@isempty,cl2)) = {'0'};
        cl1 = strrep(cases{caseRow,2+jj},'<5','2.5');
        cl1(cellfun(@isempty,cl1)) = {'0'};
        if isequal(unique(cl2),{'0'})
            ins2(ii,jj) = nan;
        else
            ins2(ii,jj) = sum(cellfun(@str2num,cl2))/vac2;
        end
        ins1(ii,jj) = sum(cellfun(@str2num,cl1))/vac1;
    end
end

figure;
h(1:3) = plot(ins1*100,'--');
hold on
colorset;
h(4:6) = plot(ins2*100,'-');
set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
xtickangle(35)
grid on
set(gcf,'Color','w')
legend('1 week from dose I','2 weeks from dose I','3 weeks from dose I',...
    '1 week from dose II','2 weeks from dose II','3 weeks from dose II','location','northeast')
ylabel('% infected')
col = [0.882,0.341,0.349;0.949,0.557,0.169;0.349,0.631,0.31];
for ii = 1:3
    h(ii).Color = col(ii,:);
    h(ii+3).Color = col(ii,:);
end
title({'The ratio of vaccinated with positive result','by time from vaccination'})
%% 
figure;
h(1:3) = plot(ins1./[6,7,7]*7*100,'--');
hold on
colorset;
h(4:6) = plot(ins2./[6,7,7]*7*100,'-');
set(gca,'XTickLabel',weekk,'xtick',1:length(weekk))
xtickangle(35)
grid on
set(gcf,'Color','w')
legend('1 week from dose I','2 weeks from dose I','3 weeks from dose I',...
    '1 week from dose II','2 weeks from dose II','3 weeks from dose II','location','northeast')
ylabel('% infected')
% col = [0.882,0.341,0.349;0.949,0.557,0.169;0.349,0.631,0.31];
for ii = 1:3
    h(ii).Color = col(ii,:);
    h(ii+3).Color = col(ii,:);
end

% ylim([0 1])
% set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)


%%
