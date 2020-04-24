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

list = readtable('Israel_ministry_of_health.csv');
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
    list{end,2:end} = misrad';
    writetable(list,'Israel_ministry_of_health.csv','WriteVariableNames',true,'Delimiter',',');
    fid = fopen('Israel_ministry_of_health.csv','r');
    txt = fread(fid);
    fclose(fid);
    txt = native2unicode(txt)';
    txt = strrep(txt,'NaN','');
    fid = fopen('Israel_ministry_of_health.csv','w');
    fwrite(fid,txt);
    fclose(fid);
end




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

