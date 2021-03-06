yy = [0.46,0.92;0.40,0.88;0.51,0.95;0.57,0.94;0.50,0.87;0.63,0.98;0.74,0.87;0.56,0.55;0.86,1;0.62,0.92;0.39,0.75;0.80,1;0.72,0;0.19,0;1,0];
y = yy(1:3:end,:);
y(end) = nan;

dd = 0.2;

figure;
bar((1:5)-0.2,y(:,1),0.3,'EdgeColor','none')
hold on
bar((1:5)+0.2,y(:,2),0.3,'EdgeColor','none')
xlim([0.5 5.5])
errorbar((1:5)-0.2,y(:,1),y(:,1)-yy(2:3:end,1),y(:,1)-yy(3:3:end,1),'k',...
    'linestyle','none','linewidth',1)
errorbar((1:5)+0.2,y(:,2),y(:,2)-yy(2:3:end,2),y(:,2)-yy(3:3:end,2),'k',...
    'linestyle','none','linewidth',1)
grid on
grid minor
box off
set(gcf,'Color','w')
title('Vaccine Effectiveness')
legend('14 to 20 days from dose I','7 days or more from dose II')
set(gca,'xtick',1:5,'xticklabel',{'infections','symptoms','hospitalization','severe','deaths'},...
    'ytick',0:0.1:1,'yticklabel',0:10:100)
xtickangle(5)