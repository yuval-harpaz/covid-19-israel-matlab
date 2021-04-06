function covid_death_list2
cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
% listD = readtable('dashboard_timeseries.csv');
% newc = readtable('new_critical.csv');
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = strrep(json,'<15','');
json = strrep(json,'NULL','');
json = jsondecode(json);
death = json.result.records;
death = struct2table(death);
deathPrev = readtable('deaths.csv');
if height(death) > height(deathPrev)
    writetable(death,'deaths.csv','Delimiter',',','WriteVariableNames',true);
    death = readtable('deaths.csv');
    update = true;
else
    death = deathPrev;
    update = false;
end


ag = covid_fix_age;
ag.date = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
%%
dday = datetime(2020,12,31);
top = 1200;
mon = unique(month(ag.date));
mon(mon > month(datetime('today'))) = [];
figure;
% subplot(2,ceil((length(mon)+1)/2),1)
row = find(dateshift(ag.date,'start','day') == dday,1,'last');
ya = ag{:,2:11};
NN = [sum(ya(row,1:6)),ya(row,7:end)]';
bar(NN,'EdgeColor','none');
text((1:5)-0.2,NN+40,str(NN))
text((1:5)-0.2,NN-40,[str(round(NN/sum(NN)*100)),repmat('%',5,1)],'Color','w','FontWeight','bold');
ylim([0 top])
set(gca,'XTickLabel',{'<60','60-70','70-80','80-90','90+'},'ygrid','on')
box off
set(gcf,'Color','w')
title(['Deaths in 2020 (',str(sum(NN)),')'])
rowPrev = find(dateshift(ag.date,'start','day') == datetime(2020,12,31),1,'last');
% NN = [sum(ya(end,1:6)),ya(end,7:end)]'-NN;
figure('units','normalized','position',[0,0,1,1]);
for iMon = 1:length(mon)
    subplot(2,ceil((length(mon))/2),iMon)
    row = find(dateshift(ag.date,'start','month') == datetime(2021,mon(iMon),1),1,'last');
    NN = [sum(ya(row,1:6)),ya(row,7:end)]'-[sum(ya(rowPrev,1:6)),ya(rowPrev,7:end)]';
    bar(NN,'EdgeColor','none');
    text((1:5)-0.2,NN+40,str(NN))
    text((1:5)-0.2,NN-20,[str(round(NN/sum(NN)*100)),repmat('%',5,1)],'Color','w','FontWeight','bold');
    ylim([0 top/2])
    set(gca,'XTickLabel',{'<60','60-70','70-80','80-90','90+'},'ygrid','on')
    box off
    set(gcf,'Color','w')
    mName = month(datetime(2021,mon(iMon),1),'name');
    mName = mName{1};
    title(['Deaths in ',mName,' (',str(sum(NN)),')'])
    rowPrev = row;
end