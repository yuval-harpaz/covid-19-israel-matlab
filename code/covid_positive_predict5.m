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
                abort = false;
                read = false;
            end
            cough = ismember({json.result.records(:).cough}','1');
            fever = ismember({json.result.records(:).fever}','1');
            sore = ismember({json.result.records(:).sore_throat}','1');
            breath = ismember({json.result.records(:).shortness_of_breath}','1');
            head = ismember({json.result.records(:).head_ache}','1');
            sym = sum([cough,fever,sore,breath,head],2) > 0;
            positive = ismember({json.result.records(:).corona_result}','חיובי');
            negative = ismember({json.result.records(:).corona_result}','שלילי');
            other = ismember({json.result.records(:).corona_result}','אחר');
            age = nan(size(other));
            age(ismember({json.result.records(:).age_60_and_above}','Yes')) = 1;
            age(ismember({json.result.records(:).age_60_and_above}','No')) = 0;
            male = ismember({json.result.records.gender},'זכר')';
            female = ismember({json.result.records.gender},'נקבה')';
            cellID = [json.result.records(:).x_id]';
            if any(ismember(find(id),cellID))
                warning([str(sum(ismember(find(id),cellID))),' duplicates!'])
            end
            id(cellID,1) = true;
            for jj = 1:length(cellDateU)
                today = ismember(cellDate,cellDateU(jj));
                cellPos(jj,1) = sum(today & positive);
                cellNeg(jj,1) = sum(today & negative);
                
                cellPosM(jj,1) = sum(today & positive & male);
                cellNegM(jj,1) = sum(today & negative & male);
                cellPosF(jj,1) = sum(today & positive & female);
                cellNegF(jj,1) = sum(today & negative & female);
                
                cellPos60(jj,1) = sum(today & positive & age == 1);
                cellNeg60(jj,1) = sum(today & negative & age == 1);
                
                cellPosM60(jj,1) = sum(today & positive & age == 1 & male);
                cellNegM60(jj,1) = sum(today & negative & age == 1 & male);
                cellPosF60(jj,1) = sum(today & positive & age == 1 & female);
                cellNegF60(jj,1) = sum(today & negative & age == 1 & female);
                cellSymPosM(jj,1) = sum(today & positive & sym & male);
                cellSymPosF(jj,1) = sum(today & positive & sym & female);
                cellSymNegM(jj,1) = sum(today & negative & sym & male);
                cellSymNegF(jj,1) = sum(today & negative & sym & female);
                cellNoSymPosM(jj,1) = sum(today & positive & ~sym & male);
                cellNoSymPosF(jj,1) = sum(today & positive & ~sym & female);
                cellNoSymNegM(jj,1) = sum(today & negative & ~sym & male);
                cellNoSymNegF(jj,1) = sum(today & negative & ~sym & female);
                
                cellSymPosM60(jj,1) = sum(today & positive & sym & male & age == 1);
                cellSymPosF60(jj,1) = sum(today & positive & sym & female & age == 1);
                cellSymNegM60(jj,1) = sum(today & negative & sym & male & age == 1);
                cellSymNegF60(jj,1) = sum(today & negative & sym & female & age == 1);
                cellNoSymPosM60(jj,1) = sum(today & positive & ~sym & male & age == 1);
                cellNoSymPosF60(jj,1) = sum(today & positive & ~sym & female & age == 1);
                cellNoSymNegM60(jj,1) = sum(today & negative & ~sym & male & age == 1);
                cellNoSymNegF60(jj,1) = sum(today & negative & ~sym & female & age == 1); %#ok<*SAGROW>
                
                
            end
            varName = who('cell*')';
            varName(ismember(varName,'cellDate')) = [];
            varName(ismember(varName,'cellID')) = [];
            varName = join(varName,',');
            tables{end+1,1} = eval(['table(',varName{1},');']);
            %         tables{end+1,1} = table(cellDateU,cellPos,cellNeg,cellSymPos,cellSymNeg,...
            %             cellNosymPos,cellNosymNeg,cellOver60,cellBelow60,cellNoAge,...
            %             cellOver60pos,cellOver60breath);
            ii = ii+100000;
            disp(datestr(cellDateU(1)))
            err = o;
            if datenum(prev.date(end)-cellDateU(1)) > 31
                read = true;
                %json = json(1:end-1);
                disp('done')
            end
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
neg_f = zeros(length(date),1);
neg_m = neg_f;
pos_f = neg_f;
pos_m = neg_f;
pos = neg_f;
neg = neg_f;
pos60 = neg_f;
neg60 = neg_f;
symptoms_neg_f = neg_f;
symptoms_neg_m = neg_f;
symptoms_pos_f = neg_f;
symptoms_pos_m = neg_f;
nosymptoms_neg_f = neg_f;
nosymptoms_neg_m = neg_f;
nosymptoms_pos_f = neg_f;
nosymptoms_pos_m = neg_f;

neg_f_60 = neg_f;
neg_m_60 = neg_f;
pos_f_60 = neg_f;
pos_m_60 = neg_f;
symptoms_neg_f_60 = neg_f;
symptoms_neg_m_60 = neg_f;
symptoms_pos_f_60 = neg_f;
symptoms_pos_m_60 = neg_f;
nosymptoms_neg_f_60 = neg_f;
nosymptoms_neg_m_60 = neg_f;
nosymptoms_pos_f_60 = neg_f;
nosymptoms_pos_m_60 = neg_f;
t = table(date,pos,neg,pos60,neg60,pos_f,pos_m,neg_f,neg_m,symptoms_pos_f,symptoms_pos_m,symptoms_neg_f,symptoms_neg_m,...
    nosymptoms_pos_f,nosymptoms_pos_m,nosymptoms_neg_f,nosymptoms_neg_m,...
    pos_f_60,pos_m_60,neg_f_60,neg_m_60,symptoms_pos_f_60,symptoms_pos_m_60,symptoms_neg_f_60,symptoms_neg_m_60,...
    nosymptoms_pos_f_60,nosymptoms_pos_m_60,nosymptoms_neg_f_60,nosymptoms_neg_m_60);
% [~,po] = sort(t.Properties.VariableNames)
% t = t(:,po);
[vn,~] = sort(t.Properties.VariableNames);
[~,order] = ismember(t.Properties.VariableNames,vn);

for iDate = 1:length(date)
    for ij = 1:length(tables)
        row = find(ismember(tables{ij}.cellDateU,date(iDate)));
        if ~isempty(row)
            t{iDate,2:end} = t{iDate,2:end}+tables{ij}{row,order(2:end)};
        end
    end
end
t = t(8:end,:);  % discard early dates with possible missing data
startUpdate = find(ismember(prev.date,t.date(1)));
prev(startUpdate:startUpdate+height(t)-1,:) = t;
% save symp t
writetable(prev,'tests.csv','Delimiter',',','WriteVariableNames',true)
%%
covid_pred_plot;
