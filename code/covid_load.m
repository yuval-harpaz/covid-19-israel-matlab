% for ii = 1:length(onset);
%     jjj = onset(ii):offset(find(offset > onset(ii),1));
%     ec(jjj) = linspace(ec(jjj(1)-1),ec(jjj(end)+1),length(jjj));
% end
% 
% col = colormap(jet(4));
% col = flipud(col);
% col(col == 1) = 0.8;
cd /home/innereye/covid-19-israel-matlab/data/Israel
listD = readtable('dashboard_timeseries.csv');
tt = readtable('Load.csv');
tt.mild(1:+height(listD)-69) = listD.CountEasyStatus(70:end);
tt.medium(1:+height(listD)-69) = listD.CountMediumStatus(70:end);
tt.severe(1:+height(listD)-69) = listD.CountHardStatus(70:end);
tt.vent(1:+height(listD)-69) = listD.CountBreath(70:end);
tt.date(1:+height(listD)-69) = listD.date(70:end);
%% fill ecmo data
if tt.ECMO(end) == 0
    count = find(tt.ECMO > 0,1,'last');
    feed = true;
    while feed
        count = count + 1;
        if count > height(tt)
            feed = false;
        else
            ip = input(['last date is ',datestr(tt.date(count)),'. new ecmo data? no / number : '],'s');
            if strcmp(ip(1),'n')
                feed = false;
            else
                tt.ECMO(count) = str2num(ip);
                tt.ECMO_filled(count) = tt.ECMO(count);
                
            end
        end
    end
end
%%
if tt.ECMO(end) == 0
    tt = tt(1:find(tt.ECMO > 0,1,'last'),:);
end
tt.level1 = tt.mild+tt.medium;
no_mechanical = tt.severe-tt.vent-tt.ECMO_filled;
tt.level2 =  no_mechanical*1.5*0.75 + no_mechanical*2*0.25; % no support + oxygen support
tt.level3 = tt.vent*3;  % (tt.vent-tt.ECMO_filled)*3;
tt.level6 = round(tt.ECMO_filled)*6;
tt.load = tt.level1+tt.level2+tt.level3+tt.level6;

writetable(tt,'Load.csv','Delimiter',',','WriteVariableNames',true)

% date = date';
load = [424,441,500,549,581,646,681,716,717,822,884,964,1030]';
date = datetime(2021,7,29)+(0:length(load)-1);
conf = readtable('confirmed.csv');
dateSeger = conf.date(ismember(conf.coronaEvents,{'סגר 3','סגר 2','סגר 1 '}));
%%
figure;
hh = plot(tt.date,[tt.level1,tt.level2,tt.level3,tt.level6,tt.load]);

xlim([tt.date(1),datetime('tomorrow')])
grid on
title('Load on health system measure   מדד עומס על מערכת הבריאות')
set(gcf,'Color','w')
hold on
plot(date,load,'.k','MarkerSize',20)
idx = ismember(tt.date,dateSeger(2:end));
plot(tt.date(idx),tt.load(idx),'*b','MarkerSize',5)
legend('Mild+Medium    קל+בינוני','Severe    קשה','Vent     מונשים','ECMO    אקמו',...
    'Load       עומס','official load value    מדד העומס הרשמי','lockdown  סגר')
set(gca,'FontSize',13)