function covid_Israel_ministry(getHistory)
if ~exist('getHistory','var')
    getHistory = true;
end
%% משרד הבריאות
cd ~/covid-19_data_analysis/
txt = urlread('https://govextra.gov.il/ministry-of-health/corona/corona-virus/');
iSmaller = find(ismember(txt,'<'));
i0 = findstr(txt,'נכונה ל');
i1 = findstr(txt,'בשעה');
tStr = [txt(i0+9:i1-2),' ',txt(i1+5:iSmaller(find(iSmaller > i1,1))-1)];
date = datetime(str2num(...
    [tStr(find(ismember(tStr,'.'),1,'last')+1:strfind(tStr,' ')),...
    tStr(find(ismember(tStr,'.'),1)+1:find(ismember(tStr,'.'),1,'last')-1),' ',...
    tStr(1:find(ismember(tStr,'.'),1)-1),' ',...
    strrep(tStr(strfind(tStr,' ')+1:end),':',' '),' 0']));

list = readtable('data/Israel/Israel_ministry_of_health.csv');
if ~ismember(date,list.date)
    warning off
    list.date(end+1) = date;
    warning on
    
    
    marker = {'corona-xl',41;...  % מקרים מאומתים
        '<div class="corona-md">נפטרו</div>',115;...
        '<div class="corona-md">החלימו</div>',116;...
        '>מונשמים',51;...
        'קשה<',46;...
        'בינוני<',49;...
        'קל<',45;...
        'בית חולים<',52;...
        'מלונית<',49;...
        'טיפולי בית<',53};
    
    
    for ii = 1:size(marker,1)
        i0 = strfind(txt,marker{ii,1})+marker{ii,2};
        i0 = i0(1);
        i1 = iSmaller(find(iSmaller > i0,1))-1;
        if length(i0) > 1
            error('marker not unique')
        end
        if ~strcmp(txt(i0-1),'>')
            error('before the number there should be a ">"')
        end
        
        misrad(ii,1) = str2num(strrep(txt(i0:i1),',',''));
    end
    misrad([2,3]) = misrad([3,2]);
    list{end,2:11} = misrad';
    list{end,12:14} = nan;
    nanwritetable(list);
end

if getHistory
    iLink = strfind(txt,'.xlsx');
    iHref = strfind(txt,'href');
    iHref = iHref(find(iHref < iLink,1,'last'));
    link = ['https://govextra.gov.il/',txt(iHref+7:iLink+4)];
    system(['wget ',link])
    movefile(link(find(ismember(link,'/'),1,'last')+1:end),'data/Israel/covid19-data-israel.xlsx')
end
%     history = readtable('data/Israel/covid19-data-israel.xlsx');
%     history.Properties.VariableNames(:) = {'date','tests','confirmed','hospitalized_xlsx','critical','on_ventilator','deceased'};
%     history.date = history.date+duration([23,59,59]);
%     iNewDates = find(~ismember(history.date,list.date));
%     if ~isempty(iNewDates)
%         prevLength = height(list);
%         history = history(iNewDates,:);
%         warning off
%         list.date(prevLength+1:prevLength+height(history)) = history.date;
%         list.hospitalized_xlsx(prevLength+1:prevLength+height(history)) = history.hospitalized_xlsx;
%         list.deceased(prevLength+1:prevLength+height(history)) = history.deceased;
%         list.confirmed(prevLength+1:prevLength+height(history)) = history.confirmed;
%         list.critical(prevLength+1:prevLength+height(history)) = history.critical;
%         list.on_ventilator(prevLength+1:prevLength+height(history)) = history.on_ventilator;
%         list.tests(prevLength+1:prevLength+height(history)) = history.tests;
%         
%         list(prevLength+1:prevLength+height(history),[3,7:11,14]) = repmat({nan},height(history),7);
% %         list.recovered(prevLength+1:prevLength+height(history)) = nan;
% %         list.severe(prevLength+1:prevLength+height(history)) = nan;
% %         list.mild(prevLength+1:prevLength+height(history)) = nan;
% %         list.hotel_isolation(prevLength+1:prevLength+height(history)) = nan;
% %         list.home_care(prevLength+1:prevLength+height(history)) = nan;
% %         list.hospitalized(prevLength+1:prevLength+height(history)) = nan;
% %         list.critical_cumulative(prevLength+1:prevLength+height(history)) = nan;
%         [~,order] = sort(list.date);
%         list = list(order,:);
%         warning on
%         nanwritetable(list);
%     end

% 
% function nanwritetable(list)
% writetable(list,'data/Israel/Israel_ministry_of_health.csv','WriteVariableNames',true,'Delimiter',',');
% fid = fopen('data/Israel/Israel_ministry_of_health.csv','r');
% txt = fread(fid);
% fclose(fid);
% txt = native2unicode(txt)';
% txt = strrep(txt,'NaN','');
% fid = fopen('data/Israel/Israel_ministry_of_health.csv','w');
% fwrite(fid,txt);
% fclose(fid);

%history.date = dateshift(history.date,'end','day')

% !wget https://raw.githubusercontent.com/tsvikas/COVID-19-Israel-data/master/daily_reports/total_cases.csv
% t = readtable('total_cases.csv','Delimiter',',');
% dateTC = datetime(cellfun(@(x) x(1:19),t.date,'UniformOutput',false));
% listNew = list;
% list.Properties.VariableNames(6:8) = {'critical','severe','mild'};
% listNew.Properties.VariableNames(6:8) = {'critical','severe','mild'};
% listNew.mild(1:height(t)) = t.mild;
% listNew.severe = t.serious;
% listNew.critical = t.critical;
% listNew.confirmed = t.total_cases;
% listNew.deceased = t.dead;
% listNew.date = dateTC;
% listNew.recovered = t.recovering;
% listNew(1:2,[5,9:11]) = repmat({0},2,4);
% listNew(end+1:end+2,:) = list;
% for ii = 5:height(vent)
%     row = find(dateshift(listNew.date,'start','day') == vent.date(ii),1,'last');
%     listNew.on_ventilator(row) = vent.vent_used(ii);
% end
% listNew.hospitalized(1:end-2) = nan;
% listNew.hotel_isolation(1:end-2) = nan;
% listNew.home_care(1:end-2) = nan;
%
% writetable(listNew,'Israel_ministry_of_health.csv','WriteVariableNames',true,'Delimiter',',');



% confirmed = misrad(1);
% deceased = misrad(2);
% recovered = misrad(3);
% on_ventilator = misrad(4);
% severe = misrad(5);
% medium = misrad(6);
% easy = misrad(7);
% hospitalized = misrad(8);
% hotel_isolation = misrad(9);
% home_care = misrad(10);
% list = table(date,confirmed,recovered,deceased,on_ventilator,severe,medium,...
%     easy,hospitalized,hotel_isolation,home_care);
% writetable(list,'Israel_ministry_of_health.csv','WriteVariableNames',true,'Delimiter',',');

