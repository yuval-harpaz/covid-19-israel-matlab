cd ~/covid-19-israel-matlab/data/Israel
agegen = readtable('dashboard_age_gen.csv');
% col = 62:2:80;
% for ii = 1:length(col)
%     ya(1:height(agegen),ii) = sum(agegen{:,[col(ii),col(ii)+1]},2);
% end
ya = agegen{:,62:end};
NN = [sum(ya(:,1:2:12),2),sum(ya(:,2:2:12),2),ya(:,13:end)];
row = ismember(dateshift(agegen.date,'start','day'),dateshift(agegen.date,'start','month'));
row([false;row(1:end-1)]) = false;
iM = [1;find(row)];

figure;
hm = bar(diff(NN(iM,1:2:end))./sum(diff(NN(iM,1:end)),2)*100+...
    diff(NN(iM,2:2:end))./sum(diff(NN(iM,2:end)),2)*100);
hold on
colorset;
hf = bar(diff(NN(iM,1:2:end))./sum(diff(NN(iM,1:end)),2)*100);
ylabel('אחוז הנפטרים')
title('נפטרים לפי גיל')
legend('<60','60-70','70-80','80-90','90+')
set(gca,'XTickLabel',datestr(datetime(2020,10:10+length(iM)-2,1),'mmm'),'ygrid','on')



% figure;
% plot(diff(NN));
% text((1:5)-0.2,NN+40,str(NN))
% text((1:5)-0.2,NN-40,[str(round(NN/sum(NN)*100)),repmat('%',5,1)],'Color','w','FontWeight','bold');
% ylim([0 max(N)+100])
% set(gca,'XTickLabel',{'<60','60-70','70-80','80-90','90+'},'ygrid','on')
% box off
% set(gcf,'Color','w')
% title(['תמותה לפי גיל מתוך ',str(sum(NN)),' נפטרים (לוח הבקרה)'])
% 
% 
