function covid_US
cd ~/covid-19-israel-matlab/
cellCount = 1;
%% NYC
% cellCount = cellCount+1;
[date{cellCount,1},popNYC,nyc,nycp] = covid_nyc;
pop{cellCount,1} = table({'NYC_Confirmed';'NYC_Probable'},[popNYC;popNYC]);
deceased{cellCount,1} = [nyc,nycp];
country{cellCount,1} = repmat({'US'},size(pop{cellCount},1),1);
%% USA states
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_usa;
deceased{cellCount} = deceased{cellCount}{:,2:end}';
pop{cellCount}{:,1} = strrep(pop{cellCount}{:,1},'Georgia','Georgia US');
country{cellCount,1} = repmat({'US'},size(pop{cellCount},1),1);

Date = {};
Region = {};
Country = {};
Population = [];
for ii = 1:length(date)
    iNaT = isnat(date{ii});
    date{ii}(iNaT) = [];
    deceased{ii}(iNaT,:) = [];
    Date =[Date;date{ii}];
%     for iBad = 1:length(badChar)
%         pop{ii}{:,1} = strrep(pop{ii}{:,1},badChar{iBad,1},badChar{iBad,2});
%     end
    Region = [Region;pop{ii}{:,1}];
    Country = [Country;country{ii}];
    Population = [Population;pop{ii}{:,2}];
end

if length(Region) > length(unique(Region))
    error('Region is not unique');
end
Date = unique(Date);
for ii = 1:length(deceased)
    if size(pop{ii},1) ~= size(deceased{ii},2)
        error(['bad matrix size for',num2str(ii)])
    end
end
Date_ = cellstr(datestr(Date,'mmm_dd_yyyy'));
list = table(Country,Region,Population);
for ii = 1:length(Date)
    eval(['list.',Date_{ii},' = nan(length(Region),1);']);
end
for ii = 1:length(deceased)
    iDate = find(ismember(Date,date{ii}));
    iReg = ismember(Region,pop{ii}{:,1});
    list{iReg,iDate+3} = deceased{ii}';
end
ignore = find(Date > dateshift(datetime('now'),'start','day'),1);
if ~isempty(ignore)
    list(:,ignore+3:end) = [];
    Date(ignore:end) = [];
end
% nanwritetable(list,'data/regions.csv');
%% sort 

listDate = datetime(strrep(list.Properties.VariableNames(4:end),'_','-'),'InputFormat','MMM-dd-yyyy');
y = list{:,4:end}'./list.Population'*10^6;
[~,order] = sort(nanmax(y),'descend');
y = y(:,order);
loc = list{order,2};
loc{ismember(loc,'New York')} = 'New York State';
iXtick = fliplr(length(listDate):-7:1);
% nLines = find(nanmax(y) > threshold,1,'last');
nLines = size(y,2);
loc = strrep(loc,'_',' ');
%% plot
fig10 = figure('units', 'normalized', 'position',[0.1,0.1,0.5,0.7]);
for ii = 1:nLines
    notNan = ~isnan(y(:,ii));
    h(ii) = plot(listDate(notNan),y(notNan,ii));
    hold on
end
xlim(listDate([40,end]))
% yt = max(max(y)):-max(max(y))/nLines:0;
yt = [nanmax(y(:,1:2)),y(end,3):-100:0];
grid on
box off
title({'תמותה למליון מצטברת בארה"ב','אלף מתים למליון = עשירית אחוז מהאוכלוסיה'})
ylabel('מתים למליון')
set(gca,'fontsize',13,'position',[0.13 0.12 0.7 0.8])
set(gcf,'Color','w','InvertHardcopy', 'off')
xtickangle(90)
% col = reshape([h(1:7).Color],3,7)';
co = [zeros(2,3);hsv(10)];
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
co(end+1:size(y,1),:) = 0.45;

country = list.Region(order(1:nLines));
countryU = unique(country);
colorIndex = mod((0:length(countryU)-1),length(co))+1;
[~,iCou] = ismember(country,countryU);
countryColor = co(colorIndex(iCou),:);
for ii = 1:nLines
    h(ii).Color = co(ii,:);
    if ii < 13
        text(listDate(end),yt(ii),loc{ii},'color',h(ii).Color);
    end
end
% for ic = 1:length(countryU)
%     text(listDate(5),100+yt(1)-75*ic,countryU{ic},'color',co(colorIndex(ic),:))
% end
isr = readtable('data/Israel/dashboard_timeseries.csv');
isr.CountDeath(isnan(isr.CountDeath)) = 0;
plot(isr.date,cumsum(isr.CountDeath)/9.2,'k','linewidth',2)
% text(listDate(5),100+yt(1)-75*(size(y,2)+1),'Israel','color',[0,0,0],'fontweight','bold','fontsize',13)
% text(listDate(end),20+sum(isr.CountDeath)/9.2,['Israel (',str(round(sum(isr.CountDeath)/9.2)),')'],'color',[0,0,0],'fontweight','bold')
text(listDate(end),20+sum(isr.CountDeath)/9.2,['Israel'],'color',[0,0,0],'fontweight','bold')

%% save
% saveas(fig10,'docs/worst_region.png')
yd = diff(y);
yd(yd < 0) = nan;
for ic = 1:size(yd,2)
    ij = find(diff(yd(:,ic)) > 100)+1;
    yd(ij,ic) = nan;
end
yd = movmean(yd,[6 0],'omitnan');
yd = movmean(yd,[3 3],'omitnan');
[~,orderd] = sort(yd(end,:),'descend');
yd = yd(:,orderd);
%%
fig11 = figure('units', 'normalized', 'position',[0.1,0.1,0.5,0.7]);
plot(listDate(2:end),yd,'Color',[0.65 0.65 0.65]);
hold on
for ii = 1:10
    hd(ii) = plot(listDate(2:end),yd(:,ii));
    hold on
end
plot(listDate(2:end),yd(:,ismember(orderd,[1,2])),'k')
ylim([0 30])
xlim(listDate([40,end]))
% yt = max(max(y)):-max(max(y))/nLines:0;
yt = linspace(yd(end,1),0,10);
grid on
box off
title('תמותה למליון ליום בארה"ב')
ylabel('מתים למליון')
set(gca,'fontsize',13,'position',[0.13 0.12 0.7 0.8])
set(gcf,'Color','w','InvertHardcopy', 'off')
xtickangle(90)
% col = reshape([h(1:7).Color],3,7)';
co = hsv(10);
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
co(end+1:size(yd,1),:) = 0.45;

country = list.Region(order(orderd));
countryU = unique(country);
colorIndex = mod((0:length(countryU)-1),length(co))+1;
[~,iCou] = ismember(country,countryU);
countryColor = co(colorIndex(iCou),:);

for ii = 1:10
    hd(ii).Color = co(ii,:);
    if ii < 13
        text(listDate(end),yt(ii),country{ii},'color',hd(ii).Color);
    end
end
