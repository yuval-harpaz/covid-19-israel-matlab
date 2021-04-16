cases = readtable('~/Downloads/cases-among-vaccinated-10.csv','Delimiter',',');
week = unique(cases.x_Week);
clear y
for ii = 1:length(week)
    for jj = 1:4
        cl = strrep(cases{ismember(cases.x_Week,week(ii)),2+jj},'<5','2.5');
        cl(cellfun(@isempty,cl)) = {'0'};
        y(ii,jj) = sum(cellfun(@str2num,cl));
    end
end

col = jet(5);
col = flipud(col(:,[1,3,2]));
col = col([1,3:end],:);
figure;
h = plot(y);
for ii = 1:4
    h(ii).Color = col(ii,:);
end
legend('1 week','2 weeks','3 weeks','4 weeks')
set(gca,'XTickLabel',week,'xtick',1:length(week))
xtickangle(35)
grid on
set(gcf,'Color','w')
title('vaccinated cases: week of positive test from dose I (color) by date (x-axis)')
ylabel('cases')

yy = [y(1:end-3,1),y(2:end-2,2),y(3:end-1,3),y(4:end,4)];
figure;
hh = plot(yy./sum(yy,2))
for ii = 1:4
    hh(ii).Color = col(ii,:);
end
