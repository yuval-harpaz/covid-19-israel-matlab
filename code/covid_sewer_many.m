function covid_sewer_many
cd ~/Downloads/
fName = dir('Waste*');
fName = {fName(:).name}';
% figure;
for iWaste = 2:length(fName)
    T = readtable(fName{iWaste});
    lenDate = cellfun(@length, T.Start_Week_Date);
    Start_Week_Date = NaT;
    for iDate = 1:height(T)
        if lenDate(iDate) == 20
            Start_Week_Date(iDate,1) = datetime(T.Start_Week_Date{iDate}(1:10));
        elseif lenDate(iDate) == 11
            Start_Week_Date(iDate,1) = datetime(T.Start_Week_Date{iDate},'InputFormat','dd-MMM-yyyy');
        else
            error('wdf?')
        end
    end
            
    date = unique(Start_Week_Date);
    disp(date(end))
%     town = unique(T.SE_Name);
%     NVL = cellfun(@str2num, T.NVL);
%     % NVL = strrep(T.NVL,'NULL','nan');
%     % NVL = cellfun(@str2num, NVL);
% %     nvl = nan(size(date));
% %     nvln = nan(size(date));
% %     nNan = nan(size(date));
%     for ii = 1:length(date)
%         rows = Start_Week_Date == date(ii);
% %         nvl(ii,1) = nanmean(NVL(rows));
%         pop = cellfun(@str2num, T.Population_For_Normalization(rows));
%         nvln(ii,iWaste-1) = nansum(NVL(rows).*pop)/sum(pop);
%         nNan(ii,iWaste-1) = sum(isnan(NVL(rows)).*pop)/sum(pop);
%     end
    
%     plot(date,nvln,'linewidth',5-iWaste,'DisplayName',fName{iWaste})
%     hold on
end
% figure;
% bar(nNan)
% %%

% 
% json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectedPerDate');
% json = jsondecode(json);
% json = struct2table(json);
% dateCases = datetime(json.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
% for ii = 1:length(date)
%     d1 = find(dateCases == date(ii));
%     cases(ii,1) = sum(json.amount(d1:min(d1+6,height(json))));
% end
% 
% 
% figure;
% plot(date,nvln/10,'b')
% hold on
% plot(date,cases,'g')
% 
% figure;
% bar(date,nvln,0.75, 'EdgeColor','none')
% set(gca,'YScale','log')
% ylim([70000 10^7])
% grid on
% box off
% title('COVID-19 in Waste water ')
% ylabel('NVL')
% set(gcf,'Color','w')
% set(gca,'XTick',date,'layer','top')
% xtickangle(90)
% xtickformat('dd.MM.yy')
% xlabel('Start week date')
% % 
% % active = readtable('~/Downloads/active1.csv','Delimiter',',');
% % % dateActive = datetime(cellfun(@(x) x(1:19),active.Date,'UniformOutput',false), 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss');
% % dateActive = datetime(cellfun(@(x) x(1:10),active.Date,'UniformOutput',false), 'InputFormat', 'yyyy-MM-dd');
% % dateActiveU = unique(dateActive);
% % activeU = nan(size(dateActiveU));
% % for ii = 1:length(activeU)
% %     activeU(ii) = max(active.active(dateActive == dateActiveU(ii)));
% % end
% % %%
% % figure;
% % plot(date+5,nvl/10,'r','linewidth',2)
% % hold on
% % plot(dateActiveU,activeU,'b','linewidth',2)
% % legend('Swere/8\ביוב','Active cases חולים פעילים')
% % grid on
% % set(gca,'YScale','log')
% 
% 
% %%
% % cnv = conv(nvl,ones(1,7));
% % figure;
% % plot(nvl);
% % hold on
% % plot(cnv)
% % dcnv = deconv(cnv,ones(1,7));
% % % dcnv = ones(1,7)\cnv';
% % 
% % % dnvl = deconv(nvl,ones(1,2));
% % % dnvl = deconv(nvl,1+[1, 0.5, 0.25, 0, 0, 0, 0, 0]);
% % dnvl = deconv(nvl,[1, 0.5, 0.01, 0]);
% % figure;
% % plot(nvl,'b')
% % hold on
% % plot(dnvl,'k')
% 
% 
% % plot(date(1:length(dnvl)),dnvl/7,'k')
