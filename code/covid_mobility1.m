mob = readtable('~/Downloads/Region_Mobility_Report_CSVs/2020_IL_Region_Mobility_Report.csv');
district = unique(mob.sub_region_1);
city = unique(mob.sub_region_2);
date = cell(2,1);
date{1} = datetime(2020,3,19):datetime(2020,4,19);
date{2} = datetime(2020,9,19):datetime(2020,10,19);
row = 0;
decrease = [];
for ii = 1:length(district)
    for jj = 1:length(city)
        if any(ismember(mob.sub_region_1,district{ii})  & ismember(mob.sub_region_2,city{jj}))
            row = row+1;
            name{row,1} = [district{ii},' ',city{jj}];
            for iWave = 1:2
                idx = ismember(mob.date,date{iWave}) & ismember(mob.sub_region_1,district{ii})  & ismember(mob.sub_region_2,city{jj});
                decrease(row,iWave) = mean(nanmean(mob{idx,9:end}.*[-1,-1,-1,-1,-1,1]));
            end
        end
    end
end

name{1} = 'Israel';
figure;
bar(decrease)
set(gca,'XTick',1:length(name),'XTickLabel',name,'ygrid','on','fontsize',13)
xtickangle(45)
box off
ylabel('תגובה לסגר (%)')
legend('גל  I','גל II')
title('היענות לשני הסגרים לפי איזור')

ii = 1; jj = 1;
idx = ismember(mob.date,[date{1},date{2}]) & ismember(mob.sub_region_1,district{ii})  & ismember(mob.sub_region_2,city{jj});
yy = nan(254,1);
yy(idx) = nanmean(mob{idx,9:end}.*[-1,-1,-1,-1,-1,1],2);
figure;
plot(mob.date(1:254),mob{1:254,9:end})
hold on
plot(mob.date(1:254),yy,'k','linewidth',2);


%%
mobglob = readtable('~/Downloads/Global_Mobility_Report.csv');
mobglob(~cellfun(@isempty,mobglob.sub_region_1) | ~cellfun(@isempty,mobglob.sub_region_2),:) = [];
country = unique(mobglob.country_region);
for ii = 1:length(country)
    idx = ismember(mobglob.country_region,country{ii});
    n(ii,1) = sum(idx);
    vec = nanmean(mobglob{idx,9:end}.*[-1,-1,-1,-1,-1,1],2);
    mobMean(ii,1) = mean(vec);
    mobMax(ii,1) = max(vec);
    mobArea(ii,1) = trapz(vec)./length(vec);
end

[~,order] = sort(mobMax,'descend');
[country(order(1:20)),country(order(end-19:end))]
idx = order([1:20,end-19:end]);
figure;
bar(1:20,mobMax(idx(1:20)),'FaceColor','b','EdgeColor','none')
hold on
bar(21:40,mobMax(idx(21:40)),'FaceColor','r','EdgeColor','none')
set(gca,'Xtick',1:40,'XTickLabel',country(idx),'ygrid','on','FontSize',13)
xtickangle(60)
set(gcf,'Color','w')
box off
ylabel('הפחתת תנועה (%)')
legend ('top 20','bottom 20')
title({'המדינות בראש ובתחתית נתוני התנועה של גוגל','ציר Y הוא מקסימום הפחתה בתנועה מאז פרוץ המשבר'})
coi = {'Israel','Belgium'};
date = unique(mobglob.date);
for iCou = 1:length(coi)
    vecs(1:length(date),iCou) = nanmean(mobglob{ismember(mobglob.country_region,coi{iCou}),9:14}.*[-1,-1,-1,-1,-1,1],2);
end