cd ~/covid-19-israel-matlab/data/Israel
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b5b4ee-467a-48f1-8799-a42fccf91651&limit=5000');
json = jsondecode(json);
t = struct2table(json.result.records);

t60 = t(ismember(t.age_group,'60+'),:);
weekStartVacc = datetime(cellfun(@(x) x(1:10),t60.Third_dose_week,'UniformOutput',false));
[weekVacc,order] = sort(weekStartVacc);
t60 = t60(order,:);
% weekVacc = (min(weekStartVacc):7:max(weekStartVacc))';
weekInfec = datetime(cellfun(@(x) strrep(x(10:19),'_','-'),t60.Properties.VariableNames(5:end),'UniformOutput',false))';
% weekInfec = (min(weekStartInfec):7:max(weekStartInfec))';
cells = t60{:,5:end};
cells(cellfun(@isempty, cells)) = {'0'};
cells = strrep(cells,'1-5','0');
cases = cellfun(@str2num, cells);
cases(cases == -4) = 0;
cpm = round(cases./cellfun(@str2num, t60.group_size).*10^6,1);
m = month(weekInfec);
mn = cellstr(datestr(datetime(1,m,1),'mmm'));
[a,b,c] = unique(m);
xtick = sort(b);
% xtick(1) = [];
xtl = mn(xtick);
yy = cases;
yy(:,:,2) = cpm;
tit = {'Cases','Cases per million'};
%%
figure;
for sp = 1:2
    subplot(2,1,sp)
    imagesc(yy(:,:,sp))
    xlabel('Infection week')
    ylabel('Vaccination week')
    set(gca,'Ydir','normal')
    set(gca,'Xtick',xtick,'XtickLabel',xtl,'Ytick',[2;xtick(2:end)],'YtickLabel',xtl)
    colormap('hot')
    ylim([1.5 10.5])
    title(tit{sp})
    colorbar
%     axis square
end
set(gcf,'Color','w')
%%
[yy1, xtl1, xtick1] = covid_waning_dose1(false);
yy1 = yy1(:,2:end,:);
xtick1 = xtick1-1;
yy(end+1:size(yy1,1),end+1:size(yy1,2),:) = nan;
%%
xEnd = length(weekInfec)+0.5;
figure;
subplot(2,1,1)
imagesc(yy(:,:,2))
set(gca,'Ydir','normal')
set(gca,'Xtick',[xtick; xEnd],'XtickLabel',[xtl;datestr(weekInfec(end)+6,'dd/mm')],...
    'Ytick',[2;xtick(2:end)],'YtickLabel',xtl)
colormap('hot')
ylim([1.5 12.5])
caxis([0 3000])
% xlim([0.5 length(yy)+0.5])


hold on
hh(1) = fill([0,0,0,0],[0,0,0,0],[1 1 1]);
hh(2) = line([xEnd,xEnd],[0,12.5],'Color','b');
yl3 = yy(2,:,2)/3000*12.5+2;
yl3(yl3 == 2) = nan;
yl3(1) = nan;
hh(3) = plot(yl3,'g');
lg = legend(hh,'3000 cases per M','last update','first group to vaccinate');
set(lg, 'Color','none','TextColor','w','Box','off')
title('Cases per million by Infection time and by dose III vaccination group')
xlabel('Infection week')
ylabel('Dose III vaccination week')
subplot(2,1,2)
imagesc(yy1(:,:,2))
set(gca,'Ydir','normal')
set(gca,'Xtick',xtick1,'XtickLabel',xtl1,'Ytick',xtick1,'YtickLabel',xtl1)
colormap('hot')
ylim([1.5 12.5])
caxis([0 3000])
set(gcf,'Color','w')
hold on
yl1 = yy1(2,:,2)/3000*12.5+2;
yl1(1) = nan;
plot(yl1,'g')
title('Cases per million by Infection time and by dose I vaccination group')
xlabel('Infection week')
ylabel('Dose I vaccination week')
