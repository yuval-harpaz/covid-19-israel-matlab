ini = {'CZ','BE','BA','SI','CO','MK','HU','BG','HR','CH','IL'};
for ii = 1:11
    t = readtable(['2020_',ini{ii},'_Region_Mobility_Report.csv']);
    mob = t{1:266,9:end};
    mob = movmean(movmedian(mob,[3 3]),[3 3]);
%     mob = mob./(-min(mob));
    mob = mean(mob(:,[1,4,5]),2);
    glob(1:length(mob),ii) = mob;
end


co = hsv(10);
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
co(11,1:3) = 0;

figure;
h = plot(t.date(1:266),glob,'linewidth',1);
for ii = 1:11
    h(ii).Color = co(ii,:);
end

xlim([t.date(1) datetime('today')])
box off
grid on
ylabel('שינוי ביחס לשגרה (%)')
title('מדד תנועתיות של גוגל')
