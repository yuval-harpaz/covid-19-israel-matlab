function covid_exp_fit
cd ~/covid-19-israel-matlab
listName = '~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv';
list = readtable(listName);
% list.Properties.VariableNames(1+[7,9:12]) = {'hospitalized','critical','severe','mild','on_ventilator'};
list.deceased = nan(height(list),1);
list.deceased =list.CountDeath;
i1 = find(~isnan(list.CountHospitalized),1);
list = list(i1:end,:);
fid = fopen('data/Israel/dashboard.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
listE = list;
list = listE(1:end-1,:);
ccc = [0,0.4470,0.7410;0.8500,0.3250,0.09800;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.07800,0.1840];
% severe = movmean((1:end),[3 3]);

% hh(9) = scatter(list.date(list.CountDeath > 0),list.CountDeath(list.CountDeath > 0),'k.','MarkerEdgeAlpha',alf);
yy = [list.tests_positive1, list.new_hospitalized, list.serious_critical_new];
yy(2:end,4) = diff(list.CountBreathCum);
yy(:,5) = list.CountDeath;
% yy = yy(1:end-1,:);
last3 = yy(end-2:end,:);
yy = movmean(yy,[3 3]);
% yy(end-2:end,:) = nan;
%%
linEst = 669:675;
coef = yy(linEst(1)+1:linEst(end),:)./yy(linEst(1):linEst(end-1),:);
coef = median(coef);
sevShift = 3;
coef(3) = median(yy(linEst(1)+1+sevShift:linEst(end)+sevShift,3)./yy(linEst(1)+sevShift:linEst(end-1)+sevShift,3));
coef(3) = coef(3)*0.98;
finEst = days(datetime('today')-list.date(linEst(1))+14);
dateEst = list.date(linEst(1)):list.date(linEst(1))+finEst;
proj = nan(length(dateEst),5);
for pr = 1:5
    proj(:,pr) = yy(linEst(1),pr)*coef(pr).^(0:length(dateEst)-1);
end
figure('units','normalized','position',[0,0,1,1]);
hh = plot(list.date(1:end-3), yy(1:end-3,:), 'linewidth', 1.5);
hh(1).Color = [0.3 0.7 0.3];
hh(2).Color = ccc(4,:);
hh(3).Color = ccc(3,:);
hh(4).Color = ccc(1,:);
hh(5).Color = [0 0 0];
hold on
% hhe = plot(list.date(linEst), yy(linEst,:), 'linewidth', 2.5);
% hhe(1).Color = [0.3 0.7 0.3];
% hhe(2).Color = ccc(4,:);
% hhe(3).Color = ccc(3,:);
% hhe(4).Color = ccc(1,:);
% hhe(5).Color = [0 0 0];
hhd = plot(list.date(end-2:end), last3,'.','markersize',8);
hhd(1).Color = [0.3 0.7 0.3];
hhd(2).Color = ccc(4,:);
hhd(3).Color = ccc(3,:);
hhd(4).Color = ccc(1,:);
hhd(5).Color = [0 0 0];
bias = [0,0,-1];
for pr = 1:3
    line(dateEst,proj(:,pr),'Color','k','linestyle',':')
end
title('New cases / patients')
legend('cases     מאומתים','hospitalized מאושפזים','severe                קשה',...
    'on vent          מונשמים','deceased        נפטרים','location','northwest')
grid on
box off
set(gcf,'Color','w')
grid minor
set(gca,'fontsize',13,'XTick',datetime(2020,3:50,1))
xlim([list.date(1) datetime('tomorrow')+14])
xtickformat('MMM')
set(gca, 'YScale', 'log')
ylim([2 100000])

date = dateEst';
cases = proj(:,1);
hosp = proj(:,2);
severe = proj(:,3);
tt = table(date,cases,hosp,severe);
tt{:,2:end} = round(tt{:,2:end});
writetable(tt,'~/Documents/proj.csv')
disp((coef(1:3)').^(1:7))

confOmi = [list.tests_positive1(640:669);proj(1:end,1)];
cs = cumsum(confOmi);
cs = cs(cs < 9500000);
ds = datetime(2021,12,1:100);
ds = ds(1:length(cs));
figure;
plot(ds,cs);
% set(gca, 'YScale', 'log')
for ii = 1:9
    xt(ii) = find(cs > 9500000/10*ii,1);
end
set(gca,'XTick',ds(xt(1:7)))
xtickformat('dd/MM')
xlim([datetime('today') ds(end)])
grid on
xtickangle(45)
title('percents of infected population without slow-down')
