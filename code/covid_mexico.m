function [deceased,pop,date] = covid_mexico(plt)
if nargin == 0
    plt = false;
end
cd ~/covid-19-israel-matlab/
mex = urlread('https://raw.githubusercontent.com/mariorz/covid19-mx-time-series/master/data/covid19_deaths_mx.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,mex);
fclose(fid);
mex = readtable('tmp.csv');
!rm tmp.*

% prov = ecu.Var1(2:end,1);
date = datetime(strrep(mex.Properties.VariableNames(2:end),'x',''),'InputFormat','dd_MM_yyyy')';
% population = cellfun(@str2num, ecu{2:end,2});
% pop = table(prov,population);
pop = readtable('data/mexico_pop.csv');
deceased = mex{:,2:end}';
if plt
    yy = deceased./pop.population'*10^6;
    [~,order] = sort(yy(end,:),'descend');
    yy = yy(:,order);
    figure;
    h = plot(date,yy);
    for ii = 1:height(pop)
        text(date(end),yy(end,ii),pop.state{order(ii)},'Color',h(ii).Color);
    end
end


