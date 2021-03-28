t = readtable('~/covid-19-israel-matlab/data/Israel/Israel MOH - Pfizer paper 25 Mar - adjusted VE.csv');

y = t{:,2:3:end};
CI1 = t{:,3:3:end};
CI2 = t{:,4:3:end};

% co = hsv(10);
col = [14 45 10;14,45,94;95 62 19;95 14 19;35 35 35]/100;
%%
figure;
ii = 1;
for ii = 1:5
    gap = ii/6-0.5;
    if ii == 1
        h(1) = errorbar(gap+(1:4),y(:,ii),CI1(:,ii)-y(:,ii),CI2(:,ii)-y(:,ii),'k','linestyle','none');
    end
    hold on
    h(ii+1) = bar(gap+(1:4),y(:,ii),0.15,'EdgeColor','none','FaceColor',col(ii,:));
    text(gap+(1:4)-0.075,y(:,ii)-5,num2str(y(:,ii)),'Color','w')
    errorbar(gap+(1:4),y(:,ii),CI1(:,ii)-y(:,ii),CI2(:,ii)-y(:,ii),'k','linestyle','none');
end
ylim([50 101])
set(gca,'YTick',50:5:100,'xtick',1:4,'XTickLabel',t{:,1},'ygrid','on','FontSize',13)
xlim([0.3 4.7])
ylabel('Vaccine Effectiveness')
title('VE by age and medical condition')
legend(h,'CI','Asymptomatic','Symptomatic','Hospitalization','Severe','Death','location','southwest')
grid minor
set(gcf,'Color','w')
