function fig = covid_plot(mergedData,timeVector,nCountries,criterion,criterionDays,mustHave,ymax,dashboard)
cd ~/covid-19-israel-matlab/
% showDateEvery = 7; % days
warning off
pop = readtable('data/population.csv','delimiter',',');
for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
warning on
mergedData(~ismember(mergedData(:,1),pop.Country_orDependency_),:) = [];
deaths = nan(length(timeVector),length(mergedData));

for iCou = 1:length(mergedData)
    deaths(1:length(timeVector),iCou) = mergedData{iCou,2};
end
%%
[~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
mil = pop.Population_2020_(idx)'/10^6;
[~,iMustHave] = ismember(mustHave,mergedData(:,1));
iMustHave(isempty(iMustHave)) = [];
if ~exist('dashboard','var')
    dashboard = true;
end
if dashboard
    listD = readtable('data/Israel/dashboard_timeseries.csv');
    listD.CountDeath(isnan(listD.CountDeath)) = 0;
    [isDate,iDate] = ismember(listD.date,timeVector);
    deaths(iDate(isDate),iMustHave) = listD.CountDeath(isDate);
    deaths(iDate(isDate),iMustHave) = cumsum(deaths(iDate(isDate),iMustHave));
end

switch criterion
    case 'd'
        y = deaths;
        tit = 'Deaths';
    case 'dpm'
        y = deaths./mil;
        tit = 'Deaths per million';
    case 'dd'
        y = [deaths(1,:);diff(deaths)];
        tit = 'Daily deaths';
    case 'ddpm'
        y = [deaths(1,:);diff(deaths)]./mil;
        isNeg = y < 0;
        y(isNeg) = nan;
        isJump = y > 20;
        if ~dashboard
            isJump(211,83) = true;  % Israel's little jump
        end
        jump = nan(size(y));
        jump(isJump) = y(isJump);
        y(isJump) = nan;
        tit = 'Daily deaths per million';
end
y(y < 0) = 0;
y = movmean(y,[6 0],'omitnan');
if exist('isNeg','var')
    y(isNeg) = nan;
    %y(isJump) = jump(isJump);
end

[~,order] = sort(nanmean(y(end-criterionDays+1:end,:),1),'descend'); % most deaths
[~,iMustHave] = ismember(iMustHave,order);
y = y(:,order);
fig = figure('units','normalized','position',[0,0,0.5,0.5]);
hAll = plot(timeVector,y,'linewidth',1,'color',[0.65 0.65 0.65]);
hold on
h = plot(timeVector,y(:,1:nCountries),'linewidth',1,'marker','.','MarkerSize',8);
if ~isempty(iMustHave)
    for im = 1:length(iMustHave)
        hm(im) = plot(timeVector,y(:,iMustHave(im)),'linewidth',1,'marker','.','MarkerSize',8);
        hm(im).Color = [0 0 0];
        if iMustHave(im) <= nCountries
            h(iMustHave(im)).Color = [0 0 0];
        end
    end
else
    hm = [];
end
ax = ancestor(hAll, 'axes');
ax{1}.YAxis.Exponent = 0;
xlim([datetime(2020,3,1) timeVector(end)])
box off
grid on
xlabel('Weeks')
title(tit)
if ~exist('ymax','var')
    ymax = max(y(end,:))*1.1;
end
ylim([0 ymax])
yt = fliplr(ymax/nCountries:ymax/nCountries:ymax);
x = size(y,1);
for iAnn = 1:nCountries
    text(x,yt(iAnn),mergedData{order(iAnn)},...
        'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
end
if ~isempty(hm) && any(iMustHave > nCountries)
    if length(hm) == 1
        ya = 0;
    else
        ya = y(end,iMustHave);
    end
    for im = 1:length(hm)
        io = order(iMustHave(im));
        text(x,ya(im),[mergedData{io},'(',num2str(iMustHave(im)),')'],...
            'FontSize',10,'Color',hm(im).Color,'FontWeight','bold');
    end
end

