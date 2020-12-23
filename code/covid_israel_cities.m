city = {'ירושלים';'תל אביב';'חיפה';'ראשון לציון';'פתח תקווה';'אשדוד';'נתניה';'באר שבע';'בני ברק';'חולון';'רמת גן';'אשקלון';'רחובות'};
population = [919438;451523;283640;251719;244275;224628;217243;209002;198863;194273;159160;145967;141579];
pop = table(city,population);
for ii = 1:length(city)
    data = urlread(['https://data.gov.il/api/3/action/datastore_search?q=',pop.city{ii},'&resource_id=8a21d39d-91e3-40db-aca1-f73f7ab1df69&limit=10000000']);
    % BB = urlread(['https://data.gov.il/api/3/action/datastore_search?q=%D7%91%D7%A0%D7%99%20%D7%91%D7%A8%D7%A7&resource_id=8a21d39d-91e3-40db-aca1-f73f7ab1df69&limit=10000000');
    data = jsondecode(data);
    data = struct2table(data.result.records);
    % BB(contains(BB.Cumulated_deaths,{'0','<15'}),:) = [];
    dateRow = datetime(data.Date);
    [dateRow,order] = unique(dateRow);
    data = data(order,:);
    data.Cumulated_deaths = strrep(data.Cumulated_deaths,'<15','0');
    deathRow = cellfun(@str2num,data.Cumulated_deaths);
    % date = (dateRow(1):dateRow(end))';
    % death = nan(size(date));
    % death(ismember(date,dateRow)) = deathRow;
    %
    % figure;
    % plot(date(2:end),diff(death),'.','linestyle','-')
    listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
    for month = 3:12
        death(month-2,ii) = deathRow(find(dateRow < datetime(2020,month+1,1),1,'last'));
        %     death(month-2,2) = listD.CountDeathCum(find(listD.date < datetime(2020,month+1,1),1,'last'));
    end
end
ddpm = diff(death)./pop.population'*10^6;
dpm = death(end,:)./pop.population'*10^6;
%%
figure;
subplot(1,2,1)
bar(dpm,'linestyle','none')
set(gca,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מתים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('תמותה למליון סך הכל')
subplot(1,2,2)
% yyaxis left
h1 = plot((4:12),ddpm,'k');
hold on
h2 = plot((4:12),ddpm(:,9),'r','linewidth',2);
legend([h1(1),h2],'ערים בישראל','בני ברק','location','northwest')
set(gcf,'Color','w')
xlim([3.5 12.5])
xlabel('חודש')
ylabel('מתים למליון')
set(gca,'xtick',4:12)
grid on
box off
title('תמותה למליון לחודש')

% yyaxis right
% bar((3:12)+0.15,diff([0;death(:,2)]),'BarWidth',0.3)
% ylim([0 1200])
% title('תמותה')
% xlim([2.5 12.5])
% xlabel('חודש')
% set(gcf,'color','w')
% box off
% set(gca,'ygrid','on')
% set(gca,'ygrid','on','XTick',3:12)
% 
% caseRow = cellfun(@str2num,strrep(data.Cumulative_verified_cases,'<15','0'));
% caseCum = cumsum(listD.tests_positive);
% for month = 3:12
%     cases(month-2,1) = caseRow(find(dateRow < datetime(2020,month+1,1),1,'last'));
%     cases(month-2,2) = caseCum(find(listD.date < datetime(2020,month+1,1),1,'last'));
% end
% 
% figure;
% yyaxis left
% bar((3:12)-0.15,diff([0;cases(:,1)])/1000,'BarWidth',0.3)
% yyaxis right
% bar((3:12)+0.15,diff([0;cases(:,2)])/1000,'BarWidth',0.3)
% ylim([0 150])
% legend('בני ברק','ישראל')
% title('מאומתים (אלפים)')
% xlim([2.5 12.5])
% xlabel('חודש')
% set(gcf,'color','w')
% box off
% set(gca,'ygrid','on','XTick',3:12)
