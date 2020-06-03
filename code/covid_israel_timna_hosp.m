function covid_israel_timna_hosp
if ~exist('plt','var')
    plt = false;
end
cd ~/covid-19_data_analysis/

json = urlread('https://data.gov.il/api/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd');
fid = fopen('data/Israel/corona_hospitalization_ver_001.json','w');
fwrite(fid,json);
fclose(fid);

json = strrep(json,'NULL','0');
json = strrep(json,'<15','0');
struc = jsondecode(json);

recordsCell = struct2cell(struc.result.records)';
date = datetime(recordsCell(:,2));
records = table(date);
varName = {'hospitalized','hosp_female_percent','hosp_age_mean','hosp_age_sd',...
    'on_ventilator','vent_female_percent','vent_age_mean','vent_age_sd',...
    'mild','mild_female_percent','mild_age_mean','mild_age_sd',...
    'severe','severe_female_percent','severe_age_mean','severe_age_sd',...
    'critical','crit_female_percent','crit_age_mean','crit_age_sd'};
for ii = 1:length(varName)
    eval(['records.',varName{ii},' = cellfun(@str2num,recordsCell(:,ii+2));'])
    eval(['records.',varName{ii},'(records.',varName{ii},' == 0) = nan;']);
end
nanwritetable(records,'data/Israel/corona_hospitalization_ver_001.csv');
% if plt
%     figure;
%     plot(records.date,records.mild_female_percent)
%     hold on
%     plot(records.date,records.hosp_female_percent)
%     plot(records.date,records.severe_female_percent)
%     plot(records.date,records.crit_female_percent)
%     legend('mild','hospitalized','severe','critical')
% end

% gender
female = records.vent_female_percent(end)*records.on_ventilator(end)/100;
female = [female;records.crit_female_percent(end)*records.critical(end)/100-female;...
    records.severe_female_percent(end)*records.severe(end)/100;...
    records.mild_female_percent(end)*records.mild(end)/100];
male = (100-records.vent_female_percent(end))*records.on_ventilator(end)/100;
male = [male;(100-records.crit_female_percent(end))*records.critical(end)/100-male;...
    (100-records.severe_female_percent(end))*records.severe(end)/100;...
    (100-records.mild_female_percent(end))*records.mild(end)/100];
