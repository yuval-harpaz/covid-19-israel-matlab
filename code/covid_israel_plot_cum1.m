
list = readtable('data/Israel/Israel_ministry_of_health.csv');
list1 = readtable('data/Israel/dashboard_timeseries.csv');
crit = list(~isnan(list.critical_cumulative),:);
crit_new = 0;
for ii = 2:height(crit)
    if crit.date(ii)-crit.date(ii-1) < 2
        crit_new(ii,1) = crit.critical_cumulative(ii)-crit.critical_cumulative(ii-1);
    else
        crit_new(ii,1) = nan;
    end
end
date = crit.date;
listCrit = table(date,crit_new);
listCrit(isnan(listCrit.crit_new),:) = [];
listCrit.date = dateshift(listCrit.date,'start','day');
for ii = 2:height(listCrit)
    if listCrit.date(ii) == listCrit.date(ii-1)
        listCrit.crit_new(ii-1) = 0;
    end
end
listCrit(listCrit.crit_new == 0,:) = [];


    

x{1} = list1.date(19:end);
y{1} = round(list1.tests_positive(19:end)./list1.tests_result(19:end),3)*100;
x{2} = list1.date(19:end);
y{2} = list1.new_hospitalized(19:end);
x{3} = listCrit.date(1):listCrit.date(end);
y{3} = zeros(size(x{3}));
y{3}(ismember(x{3},listCrit.date)) = listCrit.crit_new;
y{3} = y{3}';

for iLine = 1:3
    y{iLine}(:,2) = movmean(y{iLine}(:,1),[3,3]);
    y{iLine}(:,3) = y{iLine}(:,2)/max(y{iLine}(:,2));
end
y{1}(85:96,3) = y{1}(85:96,1)/max(y{1}(:,1));
%%
figure;
for iLine = 1:3
    h(iLine) = plot(x{iLine},y{iLine}(:,3));
    hold on
end
desiredDates = fliplr(listCrit.date(end):-7:listCrit.date(1));
for iLine = 1:3
    num = round(y{iLine}(ismember(x{iLine},desiredDates),2));
    txt = str(num);
    txt(num == 0,:) = ' ';
    text(desiredDates+1,y{iLine}(ismember(x{iLine},desiredDates),3),txt,'Color',h(iLine).Color);
    scatter(desiredDates,y{iLine}(ismember(x{iLine},desiredDates),3),10,'fill','markerfacecolor',h(iLine).Color)
end
legend('positive tests (%)','new hospitalized','new critical','location','north')
xlim([x{1}(1) x{1}(end)])
box off
set(gca,'YTick',[])
ylim([0 1.1])
