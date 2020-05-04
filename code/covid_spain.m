function [esp,pop,date] = covid_spain(plt)
if nargin == 0
    plt = false;
end
cd ~/covid-19_data_analysis/

esp = urlread('https://raw.githubusercontent.com/datadista/datasets/master/COVID%2019/ccaa_covid19_fallecidos.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,esp);
fclose(fid);

esp = readtable('tmp.csv');
date = datetime(strrep(cellfun(@(x) x([6:8,9:10,5,1:4]),esp{1,3:end},'UniformOutput',false),'-','/'))';
esp(1,:) = [];
esp(:,1) = [];
writetable(esp,'tmp.csv','WriteVariableNames',false)
esp = readtable('tmp.csv');
!rm tmp.csv


pop = readtable('data/spain_population.csv','ReadVariableNames',false);
pop = pop([1:4,6:7,9,8,10:11,19,13,14,12,16,18,17,5,15],:);


% % us_state(~ismember(us_state.Var1,pop.State),:) = [];
% [~,idx] = ismember(pop.State,us_state.Var1);
% % pop(~isx,:) = [];
% us_state = us_state(idx,:);
if plt
    y = esp{:,2:end}./pop.Var2*10^6;
    [~,order] = sort(y(:,end),'descend');
    y = y(order,:);
    region = pop.Var1(order);
    y = y';
    figure;
    h = plot(date,y);
    for ii = 1:10
        text(date(end-5),y(end,ii),region(ii),'color',h(ii).Color);
        
    end
    box off
    grid on
    set(gcf,'color','w')
%     xlim(date([length(date)-28 length(date)]))
end

%% another source
% function [espAgg,pop] = covid_spain(plt)
% if nargin == 0
%     plt = false;
% end
% cd ~/covid-19_data_analysis/
% esp = urlread('https://raw.githubusercontent.com/victorvicpal/COVID19_es/master/data/final_data/dataCOVID19_es.csv');
% fid = fopen('tmp.csv','w');
% fwrite(fid,esp);
% fclose(fid);
% esp = readtable('tmp.csv');
% Date = unique(esp.fecha); %datetime(strrep(cellfun(@(x) x([6:8,9:10,5,1:4]),esp{1,3:end},'UniformOutput',false),'-','/'))';
% region = unique(esp.CCAA);
% region_ = strrep(pop.Var1,' ','_');
% region_{9} = 'Castile_and_Leon';
% pop = readtable('data/spain_population.csv','ReadVariableNames',false);
% pop = pop([1:4,19,6:7,9,8,10:11,13,14,15,12,16,18,17,5],:);
% for iDate = 1:length(Date)
%     for iReg = 1:length(region)
%         row = find(ismember(esp.fecha,date(iDate)) & ismember(esp.CCAA,region(iReg)));
%         row = row(end); % two rows with nans
%         eval([region_{iReg},'(iDate,1) = esp.muertes(row);']);
%     end
% end
% evStr = join(region_,',');
% eval(['espAgg = table(Date,',evStr{1},');'])
% if plt
%     y = espAgg{:,2:end}'./pop.Var2*10^6;
%     [~,order] = sort(y(:,end),'descend');
%     y = y(order,:);
%     regionSorted = pop.Var1(order);
%     y = y';
%     figure;
%     h = plot(Date,y);
%     for ii = 1:10
%         text(Date(end-5),y(end,ii),regionSorted(ii),'color',h(ii).Color);
%         
%     end
%     box off
%     grid on
%     set(gcf,'color','w')
% end
% 
