clear
cd ~/covid-19-israel-matlab/data/Israel
fid = fopen('data/Israel/log.txt','r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
% lastRead = str2num(txt(find(ismember(txt,','),1,'last')+1:find(ismember(txt,newline),1,'last')-1));
% ii = lastRead-100000;
tt = readtable('symptoms.csv');

ii = 0;
read = true;
tables = {};
json = {};
id = false;
while read
    tic;
    json = urlread(['https://data.gov.il/api/3/action/datastore_search?resource_id=d337959a-020a-4ed3-84f7-fca182292308&limit=100000&offset=',str(ii)]);
    if length(json) > 10000
        %json{ii/100000+1} = strrep(json{ii/100000+1},'NULL',' ');
        json = jsondecode(json);
        clear cell*
        cellDate = {json.result.records(:).test_date}';
        cellDate = cellfun(@(x) datetime([str2num(x(1:4)),str2num(x(6:7)),str2num(x(9:10))]),cellDate);
        cellDateU = unique(cellDate);
        cough = ismember({json.result.records(:).cough}','1');
        fever = ismember({json.result.records(:).fever}','1');
        sore = ismember({json.result.records(:).sore_throat}','1');
        breath = ismember({json.result.records(:).shortness_of_breath}','1');
        head = ismember({json.result.records(:).head_ache}','1');
        nosym = sum([cough,fever,sore,breath,head],2) == 0;
%         sym = sum([cough,fever,sore,breath,head],2) > 0;
        positive = ismember({json.result.records(:).corona_result}','חיובי');
        negative = ismember({json.result.records(:).corona_result}','שלילי');
        other = ismember({json.result.records(:).corona_result}','אחר');
        age = nan(size(other));
        age(ismember({json.result.records(:).age_60_and_above}','Yes')) = 1;
        age(ismember({json.result.records(:).age_60_and_above}','No')) = 0;
        cellID = [json.result.records(:).x_id]';
        if any(ismember(find(id),cellID))
            warning([str(sum(ismember(find(id),cellID))),' duplicates!'])
        end
        id(cellID,1) = true;
        for jj = 1:length(cellDateU)
            today = ismember(cellDate,cellDateU(jj));
            cellPos(jj,1) = sum(today & positive);
            cellNeg(jj,1) = sum(today & negative);
            cellSymPos(jj,1) = sum(today & positive & ~nosym);
            cellSymNeg(jj,1) = sum(today & negative & ~nosym);
%             cellFeverPos(jj,1) = sum(today & positive & fever);
%             cellFeverNeg(jj,1) = sum(today & negative & fever);
%             cellSorePos(jj,1) = sum(today & positive & sore);
%             cellSoreNeg(jj,1) = sum(today & negative & sore);
%             cellBreathPos(jj,1) = sum(today & positive & breath);
%             cellBreatNeg(jj,1) = sum(today & negative & breath);
%             cellHeadPos(jj,1) = sum(today & positive & head);
%             cellHeadNeg(jj,1) = sum(today & negative & head);
            cellNosymPos(jj,1) = sum(today & positive & nosym);
            cellNosymNeg(jj,1) = sum(today & negative & nosym);
            cellOver60(jj,1) = sum(today & age == 1);
            cellBelow60(jj,1) = sum(today & age == 0);
            cellNoAge(jj,1) = sum(today & isnan(age));
            cellOver60pos(jj,1) = sum(today & age == 1 & ~nosym);
            cellOver60breath(jj,1) = sum(today & age == 1 & breath);
        end
        tables{end+1,1} = table(cellDateU,cellPos,cellNeg,cellSymPos,cellSymNeg,...
            cellNosymPos,cellNosymNeg,cellOver60,cellBelow60,cellNoAge,...
            cellOver60pos,cellOver60breath);
        ii = ii+100000;
        disp(datestr(cellDateU(1)))
    else
        read = false;
        %json = json(1:end-1);
        disp('done')
    end
end
date = [];
for ij = 1:length(tables)
    date = [date;tables{ij}.cellDateU];
end
date = unique(date);
neg = zeros(length(date),1);
pos = neg;
symptoms_pos = neg;
symptoms_neg = neg;
nosymptoms_pos = neg;
nosymptoms_neg = neg;
ageover60 = neg;
agebelow60 = neg;
agenull = neg;
ageover60sym_pos = neg;
ageover60breath_pos = neg;
t = table(date,pos,neg,symptoms_pos,symptoms_neg,nosymptoms_pos,nosymptoms_neg,...
    ageover60,agebelow60,agenull,ageover60sym_pos,ageover60breath_pos);
for iDate = 1:length(date)
    for ij = 1:length(tables)
        row = find(ismember(tables{ij}.cellDateU,date(iDate)));
        if ~isempty(row)
            t{iDate,2:end} = t{iDate,2:end}+tables{ij}{row,2:end};
        end
    end
end
%%
lag = 14;
figure;
h(1) = plot(listD.date,listD.CountDeath,'.b');
hold on;
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
h(3) = plot(t.date+lag,movmean(t.pos-t.nosymptoms_pos,[3 3])/50,'k');
legend(h(2:3),'deaths','corona positive with symptoms / 50, 14 days before')
box off
grid on
title({'death-rate prediction under-performs','for Sep, despite younger carriers       '})
ylabel('daily deaths')

%%
newc = readtable('new_critical.csv');
figure;
h(1) = plot(listD.date,listD.CountDeath,'.b');
hold on;
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
h(3) = plot(newc.date+4,movmean(newc.new_critical*0.3,[3 3]),'r');
h(4) = plot(listD.date,movmean(listD.CountHardStatus*0.035,[3 3]),'k');
grid on
box off
ylabel('daily deaths')
legend(h(2:4),'deaths','new critical x 0.3, 4 days before','total critical x 0.035, the same day')
