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