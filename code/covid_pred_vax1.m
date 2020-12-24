function tot = covid_pred_vax1(vaxPerDay,dayEffect)
ignoreLast = 3; % ignore days when assessing linear trend
vaxPerDay = IEdefault('vaxPerDay',90000);
dayEffect = IEdefault('dayEffect',datetime(2021,1,15));

cd ~/covid-19-israel-matlab/data/Israel
tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
newc = readtable('new_critical.csv');
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = jsondecode(json);
death = json.result.records;
death = struct2table(death);
pos2death = cellfun(@str2num,strrep(death.Time_between_positive_and_death,'NULL','0'));
bad = pos2death < 1 | ismember(death.gender,'לא ידוע');
isMale = ismember(death.gender(~bad),'זכר');
pos2death = pos2death(~bad);
% old = ~ismember(death.age_group,'<65');
prob = movmean(hist(pos2death,1:1000),[3 3]);
iEnd = find(prob < 0.5,1);
prob = prob(1:iEnd-1);
prob = prob/sum(prob);

%%
daysProject = 30*6;

x = movmean(tests.pos60,[3 3]);
predBest =  conv(x,prob);
xLin = [x(1:end-ignoreLast);x(end-ignoreLast)+...
    transpose(mean(diff(x(end-ignoreLast-6:end-ignoreLast))).*(1:daysProject))];
clear hx

predLin = conv(xLin,prob);
iStart = find(predLin(1:length(predBest) )> predBest,1);
add = 1;

%%
predLin1 = predLin(1:end-length(prob)+1);
dateLin = tests.date(1):tests.date(1)+length(predLin1)-1;
fig = figure('Units','normalized','Position',[0.25,0.25,0.4,0.5]);
scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor','b','MarkerEdgeAlpha',0.5);
hold on;
hb1(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
hb1(2) = plot(dateLin,predLin1/10+add,'r');
legend(hb1,'תמותה','ניבוי לפי מאומתים')
grid on
xlim([datetime(2020,6,15) tests.date(end)+33]);
title('ניבוי תמותה לפי מאומתים מגיל 60 (בדיקה ראשונה)')
ylabel('נפטרים')
set(gcf,'Color','w')

%% vaccines
ratioOld = 0.157;
pop = 9200000;
popOld = pop*ratioOld;
iDayEffect = find(dateLin == dayEffect);  % first day with vaccine effect
ratNotVax = ones(size(xLin));
for ii = iDayEffect:length(ratNotVax)
    ratNotVax(ii) = ratNotVax(ii-1)-vaxPerDay/popOld;
end
ratNotVax(ratNotVax < 0) = 0;
xLinVax = xLin.*ratNotVax;

predVax = conv(xLinVax,prob);
dateVax = tests.date(1):tests.date(1)+length(predVax)-1;
%% fig predicted
fig = figure('Units','normalized','Position',[0.25,0.25,0.4,0.7]);
subplot(2,1,1)
hx(3) = plot(tests.date(1):tests.date(1)+length(xLinVax)-1,xLinVax,'g');
hold on;
hx(1) = plot(tests.date(1):tests.date(1)+length(xLin)-1,xLin,'r');
hx(2) = plot(tests.date(1):tests.date(1)+length(x)-1,x,'k');
grid on
ylabel('מאומתים מעל 60')
legend(hx([1,3,2]),'מנבא תמותה לפי קצב העליה הנוכחי','מנבא תמותה הכולל חיסון מבוגרים','הנדבקים עד היום','location','northwest')
title('מנבא תמותה הכולל 60,000 מחוסנים מבוגרים ליום מתחילת ינואר')
box off
set(gca,'XTick',datetime(2020,3:16,1),'fontsize',12,'ygrid','on')
xtickangle(45)
xlim([datetime(2020,3,15) datetime(2021,4,1)]);
ylim([0 750])
subplot(2,1,2)
scatter(listD.date,listD.CountDeath,'.','MarkerEdgeColor','b','MarkerEdgeAlpha',0.5);
hold on;
hb2(1) = plot(listD.date(1:end-1),movmean(listD.CountDeath(1:end-1),[3 3]),'b','linewidth',2);
hb2(2) = plot(dateVax,predVax/10+add,'g');
legend(hb2,'תמותה','ניבוי תמותה הכולל חיסונים','location','northwest')
grid on
xlim([datetime(2020,6,15) tests.date(end)+33]);
title('הניבוי')
ylabel('נפטרים')
set(gcf,'Color','w')
xlim([listD.date(1) datetime(2021,4,1)])
set(gca,'XTick',datetime(2020,3:16,1),'fontsize',12,'ygrid','on')
xtickangle(45)
tot = round(sum(predVax(dateVax > datetime('today'))/10+add));

%% fig predictor


