cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
ncba = readtable('severe_by_age.xlsx');
col = [0,0.447,0.741;0.850,0.325,0.0980;0.929,0.694,0.125;0.494,0.184,0.556;0.466,0.674,0.188;0.301,0.745,0.933;0.635,0.0780,0.184];
col3 = [0.906 0.329 0.357;0.271 0.478 0.647;0.439 0.718 0.698];
%%
figure('units','normalized','position',[0.1,0.1,0.4,0.8]);
subplot(2,1,1)
h1 = plot(ncba.date,ncba{:,2:4});
for ii = 1:3
    h1(ii).Color = col3(ii,:);
end
legend('60+','40-60','<40','location','northwest');
grid on
% xtickformat('MMM')
title(['new severe patients by age    ','חולים קשים חדשים לפי גיל'])
set(gca,'xtick',datetime('today')-7^3:7:datetime('today'))
xtickformat('dd/MM')
xlim([ncba.date(1)-1 ncba.date(end)+1])
subplot(2,1,2)
yy = ncba{:,2:4}./sum(ncba{:,2:4},2)*100;
h2 = plot(ncba.date,yy,'.');
hold on
h3 = plot(ncba.date,movmean(yy,[3 3]));
for ii = 1:3
    h2(ii).Color = col3(ii,:);
    h3(ii).Color = col3(ii,:);
end
% legend('60+','40-60','<40','location','northwest');
grid on
% xtickformat('MMM')
title(['new severe patients by age  (%)  ','חולים קשים חדשים לפי גיל '])
set(gcf,'Color','w')
set(gca,'xtick',datetime('today')-7^3:7:datetime('today'))
xtickformat('dd/MM')
xlim([ncba.date(1)-1 ncba.date(end)+1])
%% 
figure;
hcc(1) = scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor',[0,0,0],'MarkerEdgeAlpha',0.5);
hold on
hcc(2) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'-','Color',[0,0,0],'linewidth',1.5);
ylabel('נפטרים')
hcc(3) = plot(ncba.date+7,movmean(ncba.over60,[3 3])*0.47,'-','Color',col3(1,:),'linewidth',1.5);
grid on
legend(hcc([2:3]),['נפטרים',' deceased'],['צפי לפי ','prediction by >60'],'location','northwest')
set(gcf,'Color','w')
title({'ניבוי תמותה שבוע קדימה לפי חולים חדשים במצב קשה וקריטי בני 60+','A week ahead death prediction by new severe patients 60+y/o'})
xtickformat('MMM')
xlim([datetime(2020,7,1) datetime('today')+7])

%%
% json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinationsPerAge');
% json = jsondecode(json);
% vacc = struct2table(json);
% dateVacc = datetime(strrep(vacc.Day_Date,'T00:00:00.000Z',''));
!wget -O tmp.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/vaccinated_by_age.csv
vacc = readtable('tmp.csv');
vaccDate = datetime(cellfun(@(x) x(1:end-4), strrep(strrep(vacc.Date,'T',' '),'Z',''),'UniformOutput',false));
pop60 = sum(vacc{end,17:3:end});
% pop60 = (749+531+308)*1000;
vaccDay = unique(dateshift(vaccDate,'start','day'));
for ii = 1:length(vaccDay)
    row = find(vaccDate < vaccDay(ii)+1,1,'last');
    vacc60(ii,1) = sum(vacc{row,19:3:end});
end
effic = nan(length(vaccDay),1);
for iDay = 1:length(vaccDay)
    try
        effic(iDay) = 1-(ncba{51+iDay,6}/vacc60(iDay))/((ncba{51+iDay,2}-ncba{51+iDay,6})/(pop60-vacc60(iDay)));
    end
end

figure;
% plot(vaccDay+7,movmean(effic,[3 3],'omitnan'))
% plot(vaccDay+7,effic)
nn = ~isnan(effic);
plot(vaccDay(nn)+7,effic(nn))
ylim([0 1])
set(gca,'FontSize',12,'YTickLabel',0:10:100,'YTick',0:0.1:1)
grid on
box off
title({'יעילות החיסון לתחלואה קשה מעל גיל 60','Vaccine Efficiency for severe cases over 60'})
set(gcf,'Color','w')
set(gca,'XTick',datetime(fliplr(dateshift(datetime('today'),'start','week'):-7:datetime(2021,1,17))))
xtickformat('dd/MM')


%%

yyy = cumsum(ncba{:,2:4});

dateWeek = datetime(2021,1,5:7:300);
dateWeek(dateWeek > datetime('today')-3) = [];

for iDate = 1:length(dateWeek)
    week (iDate,1:3) = yyy(ncba.date == dateWeek(iDate)+3,:)-yyy(ncba.date == dateWeek(iDate)+3-7,:);
end
figure('units','normalized','position',[0.1,0.1,0.4,0.5]);
h5 = bar(dateWeek,fliplr(week),'EdgeColor','none');
colGov = flipud([0.855,0.122,0.169;0.141,0.627,0.216;1,0.49,0.157]);
for ii = 1:3
    h5(ii).FaceColor = colGov(ii,:);
end
legend(flipud(h5),'0-39','40-59','60+','location','west');
grid on
title({'חולים חדשים במצב קשה','New severe patients'})
set(gca,'XTick',dateWeek)
xtickangle(45)
xtickformat('yyyy-MM-dd')
set(gcf,'Color','w')
% xtickformat('MMM')
