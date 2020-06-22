function [esp,pop,date] = covid_spain
plt = 0;
source = 'mscbs'; % or 'datadista'
cd ~/covid-19-israel-matlab/

switch source
    case 'datadista'
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
    case 'mscbs'
        day1 = datetime('04-Mar-2020');
        esp = readtable('data/spain.csv');
        dayLast = days(datetime('today')-day1)+34;
        [err,msg] = system(['wget -O data/spain.pdf https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov-China/documentos/Actualizacion_',str(dayLast),'_COVID-19.pdf']);
        if contains(msg,'ERROR 404')
            dayLast = dayLast-1;
            [err,msg] = system(['wget -O data/spain.pdf https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov-China/documentos/Actualizacion_',str(dayLast),'_COVID-19.pdf']);
            if contains(msg,'ERROR 404')
                error('spain not found')
            end
        end
        javaaddpath(which('/iText-4.2.0-com.itextpdf.jar'))
        pdf = pdfRead('data/spain.pdf');
        date = (day1:day1+size(esp,2)-2)';
        datePDF = datetime(strrep(pdf{1}(strfind(pdf{1},'(COVID')+12:strfind(pdf{1},'(COVID')+21),' ',''),'InputFormat','dd.MM.yyyy');
        
        if ~ismember(datePDF,date) && ~isnat(datePDF) && length(datePDF) == 1
            txt = pdf{2}(strfind(pdf{2},'Andaluc'):strfind(pdf{2},'ESPA')-2);
            rows = regexp(txt,'\n','split')';
            rows = strrep(rows,'.','');
            rows = strrep(rows,native2unicode([194,160]),'');
            rows = strtrim(rows)
            regDeath = cellfun(@(x) str2num(x{end-1}), regexp(rows,' ','split'));
            esp{:,end+1} = regDeath;
            date = [date;datePDF];
            writetable(esp,'data/spain.csv','WriteVariableNames',false)
        end
        
end


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
% cd ~/covid-19-israel-matlab/
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
