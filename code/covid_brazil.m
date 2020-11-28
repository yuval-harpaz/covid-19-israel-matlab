function [yy,pop,date] = covid_brazil(plt)
if nargin == 0
    plt = false;
end
% bra = urlread('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-cities-time.csv');
disp('downloading Brazil')
[~,~] = system('wget -O tmp.csv https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-cities-time.csv')
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

if plt
    [~,order] = sort(yy(end,:),'descend');
    ypm = yy./pop.pop'*10^6;
    figure;
    h = plot(date,ypm);
    for ii = 1:height(pop)
        text(date(end),ypm(end,ii),pop.state_name{ii},'Color',h(ii).Color);
    end
end