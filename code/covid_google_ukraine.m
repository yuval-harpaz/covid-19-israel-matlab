function covid_google_ukraine

cd ~/covid-19-israel-matlab/data/
% [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
% unzip('tmp.zip','tmp')
% !rm tmp.zip
dateCheck = dir('tmp/2021_BF_Region_Mobility_Report.csv');
if now-datenum(dateCheck.date) > 7
    [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
    unzip('tmp.zip','tmp')
    !rm tmp.zip
end
cd tmp


t2020 = readtable(['2020_UA_Region_Mobility_Report.csv']);
t2021 = readtable(['2021_UA_Region_Mobility_Report.csv']);
t2022 = readtable(['2022_UA_Region_Mobility_Report.csv']);
% if iscell(t2020.sub_region_1(1))
%     t = [t2020(cellfun(@isempty,t2020.sub_region_1),:);t2021(cellfun(@isempty,t2021.sub_region_1),:)];
%     if iscell(t.metro_area(1))
%         t = t(cellfun(@isempty,t.metro_area),:);

t = [t2020;t2021;t2022];
Kiev = t(contains(t.metro_area,'Kyiv'),:);
Ukraine = t(~contains(t.metro_area,'Kyiv'),:);
date = Ukraine.date;
if ~isequal(unique(date),date)
    error('dates not unique or not sorted')
end

data = {Ukraine,Kiev;'Ukraine','Kiev'};
figure('units','normalized','position',[0,0,1,1]);
for sp = 1:2
    mob = data{1,sp}{:,10:end};
    mob = movmean(movmedian(mob,[3 3]),[3 3]);
    subplot(2,1,sp)
    plot(date,mob,'linewidth',1);
    xlim([t.date(1) datetime('today')])
    box off
    grid on
    ylabel('change compared to baseline (%)')
    title(['Google mobility report, ',data{2,sp}])
    xtickformat('MMM-yy')
    set(gca,'XTick',datetime(2020,3:50,1),'FontSize',13)
    xtickangle(90)
    if sp == 1
        legend(strrep(strrep(t.Properties.VariableNames(10:end),'_',' '),' percent change from baseline',''));
    end
end
set(gcf,'Color','w')
%%
% yy(yy < 1/3) = 0;
% 
% for ii = 2:length(yy)
%     d1(ii,1:size(yy,2)) = yy(ii,:)./yy(ii-1,:);
% end
% for ii = 2:length(yy)-1
%     d2(ii,1:size(yy,2)) = (yy(ii+1,:)-yy(ii-1,:))./yy(ii-1,:)./2+1;
% end
% d1(isinf(d1)) = nan;
% d1(d1 == 0) = 1;
% d1(isnan(d1)) = 1;
% d1s = movmean(d1,[3 3],'omitnan');
% figure;
% plot(timeVector,d1s(:,iMust))
% hold on
% plot(t.date(1:iEnd),(glob(:,11) < -25)/10+1)
