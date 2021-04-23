clear
cd ~/covid-19-israel-matlab/data/Israel
prev = readtable('tests.csv');
ii = 0;
read = true;
tables = {};
json = {};
id = false;
%% loop read
abort = false;
err = 0;
while read
    try
        json = urlread(['https://data.gov.il/api/3/action/datastore_search?resource_id=d337959a-020a-4ed3-84f7-fca182292308&limit=100000&offset=',str(ii)]);
        if length(json) > 10000
            %json{ii/100000+1} = strrep(json{ii/100000+1},'NULL',' ');
            json = jsondecode(json);
            clear cell*
            cellDate = {json.result.records(:).test_date}';
            cellDate = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDate);
            cellDateU = unique(cellDate);
            if ii == 0 && cellDateU(end) <= prev.date(end)
                warning('No new dates?')
                abort = true;
                read = false;
            end
            abroad = ismember({json.result.records(:).test_indication}','Abroad') &...
                ismember({json.result.records(:).corona_result}','חיובי');
            cellID = [json.result.records(:).x_id]';
            if any(ismember(find(id),cellID))
                warning([str(sum(ismember(find(id),cellID))),' duplicates!'])
            end
            id(cellID,1) = true;
            for jj = 1:length(cellDateU)
                today = ismember(cellDate,cellDateU(jj));
                cellAbroad(jj,1) = sum(abroad & today);
            end
            varName = who('cell*')';
            varName(ismember(varName,'cellDate')) = [];
            varName(ismember(varName,'cellID')) = [];
            varName = join(varName,',');
            tables{end+1,1} = table(cellDateU,cellAbroad);
            %         tables{end+1,1} = table(cellDateU,cellPos,cellNeg,cellSymPos,cellSymNeg,...
            %             cellNosymPos,cellNosymNeg,cellOver60,cellBelow60,cellNoAge,...
            %             cellOver60pos,cellOver60breath);
            ii = ii+100000;
            disp(datestr(cellDateU(1)))
            err = 0;
            if datenum(prev.date(end)-cellDateU(1)) > 31
                read = false;
                %json = json(1:end-1);
                disp('done')
            end
        
        elseif length(tables) == 0
            disp('no data, table is updating?')
            abort = 1;
        else
            read = false;
            %json = json(1:end-1);
            disp('done')
        end
    catch
        err = err+1;
        if err >= 10
            error('10 attemts failed')
        else
            pause(5)
        end
    end
end
if abort
    error('aborted, no new dates')
end
%%
date = [];
for ij = 1:length(tables)
    date = [date;tables{ij}.cellDateU];
end
date = unique(date);
abroad = zeros(length(date),1);

t = table(date,abroad);
% [vn,~] = sort(t.Properties.VariableNames);
% [~,order] = ismember(t.Properties.VariableNames,vn);

for iDate = 1:length(date)
    for ij = 1:length(tables)
        row = find(ismember(tables{ij}.cellDateU,date(iDate)));
        if ~isempty(row)
            t{iDate,2} = t{iDate,2}+tables{ij}.cellAbroad(row);
        end
    end
end
% t = t(8:end,:);  % discard early dates with possible missing data
% startUpdate = find(ismember(prev.date,t.date(1)));
% prev(startUpdate:startUpdate+height(t)-1,:) = t;
% % save symp t
% writetable(prev,'tests.csv','Delimiter',',','WriteVariableNames',true)
% %%
% covid_pred_plot2;
