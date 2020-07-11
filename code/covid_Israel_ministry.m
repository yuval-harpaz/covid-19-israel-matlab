function covid_Israel_ministry(method)
if nargin == 0
    method = 'query'; % could also be chrome
end
%% משרד הבריאות
cd ~/covid-19-israel-matlab/
%% get history
try
    txt = urlread('https://govextra.gov.il/ministry-of-health/corona/corona-virus/');
catch
    [~,~] = system('wget -O tmp.html http://govextra.gov.il/ministry-of-health/corona/corona-virus/');
    fid = fopen('tmp.html', 'r');
    txt = fread(fid);
    fclose(fid);
    txt = native2unicode(txt');
end
ext = '.csv';
iLink = strfind(txt,'.csv');
iHref = strfind(txt,'href');
iHref = iHref(find(iHref < iLink,1,'last'));
link = ['https://govextra.gov.il/',txt(iHref+7:iLink+(length(ext)-1))];
[~,~] = system(['wget ',link]);
movefile(link(find(ismember(link,'/'),1,'last')+1:end),['data/Israel/covid19-data-israel',ext])
if exist('data/Israel/tmp.csv','file')
    !rm data/Israel/tmp.csv
end
!awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' data/Israel/covid19-data-israel.csv >> data/Israel/tmp.csv
movefile('data/Israel/tmp.csv','data/Israel/covid19-data-israel.csv')

%% get dashboard
covid_Israel_moh_dashboard;
%% process text
cd ~/covid-19-israel-matlab/
list = readtable('data/Israel/Israel_ministry_of_health.csv');
switch method
    case 'chrome'
        [~,~] = system('google-chrome --incognito https://datadashboard.health.gov.il/COVID-19/?utm_source=go.gov.il&utm_medium=referral && sleep 10 && xdotool key ctrl+s && sleep 3 && xdotool key Return && sleep 3 && xdotool key Return');
        pause(5)
        fid = fopen('/home/innereye/Downloads/קורונה - לוח בקרה.html', 'r');
        txt = fread(fid)';
        fclose(fid);
        txt = native2unicode(txt);
        idx = min(strfind(txt,'|'));
        iDay = find(ismember(txt,'>') & 1:length(txt) < idx,1,'last')+1;
        day = str2num(txt(iDay:iDay+1));
        month = find(cellfun(@(x) contains(txt(iDay:idx),x),{'ינו','פבר','מרץ','אפר','מאי','יונ','יול','אוג','ספט','אוק','נוב','דצמ'}'));
        date = datetime([2020,month,day,str2num(txt(idx+14:idx+15)),str2num(txt(idx+17:idx+18)),0]);
        % date = datetime(str(txt(idx+14:idx+18),'InputFormat','hh:mm');
        if ~ismember(date,list.date)
            vars = list.Properties.VariableNames(2:end);
            ta = strfind(txt,'total-amount');
            ta = ta(2+[1,3:5]);
            iVar = [1,4,3,2];
            iSmaller = strfind(txt,'<');
            misrad = nan(size(vars));
            for ii = 1:length(ta)
                misrad(1,iVar(ii)) = str2num(strrep(txt(ta(ii)+14:iSmaller(find(iSmaller > ta(ii),1))-1),',',''));
            end
            marker = {
                'קשה',39;...
                'בינוני',42;...
                '',nan;...
                'בי"ח',40;...
                'קהילה',48};
            for ii = 1:size(marker,1)
                if ~isempty(marker{ii,1})
                    i0 = strfind(txt,marker{ii,1})+marker{ii,2};
                    i0 = i0(1);
                    i1 = iSmaller(find(iSmaller > i0,1))-1;
                    if ~strcmp(txt(i0-1),'>')
                        error('before the number there should be a ">"')
                    end
                    misrad(1,4+ii) = str2num(strrep(txt(i0:i1),',',''));
                end
            end
            misrad(7) = misrad(1)-misrad(2)-misrad(3)-misrad(5)-misrad(6);
            newRow = table(date);
            for iV = 1:length(vars)
                eval(['newRow.',vars{iV},' = misrad(iV);'])
            end
            list(end+1,:) = newRow;
            nanwritetable(list,'data/Israel/Israel_ministry_of_health.csv');
        end
    case 'query'
        data = readtable('data/Israel/dashboard_timeseries.csv');
        fid = fopen('data/Israel/dashboard.json','r');
        txt = fread(fid)';
        fclose(fid);
        txt = native2unicode(txt);
        json = jsondecode(txt);
        jDate = datetime([json(1).data.lastUpdate(1:10),' ',json(1).data.lastUpdate(12:16)])+3/24;
        misrad = [nansum(data.tests_positive),nansum(data.recovered),...
            nansum(data.CountDeath),data.CountBreath(end),data.CountHardStatus(end),...
            data.CountMediumStatus(end),nan,data.Counthospitalized(end),...
            data.patients_home(end)+data.patients_hotel(end),nan];
        misrad(7) = misrad(1)-misrad(2)-misrad(3)-misrad(5)-misrad(6);
        if any(misrad(1:3) > list{end,2:4}) && jDate > list{end,1}
            warning off
            list.date(end+1) = jDate;
            list{end,2:end} = misrad;
             nanwritetable(list,'data/Israel/Israel_ministry_of_health.csv');
        end
        %data.CountEasyStatus(end)
end
