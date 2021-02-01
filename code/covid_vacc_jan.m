confOld = [5921,151,155,441,95,307;3989,90,97,251,59,120;890,28,11,50,9,17;480,10,17,16,5,3];
confYoung = [13379,67,47,81,23,13;3874,17,12,22,6,0;791,3,1,3,0,1;253,2,0,1,2,0];

col = [1 0.992 0.231;1 0.745 0.176;1 0 0.07;0.776 0 0.043;0 0 0];
figure;
subplot(2,2,1)
ho = bar(confOld(:,2:end),'EdgeColor','none');
for ii = 1:5
    ho(ii).FaceColor = col(ii,:);
end
subplot(2,2,2)
bar(confYoung(:,2:end))

data = {confOld,confYoung};
tit = {'60+','<60'};
figure;
for ip = 1:2
    subplot(1,2,ip)
    h{ip} = bar(data{ip}(:,2:end)./sum(data{ip},2)*100,'EdgeColor','none');
    for ii = 1:5
        h{ip}(ii).FaceColor = col(ii,:);
    end
    title(tit{ip})
    set(gca,'XTickLabel',{'עד שבועיים ממנה ראשונה','יותר משבועיים ממנה ראשונה','עד שבוע ממנה שניה','שבוע ומעלה ממנה שניה'},...
        'ygrid','on','FontSize',13)
    if ip == 1
        ylim([0 10])
        legend('קל','בינוני','קשה','קריטי','נפטר','location','northwest')
    else
        ylim([0 1])
    end
    xtickangle(15)
    ylabel('חולים באחוזים')
    box off
end
set(gcf,'Color','w')

figure;
for ip = 1:2
    subplot(1,2,ip)
    h{ip} = bar(data{ip}(:,2:end)./sum(data{ip},2)*100,'EdgeColor','none');
    for ii = 1:5
        h{ip}(ii).FaceColor = col(ii,:);
    end
    title(tit{ip})
    ylim([0 10])
    set(gca,'XTickLabel',{'day 0-13 from dose 1','14 days + from dose 1','0-6 days from dose 2','7 days + from dose 2'},...
        'ygrid','on','FontSize',13)
    if ip == 1
        legend('mild','medium','severe','critical','deceased','location','northwest')
    end
    xtickangle(15)
    ylabel('percents of patients')
    box off
end
set(gcf,'Color','w')