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
            cellPosM(jj,1) = sum(today & positive);
            cellNegM(jj,1) = sum(today & negative);
            cellPosF(jj,1) = sum(today & positive);
            cellNegF(jj,1) = sum(today & negative);
            cellPosM60(jj,1) = sum(today & positive & age == 1);
            cellNegM60(jj,1) = sum(today & negative & age == 1);
            cellPosF60(jj,1) = sum(today & positive & age == 1);
            cellNegF60(jj,1) = sum(today & negative & age == 1);
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
neg_f = zeros(length(date),1);
neg_m = neg_f;
pos_f = neg_f;
pos_m = neg_f;
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
t = table(date,pos_f,pos_m,neg_f,neg_m,symptoms_pos_f,symptoms_pos_m,symptoms_neg_f,symptoms_neg_m,...
    nosymptoms_pos_f,nosymptoms_pos_m,nosymptoms_neg_f,nosymptoms_neg_m,...
    pos_f_60,pos_m_60,neg_f_60,neg_m_60,symptoms_pos_f_60,symptoms_pos_m_60,symptoms_neg_f_60,symptoms_neg_m_60,...
    nosymptoms_pos_f_60,nosymptoms_pos_m_60,nosymptoms_neg_f_60,nosymptoms_neg_m_60);
[vn,~] = sort(t.Properties.VariableNames);
[~,order] = ismember(t.Properties.VariableNames,vn)

% symptoms_pos = neg_f;
% symptoms_neg = neg_f;
% nosymptoms_pos = neg_f;
% nosymptoms_neg = neg_f;
% ageover60 = neg_f;
% agebelow60 = neg_f;
% agenull = neg_f;
% ageover60sym_pos = neg_f;
% ageover60breath_pos = neg_f;
% t = table(date,pos_f,neg_f,symptoms_pos,symptoms_neg,nosymptoms_pos,nosymptoms_neg,...
%     ageover60,agebelow60,agenull,ageover60sym_pos,ageover60breath_pos);
for iDate = 1:length(date)
    for ij = 1:length(tables)
        row = find(ismember(tables{ij}.cellDateU,date(iDate)));
        if ~isempty(row)
            t{iDate,2:end} = t{iDate,2:end}+tables{ij}{row,order(2:end)};
        end
    end
end

save symp t
%%
listD = readtable('dashboard_timeseries.csv');
lag = 14;
figure;
h(1) = plot(listD.date,listD.CountDeath,'.b');
hold on;
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
%h(3) = plot(t.date+lag,movmean(t.pos_m+pos_f-t.nosymptoms_pos_m-t.nosymptoms_pos_f,[3 3])/50,'k');
h(3) = plot(t.date+lag,movmean(t.symptoms_pos_m+t.symptoms_pos_f,[3 3])/50,'k');
%h(4) = plot(t.date+lag,movmean(t.pos_f-t.nosymptoms_pos_f,[3 3])/50,'k');
legend(h(2:3),'deaths','corona positive with symptoms / 50, 14 days before')
box off
grid on
title({'death-rate prediction under-performs','for Sep, despite younger carriers       '})
ylabel('daily deaths')

figure;
h(1) = plot(listD.date,listD.CountDeath,'.b');
hold on;
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
%h(3) = plot(t.date+lag,movmean(t.pos_m+pos_f-t.nosymptoms_pos_m-t.nosymptoms_pos_f,[3 3])/50,'k');
h(3) = plot(t.date+lag,movmean(t.symptoms_pos_m-t.symptoms_pos_m_60+t.symptoms_pos_f-t.symptoms_pos_f_60,[3 3])/50,'k');
%h(4) = plot(t.date+lag,movmean(t.pos_f-t.nosymptoms_pos_f,[3 3])/50,'k');
legend(h(2:3),'deaths','corona positive with symptoms / 50, 14 days before')
box off
grid on
title({'death-rate prediction under-performs','for Sep, despite younger carriers       '})
ylabel('daily deaths')


%% 

yy = [t.nosymptoms_pos_m-t.nosymptoms_pos_m_60,t.nosymptoms_pos_f-t.nosymptoms_pos_f_60,...
    t.symptoms_pos_m-t.symptoms_pos_m_60,t.symptoms_pos_f-t.symptoms_pos_f_60,t.symptoms_pos_m_60,t.symptoms_pos_f_60];
yy = movmean(yy,[3 3]);
figure;
plot(yy)
legend('Male < 60','Female < 60','symp Male < 60','symp Female < 60','symp Male > 60','symp Female > 60')

%%
figure;
h(1) = plot(listD.date,listD.CountDeath,'.b');
hold on;
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
h(3) = plot(t.date+lag,movmean(t.pos_m+t.pos_f,[3 3])/200,'k');
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

%% pos > 60







json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = jsondecode(json);
death = json.result.records;
death = struct2table(death);
pos2death = cellfun(@str2num,strrep(death.Time_between_positive_and_death,'NULL','0'));
bad = pos2death < 1 | ismember(death.gender,'לא ידוע');
male = ismember(death.gender(~bad),'זכר');
pos2death = pos2death(~bad);
old = ~ismember(death.age_group,'<65');

prob = movmean(hist(pos2death,1:1000),[3 3]);
iEnd = find(prob < 0.5,1);
prob = prob(1:iEnd-1);
prob = prob/sum(prob);


% pos2death65 = cellfun(@str2num,strrep(t.Time_between_positive_and_death,'NULL','0'));
% pos2death65 = pos2death65(~bad & old);
% prob65 = movmean(hist(pos2death,1:1000),[3 3]);
% iEnd = find(prob65 < 0.5,1);
% prob65 = prob65(1:iEnd-1);
% prob65 = prob65/sum(prob65);
% figure;
% plot([prob;prob65]')
trend = movmean(t.pos_m_60(end-17:end-4)+t.pos_f_60(end-17:end-4),[3 3]);
b = regressBasic((1:14)',trend);
next2w = [ones(14,1),(15:28)']*b;
predLin =  conv([movmean(t.pos_m_60+t.pos_f_60,[3 3]);next2w],prob);
lag = 12;
fac = 20;
pred = conv(movmean(t.pos_m_60+t.pos_f_60,[3 3]),prob);

figure;
h(1) = plot(listD.date,listD.CountDeath,'.b');
hold on;
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
h(3) = plot(t.date+lag,movmean(t.pos_m_60+t.pos_f_60,[3 3])/20,'k--');
h(4) = plot(t.date(2):t.date(1)+length(pred),pred/20,'r--');
h(5) = plot(t.date(2):t.date(1)+length(predLin),predLin/20,'r-.');
h(6) = plot(t.date(1:end-lag)+lag,movmean(t.pos_m_60(1:end-lag)+t.pos_f_60(1:end-lag),[3 3])/20,'k');
h(7) = plot(t.date(2:end),pred(1:end-length(prob))/20,'r');
legend(h([2,6,4,5]),'נפטרים',...
    ['12 יום קודם: ',str(fac),'/','(חיוביים מעל גיל 60)'],...
    'מודל (מחר יש 0 חיוביים)','מודל (ממשיכים שבועיים באותו הקצב)','location','west')
box off
grid on
title('ניבוי תמותה לפי מספר הנבדקים החיוביים מעל גיל 60')
ylabel('נפטרים ליום')
set(gcf,'Color','w')
set(gca,'FontSize',12)

