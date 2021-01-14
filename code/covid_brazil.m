function [yy,pop,date] = covid_brazil(plt)
cd ~/covid-19-israel-matlab
if nargin == 0
    plt = true;
end
% bra = urlread('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-cities-time.csv');
disp('downloading Brazil')
% [~,~] = system('wget -O tmp.csv https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-cities-time.csv')
[~,~] = system('wget -O tmp.csv https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv');
% fid = fopen('tmp.csv','w');
% fwrite(fid,bra);
% fclose(fid);
bra = readtable('tmp.csv');
!rm tmp.*
pop = readtable('data/brazil_pop.csv');
iTot = ismember(bra.state,'TOTAL');
braTot = bra(iTot,:);
bra(iTot,:) = [];
date = braTot.date;
if iscell(date)
    date = datetime(date);
end
braDate = bra.date;
if iscell(braDate)
    braDate = datetime(braDate);
end
deaths = bra.deaths;
if iscell(deaths)
    deaths = cellfun(@str2num , deaths);
end
[state,~] = unique(bra.state);
yy = nan(length(date),length(state));
for ii = 1:length(state)
    iState = ismember(bra.state,state{ii});
    for iDate = 1:length(date)
        jDate = find(ismember(braDate,date(iDate)) & iState);
        if ~isempty(jDate)
            yy(iDate,ii) = nansum(deaths(jDate));
        end
    end
end
%%
if plt
    ypm = yy./pop.pop'*10^6;
    [~,order] = sort(ypm(end,:),'descend');
    figure;
    h = plot(date,ypm);
    for ii = 1:height(pop)
        text(date(end)+5,ypm(end,ii),pop.state_name{ii},'Color',h(ii).Color);
    end
    dypm = diff(ypm);
    bad = dypm(2:end,:)-dypm(1:end-1,:) > 20;
    dypm(bad) = nan;
    dypm = movmean(movmedian(dypm,[3 3],'omitnan'),[3 3]);
    legend(h(order),pop.state_name(order))
    set(gca,'FontSize',13)
    set(gcf,'Color','w')
    xlim([datetime(2020,3,15) datetime('today')+1])
    title('תמותה למליון מצטברת בברזיל, לפי איזור')
    box off
    grid on
    yt = linspace(min(dypm(end,:)),max(dypm(end,:)),size(dypm,2));
    xtickformat('MMM')
    figure;
    hd = plot(date(2:end),dypm);
    hold on
    for ii = 1:height(pop)
        if ~ismember(ii,[3,6,14])
            hd(ii).Color = [0 0 0];
        end
        text(date(end)+5,yt(ii),pop.state_name{ii},'Color',hd(ii).Color);
    end
    for ii = [3,6,14]
        text(date(end)+5,yt(ii),pop.state_name{ii},'Color',hd(ii).Color);
        plot(date(2:end),dypm(:,ii),'Color',hd(ii).Color);
    end
    legend(hd([3,6,14]),pop.state_name([3,6,14]))
    set(gca,'FontSize',13)
    set(gcf,'Color','w')
    xlim([datetime(2020,3,15) datetime('today')+1])
    title('תמותה למליון ליום בברזיל, לפי איזור')
    box off
    grid on
    xtickformat('MMM')
end
%%
% https://github.com/wcota/covid19br/raw/master/cases-brazil-cities-time.csv.gz
city = true;
if city
    !wget -O tmp.gz https://github.com/wcota/covid19br/raw/master/cases-brazil-cities-time.csv.gz
    gunzip('tmp.gz')
    movefile('tmp','tmp.csv')
    t = readtable('tmp.csv');
    t(ismember(t.state,'TOTAL'),:) = [];
    date = unique(t.date);
    cityName = unique(t.city);
    iMa = find(contains(cityName,'Manaus'));
    figure;
    for ii = 1:length(cityName)
        iCity = ismember(t.city,cityName{ii});
        dpm = diff(t.deaths_per_100k_inhabitants(iCity)*10);
        dpm = [0;movmean(movmedian(dpm,[3 3]),[3 3])];
        if ii == 1
            h1 = plot(t.date(iCity),dpm,'k');
            hold on
        elseif ii == iMa
            h2 = plot(t.date(iCity),dpm/10,'r');
        else
            plot(t.date(iCity),dpm,'k');
        end
    end
    iCity = ismember(t.city,cityName{iMa});
    dpm = diff(t.deaths_per_100k_inhabitants(iCity)*10);
    dpm = [0;movmean(movmedian(dpm,[3 3]),[3 3])];
    plot(t.date(iCity),dpm,'r','linewidth',2);
    legend([h2,h1(1)],'מנאוס','ערים אחרות')
    title('תמותה בערי ברזיל')
    ylim([0 60])
    xlim([datetime(2020,3,15) datetime('today')+1])
    set(gca,'ygrid','on')
    set(gcf,'Color','w')
    box off
    xtickformat('MMM')
    figure;
    for ii = 1:length(cityName)
        iCity = ismember(t.city,cityName{ii});
        dpm = t.deaths_per_100k_inhabitants(iCity)*10;
%         dpm = [0;movmean(movmedian(dpm,[3 3]),[3 3])];
        if ii == 1
            hh1 = plot(t.date(iCity),dpm,'k');
            hold on
        elseif ii == iMa
            hh2 = plot(t.date(iCity),dpm/10,'r');
        else
            plot(t.date(iCity),dpm,'k');
        end
    end
    iCity = ismember(t.city,cityName{iMa});
    dpm = t.deaths_per_100k_inhabitants(iCity)*10;
%     dpm = [0;movmean(movmedian(dpm,[3 3]),[3 3])];
    plot(t.date(iCity),dpm,'r','linewidth',2);
    legend([hh2,hh1(1)],'מנאוס','ערים אחרות')
    title('תמותה מצטברת בערי ברזיל')
%     ylim([0 60])
    xlim([datetime(2020,3,15) datetime('today')+1])
    set(gca,'ygrid','on')
    set(gcf,'Color','w')
    box off
    xtickformat('MMM')
end