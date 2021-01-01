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
writetable(death,'deaths.csv','Delimiter',',','WriteVariableNames',true);
death = readtable('deaths.csv');
u = unique(death.age_group);
u = u([4,1,2,3]);
for ii = 1:4
    N(ii,1) = sum(ismember(death.age_group,u{ii}));
end
figure;
subplot(1,2,1)
bar(N,'EdgeColor','none');
text((1:4)-0.2,N+40,str(N))
h = text((1:4)-0.2,N-40,[str(round(N/sum(N)*100)),repmat('%',4,1)],'Color','w','FontWeight','bold');
ylim([0 max(N)+100])
set(gca,'XTickLabel',u,'ygrid','on')
box off
set(gcf,'Color','w')
title(['תמותה לפי גיל מתוך ',str(sum(N)),' נפטרים (מאגר מידע)'])

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


