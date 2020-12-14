% function covid_google_us_cities
cd ~/covid-19-israel-matlab/data/
dateCheck = dir('tmp/2020_BF_Region_Mobility_Report.csv');
if now-datenum(dateCheck.date) > 3
    [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
    unzip('tmp.zip','tmp')
    !rm tmp.zip
end
cd tmp
t = readtable('2020_US_Region_Mobility_Report.csv');

subregion2 = {'New York','Los Angeles','Chicago','Houston','Phoenix','Philadelphia','San Antonio','San Diego','Dallas','San Jose'}';
subregion2(:,2) = subregion2;
subregion2(3,2:3) = {'Cook','Illinois'};
subregion2([4,9],3) = {'Texas'};
subregion2{5,2} = 'Maricopa';
subregion2{7,2} = 'Bexar';
subregion2{10,2} = 'Santa Clara';
% clear county %= cell(length(subregion2),2);
for ii = 1:length(subregion2)
    if isempty(subregion2{ii,3})
        idx = find(contains(t.sub_region_2,subregion2{ii,2}),1);
        if ~isempty(idx)
            subregion2(ii,3) = t{idx,3};
        end
    end
end
iEnd = find(cellfun(@isempty,t.sub_region_1),1,'last');
date = t.date(1:iEnd);
glob = nan(length(date),length(subregion2));
figure;
for ii = 1:length(subregion2)
    row = contains(t.sub_region_2,subregion2{ii,2}) & contains(t.sub_region_1,subregion2{ii,3});
    globRow = ismember(date,t.date(row));
    mob = t{row,9:end};
    subplot(5,2,ii)
    h1 = plot(t.date(row),mob(:,[1,4,5]))
    xlim([t.date(1) datetime('today')])
    title(subregion2{ii,1})
    ylim([-100 20])
    box off
    grid on
    mob = movmean(movmedian(mob,[3 3],'omitnan'),[3 3],'omitnan');
    mob = nanmean(mob(:,[1,4,5]),2);
    glob(globRow,ii) = mob;
    hold on
    h2 = plot(t.date(row),mob,'k');
    if ii == 1
        legend([h1;h2],'חנויות','תחבורה','עבודה','משוקלל')
    end
end


co = hsv(10);
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
% co(11,1:3) = 0;
[~,order] = sort(glob(end,:),'descend');
figure('units','normalized','position',[0,0,0.5,0.5]);
h = plot(date,glob,'linewidth',1);
for ii = 1:10
    h(order(ii)).Color = co(ii,:);
end
xlim([t.date(1) datetime('today')])
box off
grid on
ylabel('שינוי ביחס לשגרה (%)')
title('מדד התנועתיות של גוגל')
set(gcf,'Color','w')

yt = linspace(-10,-70,11);
for iAnn = 1:10
    text(length(glob),yt(iAnn),subregion2{order(iAnn),1},...
        'FontSize',10,'Color',h(order(iAnn)).Color,'FontWeight','bold');
end

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