y = round([male,female]);
cm = [231,71,51;244,162,97;233,196,106;42,157,143]./255;
zer = sum(y,2) == 0;
cm(zer,:) = [];
[~,legendIn] = max(sum(y > 0));
ratio = sqrt(sum(y));
ratio = max(ratio)./ratio;
per = round(100*sum(y)/sum(sum(y)));
titles = {['מאושפזים ',str(per(1)),'%'],['מאושפזות ',str(per(2)),'%']};
fig = figure;
for ip = 1:2
    % bar([male,female]','stack')
    subplot(1,2,ip)
    ph{ip} = pie(round(y(:,ip)));
    xlim([-ratio(ip) ratio(ip)])
    title(titles{ip})
end
colormap(cm);
ih = [1,3,5,7];
ih(zer) = [];
legText = {'מונשמים','קשה','בינוני','קל'};
legend(ph{legendIn}(ih),legText,[350,275,10,10])
saveas(fig,'docs/Israel_gender.png')
%% regions in israel

% json = urlread('https://data.gov.il/api/action/datastore_search?resource_id=05571ef1-8f23-4a04-bd1c-0a59dec013fd&limit=100000000');
% % fid = fopen('data/Israel/corona_hospitalization_ver_001.json','w');
% % fwrite(fid,json);
% % fclose(fid);
% json = strrep(json,'NULL','0');
% json = strrep(json,'<15','0');
% struc = jsondecode(json);
% %struc.result.records(:).date = 
% %recordsCell = struct2cell(struc.result.records)';
% rowDate = datetime(cellfun(@(x) x(1:10),{struc.result.records.date}','UniformOutput',false));
% rowAccum = cellfun(@str2num,{struc.result.records(:).accumulated_hospitalized}');
% rowNew = [struc.result.records(:).new_hospitalized_on_date]';
% date = unique(rowDate);
% for ii = 1:length(date)
%     accum(ii,1) = sum(rowAccum(rowDate == date(ii)));
%     new(ii,1) = sum(rowNew(rowDate == date(ii)));
% end
% tAccum = table(date,accum,new);
% rowTownCode = [struc.result.records(:).town_code]';
% % רחובות
% rowTown = {struc.result.records(:).town}';
% town = unique(rowTown);
% clear acc accRest
% for iTown = 1:length(town)
%     tt = struct2table(struc.result.records(ismember(rowTown,town{iTown})));
%     tt.date = datetime(cellfun(@(x) x(1:10),tt.date,'UniformOutput',false));
%     if isequal(unique(tt.date),sort(tt.date))
%         [~,idx] = ismember(tt.date,date);
%         acc(1:length(date),iTown) = nan;
%         acc(idx,iTown) = cellfun(@str2num, tt.accumulated_hospitalized);
%         accRest (1,iTown) = nan;
%     else
%         try
%             isAgas = ~cellfun(@isempty, tt.agas_code);
%             ttRest = tt(isAgas,:);
%             tt(isAgas,:) = [];
%             if ~isequal(unique(tt.date),sort(tt.date))
%                 error('not unique');
%             end
%             [~,idx] = ismember(tt.date,date);
%             acc(1:length(date),iTown) = nan;
%             acc(idx,iTown) = cellfun(@str2num, tt.accumulated_hospitalized);
%             accRest(1,iTown) = sum(cellfun(@str2num,ttRest.accumulated_hospitalized));
%         catch
%             acc(1:length(date),iTown) = nan;
%             for id = 1:length(date)
%                 a = tt.accumulated_hospitalized(ismember(tt.date,date(id)));
%                 if ~isempty(a)
%                     acc(id,iTown) = sum(cellfun(@str2num,a));
%                 end
%             end
%             accRest(1,iTown) = nansum(acc(:,iTown));
%         end
%     end
% end
% 
% 
% 
% reh = struct2table(struc.result.records(ismember(rowTown,'רחובות')));
% [~,order] = sort(reh.date);
% reh = reh(order,:);
% agas = reh.agas_code;
% agas(cellfun(@isempty,agas)) = [];
% agas = cellfun(@(x) x,agas)
% agas = unique(agas);
% reh.date = datetime(cellfun(@(x) x(1:10),reh.date,'UniformOutput',false));
% clear accum new
% for ii = 1:length(date)
%     accumR1(ii,1) = reh.accumulated_hospitalized(reh.date == date(ii) & cellfun();
%     new(ii,1) = rowNew(rowDate == date(ii) & rowTownCode == 8400);
% end
% rehovot = table(date,accum,new);
% 
% records = table(date);
% varName = {'hospitalized','hosp_female_percent','hosp_age_mean','hosp_age_sd',...
%     'on_ventilator','vent_female_percent','vent_age_mean','vent_age_sd',...
%     'mild','mild_female_percent','mild_age_mean','mild_age_sd',...
%     'severe','severe_female_percent','severe_age_mean','severe_age_sd',...
%     'critical','crit_female_percent','crit_age_mean','crit_age_sd'};
% for ii = 1:length(varName)
%     eval(['records.',varName{ii},' = cellfun(@str2num,recordsCell(:,ii+2));'])
%     eval(['records.',varName{ii},'(records.',varName{ii},' == 0) = nan;']);
% end


%%
% list = readtable('~/covid-19_data_analysis/data/Israel/Israel_ministry_of_health.csv');
% 
% figure;
% idx = ~isnan(list.on_ventilator);
% plot(list.date(idx),list.on_ventilator(idx),'r')
% hold on
% v =  cellfun(@(x) str2num(strrep(x,'<15','0')),t.on_ventilator);
% plot(t.date,v,'g')
% figure;
% idx = ~isnan(list.critical);
% plot(list.date(idx),list.critical(idx),'r')
% hold on
% c =  cellfun(@(x) str2num(strrep(x,'<15','0')),t.critical);
% plot(t.date,c,'g')
% figure;
% idx = ~isnan(list.severe);
% plot(list.date(idx),list.severe(idx),'r')
% hold on
% plot(t.date,cellfun(@(x) str2num(strrep(strrep(x,'NULL','0'),'<15','0')),t.severe),'g')
% figure;
% 
% 
% for ii = 1:length(t.Properties.VariableNames)
%     if is