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
tt.level1 = tt.mild;
tt.level2 = (tt.medium+tt.severe-tt.vent)*2;
tt.level3 = (tt.vent-tt.ECMO_filled)*3;
tt.level5 = round(tt.ECMO_filled)*5;
tt.load = tt.level1+tt.level2+tt.level3+tt.level5;

writetable(tt,'Load.csv','Delimiter',',','WriteVariableNames',true)
%%
figure;
hh = plot(tt.date,[tt.level1,tt.level2,tt.level3,tt.level5,tt.load]);
legend('Mild','Medium + Severe','Vent','ECMO','Load')
xlim([tt.date(1),datetime('today')])
grid on
title('Load on health system measure   מדד עומס על מערכת הבריאות')
set(gcf,'Color','w')
% figure;
% h1 = bar(tt.date,tt{:,9:end},'stacked','EdgeColor','none');
% % h1 = bar(tt.date,[tt{:,9:end},listD.CountDeath(70:end)],'stacked','EdgeColor','none');
% %%
% figure;
% yyaxis left
% h2 = bar(tt.date,tt{:,9:end},'stacked','EdgeColor','none');
% for ii = 1:4
%     h2(ii).FaceColor = h1(ii).FaceColor;
% end
% ylabel('Load')
% hold on
% h2a = bar(tt.date,-listD.CountDeath(70:end),'stacked','FaceColor','k');
% 
% yyaxis right
% 
% h3 = plot(tt.date,tt.cases,'k');
% ylabel('Cases')
% 
% set(gca,'xtick',datetime(2020,4:30,1),'ygrid','on','FontSize',13)
% box off
% grid on
% 
% death = listD.CountDeathCum(70:end);
% for ii = 1:6
%     kk(ii) = find(death > 1000*ii,1);
% end
% hold on
% h4 = bar(tt.date(kk),repmat(1000,6,1),0.1,'FaceColor',[0.35 0.35 0.35],'EdgeColor','none');
% ylim([-1000 9000])
% % legend([h4,h3,h2],{'1k deaths','cases','mild (1)','medium+severe (2)','vent (3)','ECMO (5)'}) 
% legend([fliplr(h2),h2a,h4,h3],'ECMO (5)','vent (3)','medium+severe (2)','mild (1)','deaths','1k deaths','cases') 
% set(gcf,'Color','w')
% 
% %%
% figure;
% yyaxis left
% h2 = bar(tt.date,tt{:,9:end},1,'stacked','EdgeColor','none');
% for ii = 1:4
%     h2(ii).FaceColor = h1(ii).FaceColor;
% end
% ylabel('Load')
% hold on
% h2a = bar(tt.date,listD.CountDeath(70:end),1,'stacked','FaceColor','k');
% set(gca, 'YScale', 'log')
% yyaxis right
% 
% h3 = plot(tt.date,tt.cases,'k');
% ylabel('Cases')
% 
% set(gca,'xtick',datetime(2020,4:30,1),'ygrid','on','FontSize',13)
% box off
% grid on
% 
% death = listD.CountDeathCum(70:end);
% for ii = 1:6
%     kk(ii) = find(death > 1000*ii,1);
% end
% hold on
% h4 = bar(tt.date(kk),repmat(1000,6,1),0.1,'FaceColor',[0.35 0.35 0.35],'EdgeColor','none');
% % ylim([-1000 9000])
% % legend([h4,h3,h2],{'1k deaths','cases','mild (1)','medium+severe (2)','vent (3)','ECMO (5)'}) 
% legend([fliplr(h2),h2a,h4,h3],'ECMO (5)','vent (3)','medium+severe (2)','mild (1)','deaths','1k deaths','cases') 
% set(gcf,'Color','w')
% 
% set(gca, 'YScale', 'log')