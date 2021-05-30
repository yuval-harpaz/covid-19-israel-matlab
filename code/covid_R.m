json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectionFactor');
json = jsondecode(json);
t = struct2table(json);
date = datetime(strrep(t.day_date,'T00:00:00.000Z',''));
ful = ~cellfun(@isempty ,t.R);
R = nan(length(date),1);
R(ful,1) = cellfun(@(x) x,t.R(ful));



listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
mm = movmean(listD.tests_positive,[6 0]);
% mm = floor(movmean(listD.tests_positive,[6 0]));
days = 7;
rr = mm(days+1:end)./mm(1:end-days);

%%
pow = 0.65;
shift = 3;
figure;
yyaxis left
plot(date,R,'LineWidth',2)
hold on;
plot(listD.date(1)-shift:listD.date(end)-days-shift,rr.^pow,':k','LineWidth',1.5)
ylim([0 2])
ylabel('R')
yyaxis right
plot(listD.date,movmean(listD.tests_positive,[3 3]))
hold on
plot(listD.date,listD.tests_positive,':')
ylim([0 10000])
xtickformat('MMM')
set(gca,'xtick',datetime(2020,4:30,1))
set(gcf,'Color','w')
title('cases vs R מאומתים מול')
ylabel('Cases')
xlim([datetime(2020,6,1) datetime('tomorrow')])
legend('R','R estimate','cases','location','north')
grid on
% title(pow)
%%

columns = listD(:,[1,4,7,14,20,24]);
columns.CountBreathCum(2:end) = diff(columns.CountBreathCum);
mmm = movmean(columns{:,2:end},[6 0]);
mmm(mmm == 0) = 0.1;
rrr = mmm(days+1:end,:)./mmm(1:end-days,:);
figure;
h = plot(listD.date(1)-shift:listD.date(end)-days-shift,rrr);
legend('positive','hospitalized','dead','ventilated','severe','location','northwest')
xlim([datetime(2020,10,15) datetime('tomorrow')])
ylim([0 3])
grid on
set(gca,'FontSize',13)
ylabel('R estimate')



%%
figure;
yyaxis left
% plot(date,R,'LineWidth',2)
% hold on;
Rest = rr.^pow;
t = listD.date(1)-shift:listD.date(end)-days-shift;
date1 = dateshift(datetime('today'),'start','week')-22;
i1 = find(ismember(t,date1));
plot(t(i1:end),Rest(i1:end),'b','LineWidth',2,'Marker','o','MarkerFaceColor',...
    'b','MarkerEdgeColor','none')
iD1 = find(ismember(listD.date,date1));
ylim([-1 2])
ylabel('R')
yyaxis right
bar(listD.date(iD1:end),listD.tests_positive(iD1:end),'FaceColor',[0.8 0.8 0.8])
hold on
bar(listD.date(end-6:end),listD.tests_positive(end-6:end),'FaceColor',[0.8 0.2 0.2])
bar(listD.date(end-13:end-7),listD.tests_positive(end-13:end-7),'FaceColor',[0.8 0.5 0.5])
ylim([0 100])
ylabel('Cases')


% figure;
% for ii = 1:7
%     plot(t(i1+ii-1:7:end),Rest(i1+ii-1:7:end),'.','LineWidth',2)
%     hold on
% end
% plot(listD.date,listD.tests_positive,':')
% ylim([0 10000])
% xtickformat('MMM')
% set(gca,'xtick',datetime(2020,4:30,1))
% set(gcf,'Color','w')
% title('cases vs R מאומתים מול')
% ylabel('Cases')
% xlim([datetime(2020,6,1) datetime('tomorrow')])
% legend('R','R estimate','cases','location','north')
% grid on
