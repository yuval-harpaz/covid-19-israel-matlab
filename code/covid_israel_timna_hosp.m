


% https://data.gov.il/dataset/f54e79b2-3e6b-4b65-a857-f93e47997d9c/resource/e4bf0ab8-ec88-4f9b-8669-f2cc78273edd/download/corona_hospitalization_ver_001.csv
cd 
tc = readtable('~/covid-19_data_analysis/data/Israel/covid19-data-israel.xlsx');
tc.Properties.VariableNames = {'date','tests','confirmed','hospitalized','critical','ventilated','deceased'};
list = readtable('~/covid-19_data_analysis/data/Israel/Israel_ministry_of_health.csv');
for ii = 1:height(tc)
    idx = find(ismember(dateshift(list.date,'start','day'),tc.date(ii)),1,'last');
    if ~isempty(idx)
        tc.hosp2(ii) = list.hospitalized(idx);
    end
end

t = readtable('/media/innereye/1T/Docs/corona_hospitalization_ver_001.csv');
for ii = 1:height(tc)
    idx = find(ismember(t{:,1},tc.date(ii)));
    if ~isempty(idx)
        tc.hosp3(ii) = t{idx,2};
    end
end

t.Properties.VariableNames = {'date','hospitalized','hosp_female_percent','hosp_age_mean','hosp_age_sd',...
    'on_ventilator','vent_female_percent','vent_age_mean','vent_age_sd',...
    'mild','mild_female_percent','mild_age_mean','mild_age_sd',...
    'severe','severe_female_percent','severe_age_mean','severe_age_sd',...
    'critical','crit_female_percent','crit_age_mean','crit_age_sd'};
figure;
idx = ~isnan(list.on_ventilator);
plot(list.date(idx),list.on_ventilator(idx),'r')
hold on
v =  cellfun(@(x) str2num(strrep(x,'<15','0')),t.on_ventilator);
plot(t.date,v,'g')
figure;
idx = ~isnan(list.critical);
plot(list.date(idx),list.critical(idx),'r')
hold on
c =  cellfun(@(x) str2num(strrep(x,'<15','0')),t.critical);
plot(t.date,c,'g')
figure;
idx = ~isnan(list.severe);
plot(list.date(idx),list.severe(idx),'r')
hold on
plot(t.date,cellfun(@(x) str2num(strrep(strrep(x,'NULL','0'),'<15','0')),t.severe),'g')
figure;


for ii = 1:length(t.Properties.VariableNames)
    if is