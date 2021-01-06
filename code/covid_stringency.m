function covid_stringency(country,download,heb)
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
heb = IEdefault('heb',true);
cd ~/covid-19-israel-matlab/data

if download       
%     [~,~] = system('wget -O tmp.json https://covidtrackerapi.bsg.ox.ac.uk/api/v2/stringency/date-range/2020-02-15/2020-11-11');
    [~,~] = system('wget -O tmp1.csv https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv');
end
ox = readtable('tmp1.csv');
dates = str(ox.Date(contains(ox.CountryName,country{1}) & cellfun(@isempty, ox.RegionName)));
date = datetime(dates,'InputFormat','yyyyMMdd');
% deaths = ox.ConfirmedDeaths(ismember(ox.CountryName,country{1}));

[dataMatrix] = readCoronaData('deaths');
[~,timeVector,mergedData] = processCoronaData(dataMatrix);
[dataMatrix] = readCoronaData('confirmed');
[~,~,mergedDataC] = processCoronaData(dataMatrix);
if strcmp(country{1},'United States')
    mergedData(ismember(mergedData(:,1),'US'),1) = {'United States'};
end
[isx,idx] = ismember(date,timeVector);
deaths = zeros(length(date),1);
deaths(isx) = mergedData{contains(mergedData(:,1),country{1}),2}(idx(isx))';
deaths(deaths == 0) = nan;  % end of vector?
cases = zeros(length(date),1);
cases(isx) = mergedDataC{contains(mergedDataC(:,1),country{1}),2}(idx(isx))';
cases(cases == 0) = nan;  % end of vector?
% deaths = deaths(ismember(timeVector,date));
stringency = ox.StringencyIndex(contains(ox.CountryName,country{1}) & cellfun(@isempty, ox.RegionName));

t = table(date,stringency,deaths,cases);
if ismember('IL',country)
    t.deaths(ismember(t.date,datetime(2020,8,20))) = nan;
elseif ismember('AR',country)
    t.deaths(275) = nan;
end
% t = t(1:find(~isnan(t.stringency),1,'last')-1,:);
t(isnan(t.stringency),:) = [];
try
    mob = readtable(['~/Downloads/Region_Mobility_Report_CSVs/2020_',country{2},'_Region_Mobility_Report.csv']);
catch
    mob = readtable(['tmp/2020_',country{2},'_Region_Mobility_Report.csv']);
end
mob = mob(1:find(~cellfun(@isempty,mob.sub_region_1),1)-1,8:end);
[isx,idx] = ismember(t.date,mob.date);
figure('units','normalized','position',[0.1,0.1,0.6,0.8]);
fill([t.date;flipud(t.date)],[t.stringency;-flipud(t.stringency)],[0.9,0.9,0.9],'linestyle','none')
hold on
colorset;
plot(mob.date,movmedian(mob{:,2:end},[3 3]))
plot(t.date(2:end),movmean(diff(t.deaths)./max(diff(t.deaths))*100,[3 3],'omitnan'),'k')
plot(t.date(2:end),movmean(diff(t.cases)./max(diff(t.cases))*100,[3 3],'omitnan'),'m')
grid on
box off
set(gcf,'Color','w')
xtickformat('MMM')
set(gca,'XTick',datetime(2020,3:25,1),'FontSize',13)
xlim([datetime(2020,2,1) datetime('tomorrow')])
if heb
   legend('מדד צעדי המנע של אוקספורד','חנויות','מכולות','פארקים','תחנות אוטובוס','עבודה','בית','נפטרים (מנורמל)','מאומתים (מנורמל)','location','northwest')
    title({'צעדי המנע מול התחלואה והתמותה',country{1}})
else
    legend('oxford stringency index','retail','grocery','parks','transit','workplaces','residential','deaths (normalized)','cases (normalized))','location','northwest')
    title({'Oxford Stringency and Google Mobility indices vs Deaths and Cases',country{1}})
end
 
    