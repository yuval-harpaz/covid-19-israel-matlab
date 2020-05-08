bra = urlread('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-cities-time.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,bra);
fclose(fid);
bra = readtable('tmp.csv');
!rm tmp.

iTot = ismember(bra.state,'TOTAL');
braTot = bra(iTot,:);
bra(iTot,:) = [];
city = unique(bra.city);
date = braTot.date;
y = nan(length(date),length(city));
for ii = 1:length(city)
    iCity = ismember(bra.city,city{ii});
    dateCity = bra.date(iCity);
    [~,iDate] = ismember(dateCity,date);
    y(iDate,ii) = bra.deaths(iCity);
end

[~,order] = sort(y(end,:),'descend');
city(order(1:10))
figure;plot(date,y(:,order(1:10)))
    
state = unique(bra.state);
yy = nan(length(date),length(state));
for ii = 1:length(state)
    iState = ismember(bra.state,state{ii});
    for iDate = 1:length(date)
        jDate = find(ismember(bra.date,date(iDate)) & iState);
        if ~isempty(jDate)
            yy(iDate,ii) = nansum(bra.deaths(jDate));
        end
    end
%     dateState = bra.date(iState);
%     [~,iDate] = ismember(dateState,date);
%     iDate = find(iDate);
%     yy(iDate,ii) = bra.deaths(iState);
end
[~,order] = sort(yy(end,:),'descend');
state(order(1:10))
pop = [881935,3337357,4144597,845731,14873064,9132078,3015268,4018650,7018354,...
    7075181,21168791,2778986,3484466,8602865,4018127,9557071,3273227,11433957,...
    17264943,3506853,1777225,605761,11377239,7164788,2298696,45919049,1572866]';

figure;
plot(date,yy./pop'*10^6)