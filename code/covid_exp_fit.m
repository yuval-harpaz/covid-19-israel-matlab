function covid_exp_fit

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
yy = yy(1:end-1,:);
yy = movmean(yy,[3 3]);
yy(end-2:end,:) = nan;
coef = yy(650:675,:)./yy(650-1:675-1,:);
coef = median(coef(24-6:24,:));
% proj = 
figure('units','normalized','position',[0,0,1,1]);
hh = plot(list.date(1:end-1), yy, 'linewidth', 1.5);
hh(1).Color = [0.3 0.7 0.3];
hh(2).Color = ccc(4,:);
hh(3).Color = ccc(3,:);
hh(4).Color = ccc(1,:);
hh(5).Color = [0 0 0];
title('New cases / patients')
legend('cases     מאומתים','hospitalized מאושפזים','severe                קשה',...
    'on vent          מונשמים','deceased        נפטרים','location','northwest')
grid on
box off
set(gcf,'Color','w')
grid minor
set(gca,'fontsize',13,'XTick',datetime(2020,3:50,1))
xlim([list.date(1) datetime('tomorrow')])
xtickformat('MMM')
set(gca, 'YScale', 'log')
ylim([2 100000])
