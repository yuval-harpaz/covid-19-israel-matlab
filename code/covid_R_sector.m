
cd ~/Downloads/
load 'CasesBySector (1).mat'
pow = 0.65;
shift = 0;
days = 7;
Rl = movmean(cases_by_sector{:,2:4},[6 0]);
Rl = Rl(days+1:end,:)./Rl(1:end-days,:);
figure;
hh = plot(cases_by_sector.t(1)-shift:cases_by_sector.t(end)-days-shift,Rl.^pow,'LineWidth',1.5);
legend(cases_by_sector.Properties.VariableNames(2:4))
grid on
xlim([cases_by_sector.t(1)-3 datetime('today')+2])
title('R by sector')
set(gca,'FontSize',13)
set(gcf,'Color','w')
grid minor