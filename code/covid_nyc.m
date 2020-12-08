function [date,pop,deceased,deceased_probable] = covid_nyc
% nyc = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/Deaths/probable-confirmed-dod.csv');
% nyc = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/deaths/probable-confirmed-dod.csv');
nyc = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/data-by-day.csv');
% nyc = strrep(nyc,'/20,','/2020,');
fid = fopen('tmp.csv','w');
fwrite(fid,nyc);
fclose(fid);
nyc = readtable('tmp.csv');
!rm tmp.csv
% nyc.PROBABLE_COUNT(isnan(nyc.PROBABLE_COUNT)) = 0;
% nyc.CONFIRMED_COUNT(isnan(nyc.CONFIRMED_COUNT)) = 0;
date = nyc.date_of_interest;
pop =  8336830; % you sum borrogh pop 25.5995   14.1823   16.2867   22.5383    4.7614. before I used 8399000
deceased = cumsum(nyc.DEATH_COUNT);
deceased_probable = deceased + cumsum(nyc.PROBABLE_DEATH_COUNT);

% !wget -O tmp.csv https://raw.githubusercontent.com/nychealth/coronavirus-data/13c4c61fcd426eb9b285f2953ce2e262c192f49f/totals/group-data-by-boro.csv
% bo = readtable('tmp.csv');
% !rm tmp.csv
% 
% 
% rateBo = bo{5:12,8:6:end};
% deathBo = bo{5:12,5:6:end};
% popBo = deathBo./rateBo;
% rateBo(:,end+1) = sum(deathBo,2)./nansum(popBo,2);
% 
% x = [8.75,21,29.5,39.5,49.5,59.5,69.5,79.5];
% if nargout == 0
%     figure;
%     h = bar(x,rateBo,'linestyle','none');
%     legend([cellfun(@(x) x(1:2),bo.Properties.VariableNames(5:6:end),'UniformOutput',false),'NYC'])
%     set(gca,'Xtick',x,'XtickLabel',bo{5:12,2});
%     h(end).FaceColor = [0 0 0];
%     hold on
%     h = bar(x,rateBo,'linestyle','none');
% end
% TODO - all NYC, add probablr