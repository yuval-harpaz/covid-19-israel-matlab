% for ii = 1:length(onset);
%     jjj = onset(ii):offset(find(offset > onset(ii),1));
%     ec(jjj) = linspace(ec(jjj(1)-1),ec(jjj(end)+1),length(jjj));
% end
% 
% col = colormap(jet(4));
% col = flipud(col);
% col(col == 1) = 0.8;
cd /home/innereye/covid-19-israel-matlab/data/Israel
sync = find(ismember(listD.date,tt.date(1)));
listD = readtable('dashboard_timeseries.csv');
tt = readtable('Load.csv');
tt.mild(1:+height(listD)-sync+1) = listD.CountEasyStatus(sync:end);
tt.medium(1:+height(listD)-sync+1) = listD.CountMediumStatus(sync:end);
tt.severe(1:+height(listD)-sync+1) = listD.CountHardStatus(sync:end);
tt.vent(1:+height(listD)-sync+1) = listD.CountBreath(sync:end);
tt.date(1:+height(listD)-sync+1) = listD.date(sync:end);
tt.ECMO(1:+height(listD)-sync+1) = listD.count_ecmo(sync:end);
% %% fill ecmo data
% if tt.ECMO(end) == 0
%     count = find(tt.ECMO > 0,1,'last');
%     feed = true;
%     while feed
%         count = count + 1;
%         if count > height(tt)
%             feed = false;
%         else
%             ip = input(['last date is ',datestr(tt.date(count)),'. new ecmo data? no / number : '],'s');
%             if strcmp(ip(1),'n')
%                 feed = false;
%             else
%                 tt.ECMO(count) = str2num(ip);
%                 tt.ECMO_filled(count) = tt.ECMO(count);
%                 
%             end
%         end
%     end
% end
%%
% if tt.ECMO(end) == 0
%     tt = tt(1:find(tt.ECMO > 0,1,'last'),:);
% end
tt.level1 = tt.mild+tt.medium;
no_mechanical = tt.severe-tt.vent-tt.ECMO;
tt.level2 =  no_mechanical*1*0.75 + no_mechanical*2*0.25; % no support + oxygen support
tt.level3 = tt.vent*3;  % (tt.vent-tt.ECMO_filled)*3;
tt.level6 = round(tt.ECMO)*6;
tt.load = tt.level1+tt.level2+tt.level3+tt.level6;

writetable(tt,'Load.csv','Delimiter',',','WriteVariableNames',true)

% date = date';
load = [424,441,500,549,581,646,681,716,717,822,884,964,1044,1108,1183,1220,1308,1426,...
    1463,1481,1509,1562,1547,1700,1791,1814,1799,1791,1819,1794]';
date = datetime(2021,7,29)+(0:length(load)-1);
conf = readtable('confirmed.csv');
% dateSeger = [datetime(202
dateSeger = conf.date(ismember(conf.coronaEvents,{'סגר שני','סגר שלישי'}));
%%
yy = [tt.level1,tt.level2,tt.level3,tt.level6,tt.load];

figure;
hh = plot(tt.date(1:end-1),yy(1:end-1,:));
xlim([tt.date(1),datetime('tomorrow')])
grid on
title('Load on health system measure   מדד עומס על מערכת הבריאות')
set(gcf,'Color','w')
hold on
plot(date,load,'.k','MarkerSize',20)
idx = ismember(tt.date,dateSeger);
plot(tt.date(idx),tt.load(idx),'*b','MarkerSize',5)
legend('Mild+Medium    קל+בינוני','Severe    קשה','Vent     מונשים','ECMO    אקמו',...
    'Load       עומס','official load value    מדד העומס הרשמי','lockdown  סגר')
set(gca,'FontSize',13)