t = readtable('Downloads/Israel MOH - Pfizer paper 25 Mar - adjusted VE.csv');
t{1,end} = {'(100–100)'};
y = t{:,4:2:12};
CI1 = cellfun(@(x) str2num(x(2:findstr(x,'–')-1)), t{:,5:2:13});
CI2 = cellfun(@(x) str2num(x(findstr(x,'–')+1:end-1)), t{:,5:2:13});

% co = hsv(10);
col = [14 45 10;14,45,94;95 62 19;95 14 19;0,0,0]/100;
figure;
for ii = 1:5
    gap = ii/6-0.5;
    h(ii) = bar(gap+(1:4),y(:,ii),0.15,'EdgeColor','none','FaceColor',col(ii,:));
    hold on
    h(6) = errorbar(gap+(1:4),y(:,ii),CI1(:,1)-y(:,ii),CI2(:,ii)-y(:,ii),'k','linestyle','none');
end

ylim([50 101])
set(gca,'YTick',50:5:100,'xtick',1:4,'XTickLabel',t{:,1},'ygrid','on','FontSize',13)
xlim([0.3 4.7])
ylabel('Vaccine Effectiveness')
title('VE by age and medical condition')
legend(h,'Asymptomatic','Symptomatic','Hospitalization','Severe','Death','CI')
grid minor
set(gcf,'Color','w')