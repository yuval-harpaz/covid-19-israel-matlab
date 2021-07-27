t = readtable('~/Downloads/sec.csv');
mixed = t.casesPer10000(1:4:end);
Arab = t.casesPer10000(2:4:end);
general = t.casesPer10000(3:4:end);
Haredi = t.casesPer10000(4:4:end);
date = t.Date(1:4:end);

sec = table(date,general,Haredi,Arab,mixed);

yy{1} = sec{:,2:end-1};
yy{2} = movmean(sec{8:end,2:end-1}./sec{1:end-7,2:end-1},[3 3]);
yy{2}(end+1:length(yy{1}),:) = nan;
yy{3} = mult.^0.65;
yy{3}(end+1:length(yy{1}),:) = nan;
%%
tit = {'Cases per 10,000 people';'weekly growth factor';'R estimate'};
figure;
for ii = 1:3
    subplot(3,1,ii)
    plot(date,yy{ii})
    if ii == 1
        legend(sec.Properties.VariableNames(2:end-1))
    end
    xlim(date([1,end]))
    title(tit{ii})
    grid on
    box off
end
ylim([0 5])
