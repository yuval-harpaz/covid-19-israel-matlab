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
%%
figure;
h1 = bar(tt.date,tt{:,9:end},'stacked','EdgeColor','none');
% h1 = bar(tt.date,[tt{:,9:end},listD.CountDeath(70:end)],'stacked','EdgeColor','none');
%%
figure;
yyaxis left
h2 = bar(tt.date,tt{:,9:end},'stacked','EdgeColor','none');
for ii = 1:4
    h2(ii).FaceColor = h1(ii).FaceColor;
end
ylabel('Load')
hold on
h2a = bar(tt.date,-listD.CountDeath(70:end),'stacked','FaceColor','k');

yyaxis right

h3 = plot(tt.date,tt.cases,'k');
ylabel('Cases')

set(gca,'xtick',datetime(2020,4:30,1),'ygrid','on','FontSize',13)
box off
grid on

death = listD.CountDeathCum(70:end);
for ii = 1:6
    kk(ii) = find(death > 1000*ii,1);
end
hold on
h4 = bar(tt.date(kk),repmat(1000,6,1),0.1,'FaceColor',[0.35 0.35 0.35],'EdgeColor','none');
ylim([-1000 9000])
% legend([h4,h3,h2],{'1k deaths','cases','mild (1)','medium+severe (2)','vent (3)','ECMO (5)'}) 
legend([fliplr(h2),h2a,h4,h3],'ECMO (5)','vent (3)','medium+severe (2)','mild (1)','deaths','1k deaths','cases') 
set(gcf,'Color','w')
