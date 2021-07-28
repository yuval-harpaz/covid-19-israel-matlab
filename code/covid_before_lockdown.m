cd ~/covid-19-israel-matlab/data/Israel

conf = readtable('confirmed.csv');
date = [conf.date(ismember(conf.coronaEvents,{'סגר 3','סגר 2','סגר 1 '}));datetime('today')];
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
listD.CountBreathNew = [0;diff(listD.CountBreathCum)];
listD.perPos = listD.tests_positive1./listD.tests1;

col = [26,29,7,24,28,14,8,10,13];
disp(listD.Properties.VariableNames(col)')
clear yy
for ii = 1:length(date)
    row = find(ismember(listD.date,date(ii)));
    yy(ii,1:length(col)) = mean(listD{row-7:row-1,col});
end
[mx,ix] = max(movmean(listD{293:end,col},[3 3]));
yys = round(yy);
yys(:,2) = round(yy(:,2)*100,1);
yyn = yy./mx*100;
%%
figure;
subplot(1,3,1:2)
h = bar(yyn(:,1:6));
% txt = cellstr(str(yys));
legend('מאומתים    cases','חיוביים  %  positive','מאושפזים חדשים hospital admissions','קשים   severe','מונשמים   ventilated','מתים   deceased')
set(gca,'XTickLabel',{'lockdown סגר 1','lockdown סגר 2','lockdown סגר 3','today   היום'},'ygrid','on','fontsize',13)
box off
ylabel('% from Jan 21 peak        מהשיא של ינואר 21 %')
title({'New cases before lockdown vs today','תחלואה חדשה לפני הסגרים בהשוואה להיום'})

subplot(1,3,3)
h1 = bar(yyn(:,7:end));
for ii = 1:3
    h1(ii).FaceColor = h(ii+2).FaceColor;
end
ylim([0 100])
% txt = cellstr(str(yys));
legend('מאושפזים  hospitalized','קשים   severe','מונשמים   ventilated')
set(gca,'XTickLabel',{'סגר 1','סגר 2','סגר 3','היום'},'ygrid','on','fontsize',13)
box off
ylabel('% from Jan 21 peak        מהשיא של ינואר 21 %')
title({'Active cases before lockdown vs today','חולים פעילים לפני הסגרים בהשוואה להיום'})

%%
figure;
subplot(1,3,1:2)
h2 = bar(yyn(:,1:6)');
% txt = cellstr(str(yys));
legend('סגר 1','סגר 2','סגר 3','היום')
set(gca,'XTickLabel',{'מאומתים cases','חיוביים % positive','מאושפזים hosp','קשים severe','מונשמים   ventilated','מתים   deceased'})
set(gca,'ygrid','on','fontsize',13)
box off
ylabel('% from Jan 21 peak        מהשיא של ינואר 21 %')
title({'New cases before lockdown vs today','תחלואה חדשה לפני הסגרים בהשוואה להיום'})

subplot(1,3,3)
h3 = bar(yyn(:,7:end)');
ylim([0 100])
% txt = cellstr(str(yys));
legend('lockdown 1','lockdown 2','lockdown 3','today')
set(gca,'XTickLabel',{'hospitalized','severe','ventilated'},'ygrid','on','fontsize',13)
box off
ylabel('% from Jan 21 peak        מהשיא של ינואר 21 %')
title({'Active cases before lockdown vs today','חולים פעילים לפני הסגרים בהשוואה להיום'})
set(gcf,'Color','w')
% json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=32150ead-89f2-461e-9cc3-f785e9e8608f&limit=5000');
% json = jsondecode(json);
% t = struct2table(json.result.records);
% 
% t60 = t(ismember(t.age_group,'60+'),:);
% weekStartVacc = datetime(cellfun(@(x) x(1:10),t60.First_dose_week,'UniformOutput',false));
% [weekVacc,order] = sort(weekStartVacc);
% t60 = t60(order,:);
% % weekVacc = (min(weekStartVacc):7:max(weekStartVacc))';
% weekInfec = datetime(cellfun(@(x) strrep(x(10:19),'_','-'),t60.Properties.VariableNames(5:end),'UniformOutput',false))';
% % weekInfec = (min(weekStartInfec):7:max(weekStartInfec))';
% cells = t60{:,5:end};
% cells(cellfun(@isempty, cells)) = {'0'};
% cells = strrep(cells,'1-5','2.5');
% cases = cellfun(@str2num, cells);
% cases(cases == -4) = 8;
% cpm = round(cases./cellfun(@str2num, t60.group_size).*10^6,1);
% cpm4 = movsum(cpm,[2 2]);
% pct = cpm4./sum(cpm4);
% col = flipud(jet(length(weekVacc)));
% yy{1} = cpm4;
% yy{3} = pct;
% 
% t_ = t(ismember(t.age_group,'<60'),:);
% weekStartVacc = datetime(cellfun(@(x) x(1:10),t_.First_dose_week,'UniformOutput',false));
% [weekVacc,order] = sort(weekStartVacc);
% t_ = t_(order,:);
% % weekVacc = (min(weekStartVacc):7:max(weekStartVacc))';
% weekInfec = datetime(cellfun(@(x) strrep(x(10:19),'_','-'),t_.Properties.VariableNames(5:end),'UniformOutput',false))';
% % weekInfec = (min(weekStartInfec):7:max(weekStartInfec))';
% cells = t_{:,5:end};
% cells(cellfun(@isempty, cells)) = {'0'};
% cells = strrep(cells,'1-5','2.5');
% cases = cellfun(@str2num, cells);
% cases(cases == -4) = 8;
% cpm = round(cases./cellfun(@str2num, t_.group_size).*10^6,1);
% cpm4 = movsum(cpm,[2 2]);
% pct = cpm4./sum(cpm4);
% col = flipud(jet(length(weekVacc)));
% yy{2} = cpm4;
% yy{4} = pct;
% tit= {'Amount of 60+ y/o infections by date and vaccine age',...
%     'Amount of <60 y/o infections by date and vaccine age',...
%     'Ratio of 60+ y/o infections by date and vaccine age',...
%     'Ratio of <60 y/o infections by date and vaccine age'};
% %%
% figure;
% for isp = 1:4
%     subplot(2,2,isp)
%     for ii = 1:length(weekVacc)
%         if ii == 1
%             prev = zeros(1,length(weekInfec));
%             %     else
%             %         prev = fliplr(cumsum(cpm(1:ii-1,:)));
%         end
%         curr = sum(yy{isp}(1:ii,:),1);
%         h(ii) = fill([weekInfec;flipud(weekInfec)],[curr,prev],col(ii,:),'LineStyle','none');
%         prev = fliplr(curr);
%         hold on
%     end
%     xlim(weekInfec([1,end]))
%     if isp > 2
%         ylim([0 1])
%         set(gca,'YTick',0:0.1:1,'YTickLabel',0:10:100)
%         ylabel('% of aged vaccines')
%     else
%         ax = gca;
%         ax.YRuler.Exponent = 0;
%         ax.YAxis.TickLabelFormat = '%,.0g';
%         ylabel('aged vaccine cases per 1M per 5 weeks')
%         ylim([0 100000])
%     end
%     box off
%     set(gca,'Layer','top')
%     
%     title(tit{isp})
% end
% set(gcf,'Color','w')