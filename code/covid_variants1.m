txt = urlread('https://raw.githubusercontent.com/hodcroftlab/covariants/master/web/data/perCountryDataCaseCounts.json');
json = jsondecode(txt);
iIsr = find(ismember({json.regions.distributions(:).country}','Israel'));
isr = struct2table(json.regions.distributions(iIsr).distribution);
week = cellfun(@datetime, isr.week);

variant = fieldnames(isr.stand_estimated_cases);
tt = struct2table(isr.stand_estimated_cases(:));
% if tt.x22A_Omicron_(12) == 1005  % too early for omicron
%     tt.x22A_Omicron_(12) = 0;
%     tt.x22C_Omicron_(12) = 0;
% end
txt = urlread('https://raw.githubusercontent.com/hodcroftlab/covariants/master/web/data/perCountryData.json');
json = jsondecode(txt);
iIsr = find(ismember({json.regions(1).distributions(:).country}','Israel'));
isrData = struct2table(json.regions(1).distributions(iIsr).distribution);
weekData = cellfun(@datetime, isr.week);
ttData = struct2table(isrData.cluster_counts(:));

json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectedPerDate');
json = jsondecode(json);
cases = struct2table(json);
cases.date = datetime(strrep(cases.date,'T00:00:00.000Z',''));

norm2daily = 9291000/10^6/14;
dateH = week+7;
figure;
plot(dateH,sum(tt{:,:},2)*norm2daily,'r')
hold on
plot(cases.date,movmean(cases.amount,[3 3]),'k')
grid on
box off
title('rescaling hodcroftlab to MOH')
legend(['sum(variants)*',str(round(norm2daily,2))],'daily cases','location','northwest')

% thick = [22,7,16,17,18,21,19,20];
varName = {'Others','Alpha','Delta','Omicron BA.1','Omicron BA.2','Omicron BA.2.12.1','Omicron BA.2.75','Omicron BA.4','Omicron BA.5','Omicron BQ.1','Omicron XBB','Daily cases'};
[~,thick] = ismember({'others','x20I_Alpha_V1_','x21J_Delta_','x21K_Omicron_','x21L_Omicron_','x22C_Omicron_','x22D_Omicron_','x22A_Omicron_','x22B_Omicron_','x22E_Omicron_','x22F_Omicron_'},tt.Properties.VariableNames);
yy = tt{:,:}*norm2daily;
yy(yy < 30) = nan;

eventDate = [datetime(2021,02,7), datetime(2021,01,10), datetime(2021,08,1), datetime(2022,3,16)]';
eventTitle = {'end lockdown', 'dose II','dose III', 'Purim'}';
eventY = [8000, 9200, 10000, 8000];
%%
fn = 'serif'; fs = 15; xh = 11000;
tit = {'Variants by wave','Omicron variants'};
figure('Units','Normalized','Position',[0,0,1,1]);
for subp = 1:2
    subplot(1,2,subp)
    hh = plot(dateH,yy);
    hold on
    ha = plot(cases.date(1:end-4),movmean(cases.amount(1:end-4),[3 3]),'k');
    for it = 1:length(thick)
        hh(thick(it)).LineWidth = 2;
    end
    hh(thick(1)).Color = [0.7 0.7 0.7];
    % legend(num2str((1:size(tt,2))'))
    if subp == 2
        line([datetime(2022,3,16) datetime(2022,3,16)],[0 10000],'Color','k','LineStyle','--')
        text(datetime(2022,3,16),8000,'Purim')
    else
        for jj = 1:length(eventDate)
            line([eventDate(jj) eventDate(jj)],[0 eventY(jj)],'Color','k','LineStyle','--')
            text(eventDate(jj),eventY(jj),eventTitle{jj}); % ,'Rotation',90)
        end
    end
    lh = legend([hh(thick);ha], varName,'location','north');
    lh.Position(1) = 0.15; 
    lh.Position(2) = 0.25;
    lh.EdgeColor = 'none';
    box off
    grid on
    ylabel('Estimated daily cases');
    ax = gca;
    ax.YRuler.Exponent = 0;
    ax.YAxis.TickLabelFormat = '%,.0g';
    if subp == 2
        xlim([datetime(2021,12,1) datetime('today')])
        lh.Position(1) = 0.8; 
        lh.Position(2) = 0.25;
        
    else
        xlim([datetime(2020,5,1) datetime('today')])
        text(datetime(2020,5,1),xh,'Wave:     II','FontName',fn,'FontSize', fs)
        text(datetime(2021,1,1),xh,'III','FontName',fn,'FontSize', fs)
        text(datetime(2021,8,1),xh,'IV','FontName',fn,'FontSize', fs)
        text(datetime(2022,2,1),xh,'V','FontName',fn,'FontSize', fs)
        text(datetime(2022,6,1),xh,'VI','FontName',fn,'FontSize', fs)
    end
    title(tit{subp});
    clear hh ha lh
end
set(gcf,'Color','w')
text(datetime('today')-140,4e4,['BA.2.75 total: ',str(sum(ttData.x22D_Omicron_)),...
    ', last measure was ',str(ttData.x22D_Omicron_(end)),...
    ' (',str(round(ttData.x22D_Omicron_(end)/sum(tt{end,:})*100,2)),'%)'],...
    'FontSize',13,'Color','r')
% set(gca,'YScale','log'); ylim([20 10^5])

%%
% 
% shift_cases = 14;
% shift = shift_cases+14;
% death2w = nan(length(week),1);
% cases2w = nan(length(week),1);
% for ii = 1:height(tt)
%     row = find(death.date == week(ii));
%     row = (row-13):row;
%     row = row + shift;
%     if row(end) <= height(death)
%         death2w(ii,1) = sum(death.amount(row));
%     else
%         death2w(ii,1) = nan;
%     end
%     
%     row = find(cases.date == week(ii));
%     row = (row-13):row;
%     row = row + shift_cases;
%     cases2w(ii,1) = sum(cases.amount(row));
% end
% 
% dbv = prc.*death2w;
% cbv = prc.*cases2w;
% figure;
% bar(week,cbv,1,'stacked','EdgeColor','none')
% %%
% figure;
% plot(week,cbv)
% 
% figure;
% bar(week,prc,1,'stacked','EdgeColor','none')
% 
% figure;
% plot(week,dbv)
% 
% %%
% tot = round(nansum(dbv));
% yy = [tot(7);tot(16)+tot(17);tot(18);tot(19);tot(20)];
% figure;
% pie(yy,{['Alpha ',str(yy(1))],['Delta ',str(yy(2))],['Omicron BA1 ',str(yy(3))],...
%     ['Omicron BA2 ',str(yy(4))],['Other ',str(yy(5))]})
% %%
% txt = urlread('https://raw.githubusercontent.com/hodcroftlab/covariants/master/web/data/perClusterData.json');
% jsonClust = jsondecode(txt);
% weekk = cellfun(@datetime, {jsonClust.distributions(end).distribution(:).week}');
% jvr = [1,6:8];
% isr = nan(length(weekk),length(jvr));
% for iVar = 1:length(jvr)
%     fr = {jsonClust.distributions(jvr(iVar)).distribution(:).frequencies}';
%     for ii = 1:length(fr)
%         if isfield(fr{ii},'Israel')
%             isr(ii,iVar) = fr{ii}.Israel;
%         end
%     end
% end
% 
% figure;bar(weekk,isr,1,'stacked','EdgeColor','none')
% legend({jsonClust.distributions(jvr).cluster}')
% 
% %%
% jvr = 7:11;
% omi = nan(length(weekk),length(jvr));
% for iVar = 1:length(jvr)
%     fr = {jsonClust.distributions(jvr(iVar)).distribution(:).frequencies}';
%     for ii = 1:length(fr)
%         if isfield(fr{ii},'Israel')
%             omi(ii,iVar) = fr{ii}.Israel;
%         end
%     end
% end
% %%
% figure('position',[100,100,1000,700]);
% subplot(2,1,1)
% ho = bar(weekk,100*omi,1,'stacked','EdgeColor','none');
% tit = {'22C BA.2.12.1';'22B BA.5';'22A BA.4';'21L BA.2';'21K BA.1'};
% lh1 = legend(fliplr(ho),tit);
% lh1.Position(1) = 0.6; 
% lh1.Position(2) = 0.7;
% lh1.EdgeColor = 'none';
% xlim([datetime(2021,12,1) weekk(end)-3])
% grid on
% set(gca,'XTick',datetime(2021,1:50,1),'layer','top')
% xtickformat('MMM')
% box off
% title('Omicron sub-variants in Israel (%, stacked)')
% hold on
% ylabel('%')
% 
% subplot(2,1,2)
% hol = plot(weekk,100*omi);
% lh = legend(flipud(hol),tit);
% lh.Position(1) = 0.6; 
% lh.Position(2) = 0.2;
% lh.EdgeColor = 'none';
% xlim([datetime(2021,12,1) weekk(end)-3])
% grid on
% set(gca,'XTick',datetime(2021,1:50,1),'layer','top')
% xtickformat('MMM')
% box off
% title('Omicron sub-variants in Israel (%)')
% hold on
% set(gcf,'Color','w')
% ylabel('%')
% %%
% 
% %%
% 
% [~,~] = system('wget -O tmp.csv https://covid19.who.int/WHO-COVID-19-global-data.csv');
% whoData = readtable('tmp.csv');
% whoData.Country = strrep(whoData.Country,'Republic of Korea','South Korea');
% whoData.Country = strrep(whoData.Country,'The United Kingdom','United Kingdom');
% whoData.Country = strrep(whoData.Country,'Russian Federation','Russia');
% whoData.Country = strrep(whoData.Country,'United States of America','USA');
% okayCountry = find(ismember(jsonClust.country_names,whoData.Country));
% % jsonClust.country_names(~okayCountry)
% casesCountryW = nan(length(weekk),length(okayCountry));
% shiftCases = 14;
% for ii = 1:length(weekk)
%     for jj = 1:length(okayCountry)
%         row = find(whoData.x_Date_reported < weekk(ii)+1-shiftCases & ...
%             whoData.x_Date_reported > weekk(ii)-7-shiftCases & ...
%             ismember(whoData.Country,jsonClust.country_names{okayCountry(jj)}));
%         if length(row) == 7
%             casesCountryW(ii,jj) = sum(whoData.New_cases(row));
%         else
%             error('no 7 days');
%         end
%     end
% end
% 
% figure;
% for iVar = 1:length(jvr)
%     fr = {jsonClust.distributions(jvr(iVar)).distribution(:).frequencies}';
%     prcc = nan(length(weekk),length(okayCountry));
%     casc = nan(length(weekk),length(okayCountry));
%     for iCountry = 1:length(okayCountry)
%         for ii = 1:length(fr)
%             cc = jsonClust.country_names{okayCountry(iCountry)};
%             if isfield(fr{ii},cc)
%                 prcc(ii,iCountry) = eval(['fr{ii}.',cc,';']);
%                 casc(ii,iCountry) = casesCountryW(ii,iCountry).*prcc(ii,iVar);
%             end
%         end
%     end
%     subplot(2,2,iVar)
%     plot(weekk,casc)
%     title({jsonClust.distributions(jvr(iVar)).cluster}');
%     if iVar == 1
%         legend(jsonClust.country_names(okayCountry))
%     end
%     ratio = casc(2:end,:)./casc(1:end-1,:);
%     ratio = movmean(ratio,[2,2],'omitnan');
%     ratio(isinf(ratio)) = 0;
%     ratVar(1:length(okayCountry),iVar) = nanmax(ratio);
% end
% 
% nonan = ~any(isnan(ratVar),2);
% figure;
% bar(ratVar(nonan,:))
% set(gca,'Ygrid','on','Xtick',1:sum(nonan),'XTickLabel',jsonClust.country_names(okayCountry(nonan)))
% legend({jsonClust.distributions(jvr).cluster}')
% xtickangle(90)
% title('Maximum weekly multiplication per variant')
% box off
% ylabel('weekly multiplication')
% 
% figure;
% bar(mean(ratVar(nonan,:)),'EdgeColor','none','FaceColor','b')
% hold on
% errorbar(median(ratVar(nonan,:)),std(ratVar(nonan,:)),'Color','k','linestyle','none')
% title('Maximum weekly multiplication per variant')
% set(gca,'YGrid','on','XTickLabel',{jsonClust.distributions(jvr).cluster})
% ylabel('weekly multiplication')
% xtickangle(45)
