
cd ~/covid-19-israel-matlab/data/Israel
tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
newc = readtable('new_critical.csv');
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

u = unique(death.age_group);
u = u([4,1,2,3]);
for ii = 1:4
    N(ii,1) = sum(ismember(death.age_group,u{ii}));
end
% figure;
% subplot(1,2,1)
% bar(N,'EdgeColor','none');
% text((1:4)-0.2,N+40,str(N))
% h = text((1:4)-0.2,N-40,[str(round(N/sum(N)*100)),repmat('%',4,1)],'Color','w','FontWeight','bold');
% ylim([0 max(N)+100])
% set(gca,'XTickLabel',u,'ygrid','on')
% box off
% set(gcf,'Color','w')
% title(['תמותה לפי גיל מתוך ',str(sum(N)),' נפטרים (מאגר מידע)'])

agegen = readtable('dashboard_age_gen.csv');
col = 62:2:80;
for ii = 1:length(col)
    ya(1:height(agegen),ii) = sum(agegen{:,[col(ii),col(ii)+1]},2);
end
NN = [sum(ya(end,1:6)),ya(end,7:end)]';
subplot(1,2,2)

bar(NN,'EdgeColor','none');
text((1:5)-0.2,NN+40,str(NN))
text((1:5)-0.2,NN-40,[str(round(NN/sum(NN)*100)),repmat('%',5,1)],'Color','w','FontWeight','bold');
ylim([0 max(N)+100])
set(gca,'XTickLabel',{'<60','60-70','70-80','80-90','90+'},'ygrid','on')
box off
set(gcf,'Color','w')
title(['תמותה לפי גיל מתוך ',str(sum(NN)),' נפטרים (לוח הבקרה)'])
%%
dday = datetime(2020,12,31);
top = 1200;
mon = unique(month(agegen.date));
mon(end-2:end) = [];
figure('units','normalized','position',[0,0.25,1,0.75]);
subplot(1,length(mon)+1,1)
row = find(dateshift(agegen.date,'start','day') == dday,1,'last');
NN = [sum(ya(row,1:6)),ya(row,7:end)]';
bar(NN,'EdgeColor','none');
text((1:5)-0.2,NN+40,str(NN))
text((1:5)-0.2,NN-40,[str(round(NN/sum(NN)*100)),repmat('%',5,1)],'Color','w','FontWeight','bold');
ylim([0 top])
set(gca,'XTickLabel',{'<60','60-70','70-80','80-90','90+'},'ygrid','on')
box off
set(gcf,'Color','w')
title(['Deaths in 2020 (',str(sum(NN)),')'])
rowPrev = find(dateshift(agegen.date,'start','day') == datetime(2020,12,31),1,'last');
% NN = [sum(ya(end,1:6)),ya(end,7:end)]'-NN;

for iMon = 1:length(mon)
    subplot(1,length(mon)+1,iMon+1)
    row = find(dateshift(agegen.date,'start','month') == datetime(2021,mon(iMon),1),1,'last');
    NN = [sum(ya(row,1:6)),ya(row,7:end)]'-[sum(ya(rowPrev,1:6)),ya(rowPrev,7:end)]';
    bar(NN,'EdgeColor','none');
    text((1:5)-0.2,NN+40,str(NN))
    text((1:5)-0.2,NN-20,[str(round(NN/sum(NN)*100)),repmat('%',5,1)],'Color','w','FontWeight','bold');
    ylim([0 top])
    set(gca,'XTickLabel',{'<60','60-70','70-80','80-90','90+'},'ygrid','on')
    box off
    set(gcf,'Color','w')
    mName = month(datetime(2021,mon(iMon),1),'name');
    mName = mName{1};
    title(['Deaths in ',mName,' (',str(sum(NN)),')'])
    rowPrev = row;
end