function [deceased,pop,date] = covid_ecuador(plt)
if nargin == 0
    plt = false;
end
warning('ecuador should count probable deaths as well');
cd ~/covid-19-israel-matlab/
ecu = urlread('https://raw.githubusercontent.com/andrab/ecuacovid/master/datos_crudos/muertes/por_fecha/provincias_por_dia.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,ecu);
fclose(fid);
ecu = readtable('tmp.csv');
!rm tmp.*

% prov = ecu.Var1(2:end,1);
date = datetime(ecu{1,5:end})';
% population = cellfun(@str2num, ecu{2:end,2});
% pop = table(prov,population);
pop = readtable('data/ecuador_pop.csv');
deceased = cellfun(@str2num, ecu{2:end,5:end})';
if plt
    yy = deceased./pop.population'*10^6;
    [~,order] = sort(yy(end,:),'descend');
    yy = yy(:,order);
    figure;
    h = plot(date,yy);
    for ii = 1:height(pop)
        text(date(end),yy(end,ii),pop.prov{order(ii)},'Color',h(ii).Color);
    end
end


