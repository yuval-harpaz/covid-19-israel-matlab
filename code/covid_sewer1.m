function covid_sewer1

T = readtable('~/Downloads/Data.xlsx');
date = unique(T.Start_Week_Date);
town = unique(T.SE_Name);
NVL = strrep(T.NVL,'NULL','nan');
NVL = cellfun(@str2num, NVL);
nvl = nan(size(date));
for ii = 1:length(date)
    nvl(ii,1) = nanmean(NVL(T.Start_Week_Date == date(ii)));
    for jj = 1:length(town)
        row = find(T.Start_Week_Date == date(ii) & ismember(T.SE_Name,town{jj}));
        if length(row) == 1
            nvlt(ii,jj) = NVL(row);
        else
            nvlt(ii,jj) = nan;
        end
    end
end
nvlt(nvlt == 0) = nan;
figure;
plot(date,nvlt,'b');
hold on
plot(date,nvl,'k','linewidth',2)


active = readtable('~/Downloads/active1.csv','Delimiter',',');
% dateActive = datetime(cellfun(@(x) x(1:19),active.Date,'UniformOutput',false), 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss');
dateActive = datetime(cellfun(@(x) x(1:10),active.Date,'UniformOutput',false), 'InputFormat', 'yyyy-MM-dd');
dateActiveU = unique(dateActive);
activeU = nan(size(dateActiveU));
for ii = 1:length(activeU)
    activeU(ii) = max(active.active(dateActive == dateActiveU(ii)));
end
%%
figure;
plot(date+5,nvl/10,'r','linewidth',2)
hold on
plot(dateActiveU,activeU,'b','linewidth',2)
legend('Swere/8\ביוב','Active cases חולים פעילים')
grid on
set(gca,'YScale','log')


%%
cnv = conv(nvl,ones(1,7));
figure;
plot(nvl);
hold on
plot(cnv)
dcnv = deconv(cnv,ones(1,7));
% dcnv = ones(1,7)\cnv';

% dnvl = deconv(nvl,ones(1,2));
% dnvl = deconv(nvl,1+[1, 0.5, 0.25, 0, 0, 0, 0, 0]);
dnvl = deconv(nvl,[1, 0.5, 0.01, 0]);
figure;
plot(nvl,'b')
hold on
plot(dnvl,'k')

json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectedPerDate');
json = jsondecode(json);
json = struct2table(json);
dateCases = datetime(json.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
for ii = 1:length(date)
    d1 = find(dateCases == date(ii));
    cases(ii,1) = sum(json.amount(d1:min(d1+6,height(json))));
end

dnvl(dnvl < 0) = 0;
figure;
plot(date,nvl/10,'b')
hold on
plot(date,cases,'g')
plot(date(1:length(dnvl)),dnvl/7,'k')
