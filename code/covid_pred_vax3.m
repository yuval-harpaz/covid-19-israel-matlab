function tot = covid_pred_vax3
ignoreLast = 4; % ignore days when assessing linear trend
% vaxPerDay = IEdefault('vaxPerDay',90000);
% dayEffect = IEdefault('dayEffect',datetime(2021,1,15));
cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
prob = [0.0298531301548758,0.0321773598685654,0.0351186006639331,0.0362253767180710,0.0393270006302659,0.0427865042246371,0.0448144890903030,0.0470015315924917,0.0472003536381452,0.0476775265477137,0.0470810604107531,0.0455700128637864,0.0419912160420230,0.0392872362211352,0.0367820784459009,0.0337997477610981,0.0293858983475900,0.0265626252993100,0.0233019437505923,0.0220294826584098,0.0202400842475281,0.0182518637909930,0.0169794026988104,0.0149116534240139,0.0138777787866156,0.0130824906040015,0.0122076736031260,0.0108954481018128,0.00946392937310746,0.00843005473570917,0.00827099709918636,0.00735641568918017,0.00687924277961173,0.00612371900612836,0.00564654609655992,0.00548748846003710,0.00516937318699147,0.00477172909568444,0.00437408500437740,0.00401620532220107,0.00389691209480896,0.00357879682176333,0.00314138832132559,0.00282327304827996,0.00262445100262644,0.00258468659349574,0.00218704250218870,0.00167010518348955,0.00151104754696674,0.00151104754696674,0.00155081195609744,0.00135198991044392,0.00131222550131322,0.00139175431957463,0.00139175431957463,0.00135198991044392,0.00119293227392111,0.00107363904652900,0.00107363904652900,0.000874817000875480,0.000835052591744776,0.000914581410006183,0.000954345819136887,0.000994110228267591,0.000914581410006183,0.000874817000875480,0.000795288182614073,0.000755523773483369,0.000596466136960554,0.000596466136960554,0.000437408500437740,0.000437408500437740,0.000357879682176333,0.000437408500437740,0.000357879682176333,0.000397644091307036,0.000437408500437740,0.000477172909568444,0.000477172909568444,0.000477172909568444,0.000477172909568444,0.000516937318699147,0.000437408500437740,0.000318115273045629,0.000278350863914925,0.000357879682176333,0.000357879682176333,0.000357879682176333,0.000357879682176333,0.000357879682176333,0.000357879682176333,0.000357879682176333,0.000238586454784222,0.000198822045653518];

%%
daysProject = 30*6;

% x = movmean(tests.pos60,[3 3]);
x = movmean(listD.tests_positive,[3 3]);
xLin = [x(1:end-ignoreLast);x(end-ignoreLast)+...
    transpose(mean(diff(x(end-ignoreLast-6:end-ignoreLast))).*(1:daysProject))];
popOld = 1470000; %pop*ratioOld;
json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
json = jsondecode(json);
vacc = struct2table(json);
vacc.Day_Date = datetime(cellfun(@(x) x(1:10),vacc.Day_Date,'UniformOutput',false));
ratNotVax = ones(size(xLin));
ratNotVax((312:311+height(vacc))+14+4) = 1-vacc.vaccinated_cum./popOld;
% ratNotVax((277:276+height(vacc))) = 1-vacc.vaccinated_cum./popOld;
ratNotVax(ratNotVax < 0) = 0;
ratNotVax(find(ratNotVax == 0,1):end) = 0;
notVaxOld = 0.25;
ratNotVax = ratNotVax*(1-notVaxOld)+notVaxOld;

xLinF = xLin;
xLinF(cumsum(xLin) > popOld) = xLinF(cumsum(xLin) > popOld)*0.12;
predLin = conv(xLinF,prob)/120;

% add = 1;
predLin1 = predLin(1:end-length(prob)+1);
% dateLin = listD.date(1):listD.date(1)+length(predLin1)-1;


%% vaccines
% ratioOld = 0.157;
% pop = 9200000;


xLinVax = xLinF.*ratNotVax;
predVax = conv(xLinVax,prob);
dateVax = listD.date(1):listD.date(1)+length(predVax)-1;
% dateSeger = tests.date(1):tests.date(1)+length(predSeger)-1;
xLinVax(xLinVax == 0) = nan;
% xSegerVax = xSeger.*ratNotVax(1:length(xSeger));
% predSegerVax = conv(xSegerVax,prob);
% xSeger(xSeger == 0) = nan;
%% fig predicted
fig = figure('Units','normalized','Position',[0.25,0.25,0.4,0.7],'Name',datestr(datetime('today')));
set(fig, 'MenuBar', 'none', 'ToolBar', 'none');
subplot(2,1,1)

hx(1) = plot(listD.date(1):listD.date(1)+length(x)-1,x,'b');
hold on;
% hx(1) = plot(tests.date(1):tests.date(1)+length(xLin)-1,xLin,'r');
hx(2) = plot(listD.date(1):listD.date(1)+length(xLinVax)-1,xLinVax,'g');
% hx(3) = plot(tests.date(1)+iStart-1:tests.date(1)+length(xSeger)-1,xSeger(iStart:end),'r');
% hx(4) = plot(tests.date(1)+iStart-1:tests.date(1)+length(xSegerVax)-1,xSegerVax(iStart:end),'k--');
grid on
ylabel('מאומתים מעל 60')
legend(hx,'מאומתים','מנבא לפי מאומתים לא מחוסנים')
title('המנבא')
box off
set(gca,'XTick',datetime(2020,3:16,1),'fontsize',12,'ygrid','on')
xtickangle(45)
% xlim([datetime(2020,3,15) datetime(2021,4,1)]);
xlim([datetime(2020,6,15) datetime(2021,4,1)]);
% ylim([0 750])
xtickformat('MMM')
subplot(2,1,2)
scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor','b','MarkerEdgeAlpha',0.5);
hold on;
hb2(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
hb2(2) = plot(dateVax,predVax/120,'g');
% hb2(3) = plot(dateSeger(iStart:end),predSeger(iStart:end)./10+add,'r');
% hb2(4) = plot(dateSeger(iStart:end),predSegerVax(iStart:end)./10+add,'k--');
legend(hb2,'תמותה','ניבוי תמותה')
grid on
xlim([datetime(2020,6,15) datetime(2021,4,1)]);
title('הניבוי')
ylabel('נפטרים')
set(gcf,'Color','w')
% xlim([listD.date(1) datetime(2021,4,1)])
set(gca,'XTick',datetime(2020,3:16,1),'fontsize',12,'ygrid','on')
xtickangle(45)
xtickformat('MMM')
% tot = round(sum(predVax(dateVax > datetime('today') & dateVax <= datetime(2021,4,1))/10+add));
% tot(1,2) = round(sum(predSeger(dateSeger > datetime('today') & dateSeger <= datetime(2021,4,1))/10+add));
% tot(1,3) = round(sum(predSegerVax(dateSeger > datetime('today') & dateSeger <= datetime(2021,4,1))/10+add));
% 

%% fig predictor


