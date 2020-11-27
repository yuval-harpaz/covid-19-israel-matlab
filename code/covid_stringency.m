function covid_stringency(country,download)
% covid_stringency({'SVN','SI'});
% covid_stringency({'CZE','CZ'});
if ~exist('country')
    country = [];
end
if isempty(country)
    country = {'Israel','IL'};
end
if ~exist('download','var')
    download = false;
end
cd ~/covid-19-israel-matlab/data

% d = dir('tmp.json');
% if length(d) == 1
%     if dateshift(datetime(d.date),'start','day') == datetime('today')
%         download = false;
%     end
% end
if download       
%     [~,~] = system('wget -O tmp.json https://covidtrackerapi.bsg.ox.ac.uk/api/v2/stringency/date-range/2020-02-15/2020-11-11');
    [~,~] = system('wget -O tmp1.csv https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv');
end
% fid = fopen('tmp.json','r');
% json = fread(fid);
% fclose(fid)
% json = jsondecode(native2unicode(json)');
ox = readtable('tmp1.csv');
dates = str(ox.Date(contains(ox.CountryName,country{1}) & cellfun(@isempty, ox.RegionName)));
date = datetime(dates,'InputFormat','yyyyMMdd');
% deaths = ox.ConfirmedDeaths(ismember(ox.CountryName,country{1}));

[dataMatrix] = readCoronaData('deaths');
[~,timeVector,mergedData] = processCoronaData(dataMatrix);
if strcmp(country{1},'United States')
    mergedData(ismember(mergedData(:,1),'US'),1) = {'United States'};
end
[isx,idx] = ismember(date,timeVector);
deaths = zeros(length(date),1);
deaths(isx) = mergedData{contains(mergedData(:,1),country{1}),2}(idx(isx))';
deaths(deaths == 0) = nan;  % end of vector?
% deaths = deaths(ismember(timeVector,date));
stringency = ox.StringencyIndex(contains(ox.CountryName,country{1}) & cellfun(@isempty, ox.RegionName));
% dates = fieldnames(json.data);
% date = datetime(strrep(strrep(dates,'x',''),'_','-'));
% for ii = 1:length(date)
%     if isfield(eval(['json.data.',dates{ii}]),codes{1})
%         dat = eval(['json.data.',dates{ii},'.',codes{1}]);
%         if isempty(dat.deaths)
%             deaths(ii,1) = nan;
%         else
%             deaths(ii,1) = dat.deaths;
%         end
%         if isempty(dat.confirmed)
%             confirmed(ii,1) = nan;
%         else
%             confirmed(ii,1) = dat.confirmed;
%         end
%         stringency(ii,1) = dat.stringency;
%     else
%         deaths(ii,1) = deaths(ii-1,1);
%         confirmed(ii,1) = confirmed(ii-1,1);
%         stringency(ii,1) = stringency(ii-1,1);
%     end
% end

t = table(date,stringency,deaths);
if ismember('IL',country)
    t.deaths(ismember(t.date,datetime(2020,8,20))) = nan;
elseif ismember('AR',country)
    t.deaths(275) = nan;
end
% t = t(1:find(~isnan(t.stringency),1,'last')-1,:);
t(isnan(t.stringency),:) = [];
mob = readtable(['~/Downloads/Region_Mobility_Report_CSVs/2020_',country{2},'_Region_Mobility_Report.csv']);
mob = mob(1:find(~cellfun(@isempty,mob.sub_region_1),1)-1,8:end);
[isx,idx] = ismember(t.date,mob.date);
figure;
fill([t.date;flipud(t.date)],[t.stringency;-flipud(t.stringency)],[0.9,0.9,0.9],'linestyle','none')
hold on
colorset;
plot(mob.date,movmedian(mob{:,2:end},[3 3]))
plot(t.date(2:end),diff(t.deaths)./max(diff(t.deaths))*100,'k')
legend('מדד צעדי המנע של אוקספורד','חנויות','מכולות','פארקים','תחנות אוטובוס','עבודה','בית','תמותה (מנורמל)')
title({'השוואה בין המדדים של אוקספורד לגוגל לחומרת צעדי המנע',country{1}})
grid on
box off
set(gcf,'Color','w')
