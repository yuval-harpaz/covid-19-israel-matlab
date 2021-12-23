function covid_local(mult)


cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
% listD = readtable('dashboard_timeseries.csv');
% abroad = readtable('infected_abroad.csv');
% listD = listD(find(ismember(listD.date,abroad.date),1):end,:);
% extra = height(listD)-height(abroad);
% if extra > 0
%     row = height(abroad)+1:height(abroad)+extra;
%     abroad.date(end+1:end+extra) = listD.date(row);
% end
% abroad.tests = listD.tests;
% abroad.positive = listD.tests_positive;
% if sum(abroad{end,4:5}) == 0
%     abroad(end,:) = [];
% end

options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/positiveArrivingAboardDaily';
paad = webread(url, options);
paad = struct2table(paad);
paad = paad(ismember(paad.visited_country,'כלל המדינות'),:);
abroad = sum(paad{:,3:4},2);
date = datetime(paad.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

url = 'https://datadashboardapi.health.gov.il/api/queries/testResultsPerDate';
tCases = webread(url, options);
tCases = struct2table(tCases);
dateCases = datetime(tCases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
keep = ismember(dateCases,date);
cases = tCases.positiveAmount(keep);
local = cases-abroad;
local(local < 0) = 0;
%%
% figure;
% bar(date,[local,abroad],'stacked')
% text(date-0.5,(local+abroad)+30,str(abroad))
% 
% %%
% Rlocal = covid_R31(local);
% Rlocal(end-3:end) = nan;
% R = covid_R31(cases);
% R(end-3:end) = nan;
% figure;
% plot(date-6,[R,Rlocal])

%%

dateR = datetime(2021,11,17+7*4):7:datetime('today')+20;
lin1 = find(date == dateR(1));
if ~exist('mult','var')
    mult = 1.415^(1/0.65);
elseif isempty(mult)
    mul = nan(length(dateR),1);
    for id = 1:length(dateR)
        i0 = lin1+7*(id-4);
        mul(id) = mean(local(i0-3:i0+3))/mean(local(i0-7-3:i0-7+3));
    end
    mult = mean(mul(end-3:end));
end
yy = local(lin1-1:end);
xx = 1:length(yy)+14;
% fac = yy(1:23)\xx(1:23)';
rr = round(mean(local(lin1-3:lin1+3)));
% mult = 1.425^(1/0.65);

for idr = 2:length(dateR)
    rr(idr,1) = rr(idr-1)*mult;
end

% ww = [1/3,0.6,1,1,1,1,1];
ww =  [0.8,1.2,1,1,1,1,0.6];
ww = ww./mean(ww);
pred = [];
for idr = 1:length(rr)
    pred = [pred,rr(idr)*((mult^(1/7)).^(-3:3)).*ww];
end
pred = round(pred);
dateRd = dateR(1)-3;
dateRd = dateRd:dateRd+length(pred)-1;
%%
figure;
bar(dateRd,pred,1,'FaceColor',[1 1 1])
hold on
bar(date,local,'FaceColor',[0.2 0.65 0.2],'EdgeColor','none','FaceAlpha',0.75)
sm = movmean(local,[3 3]);
plot(date(1:end-3),sm(1:end-3),'r','LineWidth',3)
plot(dateR,rr,'b','LineWidth',2)
set(gca,'XTick',datetime(2021,11,17)-7*100:7:datetime('today')+20)
xtickformat('dd/MM')
grid on
box off
legend('prediction','cases (local)','cases, 7 days average (-3 to +3)',['weekly multiplication factor = ',str(round(mult,3))],'location','northwest')
title('Cases vs exponential growth')
ylabel('Cases')
set(gcf,'Color','w')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0g';
% text(datetime('today'),local(end),str(local(end)),'Color',[0.2 0.65 0.2])
% sh=lin1;
% text(datetime('tomorrow')-5,pred(length(abroad)-sh),str(pred(length(abroad)-sh)))
xlim([dateR(1)-7*4 datetime('today')+20.48])
