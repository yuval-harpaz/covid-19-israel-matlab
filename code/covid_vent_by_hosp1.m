cd ~/covid-19-israel-matlab/data/Israel
t = readtable('vent_per_hosp.csv');

date = unique(t.date);
nHosp = length(unique(t.hosp));
clear yy
for ii = 1:length(date)
    yy(1:nHosp,ii) = t.crit(t.date == date(ii),:);
end

figure('units','normalized','position',[0,0.2,1,0.6]);
h = bar(yy,'EdgeColor','none');
set(gca,'XTickLabel',t.hosp(1:nHosp),'xtick',1:nHosp,'ygrid','on')
xtickangle(90)
box off
legend(datestr(date))
title('קריטיים')
set(gcf,'Color','w')

%%
dates = t.date([1,119,270]);
figure;
for ip = 1:length(dates)
    
    t1 = t(ismember(t.date,date(ip)),:);
    subplot(length(dates),1,ip)
    h3 = bar([t1.vent-t1.ecmo,t1.ecmo,t1.crit-t1.vent],'stacked','EdgeColor','none');
    tmp = h3(2).FaceColor;
    h3(2).FaceColor = [0.4940    0.1840    0.5560]*1.5;
    h3(3).FaceColor = tmp;
    if ip == 1
        legend(h3([3,2,1]),'ללא הנשמה \ אקמו','אקמו','הנשמה חודרנית')
    end
    set(gcf,'Color','w')
    set(gca,'XTickLabel',t1.hosp,'xtick',1:height(t1),'ygrid','on')
    xtickangle(90)
    box off
    ylim([0 50])
    grid on
    title(datestr(dates(ip)))
end