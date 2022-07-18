function covid_sewer2

T = readtable('~/Downloads/WateWater_Data.xlsx');
date = unique(T.Start_Week_Date);
town = unique(T.SE_Name);
NVL = T.NVL;
% NVL = strrep(T.NVL,'NULL','nan');
% NVL = cellfun(@str2num, NVL);
nvl = nan(size(date));
nvln = nan(size(date));
for ii = 1:length(date)
    rows = T.Start_Week_Date == date(ii);
    nvl(ii,1) = nanmean(NVL(rows));
    pop = T.Population_For_Normalization(rows);
    nvln(ii,1) = nansum(NVL(rows).*pop)/sum(pop);
    for jj = 1:length(town)
        row = find(T.Start_Week_Date == date(ii) & ismember(T.SE_Name,town{jj}));
        if length(row) == 1
            nvlt(ii,jj) = NVL(row);
        else
            nvlt(ii,jj) = nan;
        end
    end
end
% nvlt(nvlt == 0) = nan;
figure;
plot(date,nvlt,'b');
hold on
plot(date,nvl,'k','linewidth',2)
plot(date,nvln,'g','linewidth',2)
plot(date,nvlm,'m','linewidth',2)




json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectedPerDate');
json = jsondecode(json);
json = struct2table(json);
dateCases = datetime(json.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
for ii = 1:length(date)
    d1 = find(dateCases == date(ii));
    cases(ii,1) = sum(json.amount(d1:min(d1+6,height(json))));
end


figure;
plot(date,nvln/10,'b')
hold on
plot(date,cases,'g')

figure;
bar(date,nvln,0.75, 'EdgeColor','none')
set(gca,'YScale','log')
ylim([70000 10^7])
grid on
box off
title('COVID-19 in Waste water ')
ylabel('NVL')
set(gcf,'Color','w')
set(gca,'XTick',date,'layer','top')
xtickangle(90)
xtickformat('dd.MM.yy')
xlabel('Start week date')
% 
% active = readtable('~/Downloads/active1.csv','Delimiter',',');
% % dateActive = datetime(cellfun(@(x) x(1:19),active.Date,'UniformOutput',false), 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss');
% dateActive = datetime(cellfun(@(x) x(1:10),active.Date,'UniformOutput',false), 'InputFormat', 'yyyy-MM-dd');
% dateActiveU = unique(dateActive);
% activeU = nan(size(dateActiveU));
% for ii = 1:length(activeU)
%     activeU(ii) = max(active.active(dateActive == dateActiveU(ii)));
% end
% %%
% figure;
% plot(date+5,nvl/10,'r','linewidth',2)
% hold on
% plot(dateActiveU,activeU,'b','linewidth',2)
% legend('Swere/8\ביוב','Active cases חולים פעילים')
% grid on
% set(gca,'YScale','log')


%%
% cnv = conv(nvl,ones(1,7));
% figure;
% plot(nvl);
% hold on
% plot(cnv)
% dcnv = deconv(cnv,ones(1,7));
% % dcnv = ones(1,7)\cnv';
% 
% % dnvl = deconv(nvl,ones(1,2));
% % dnvl = deconv(nvl,1+[1, 0.5, 0.25, 0, 0, 0, 0, 0]);
% dnvl = deconv(nvl,[1, 0.5, 0.01, 0]);
% figure;
% plot(nvl,'b')
% hold on
% plot(dnvl,'k')


% plot(date(1:length(dnvl)),dnvl/7,'k')
