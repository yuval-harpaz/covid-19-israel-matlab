
yyy = [76797,21773,1842;25763,7514,459;2427,1066,152;1314,709,93;206,193,24];
Mild = (yyy(3,:)-yyy(4,:))';
Severe = (yyy(4,:)-yyy(5,:))';
Deceased = yyy(5,:)';
time = {'No vaccine';'Dose I';'Dose II 7+'};
t = table(time,Mild,Severe,Deceased);
% t = readtable('~/covid-19-israel-matlab/data/Israel/11 Feb 2021.csv');
y = t{:,2:4};
y = y./sum(sum(y,2))*100;
% r = t{4,8}-nansum(t{4,2:7});
% y(4,[2,4]) = r*[2/3,1/3];
% y = y./t{:,7}*100;
col = [0,0.447,0.741;0.850,0.325,0.0980;0.929,0.694,0.125;0.494,0.184,0.556;0.466,0.674,0.188;0.301,0.745,0.933;0.635,0.0780,0.184];
figure;
h = bar(y,'stacked','EdgeColor','none');
for ii = 1:length(h)
    col(ii,1:3) = h(ii).FaceColor;
end
h(1).FaceColor = col(5,:);
h(2).FaceColor = col(2,:);
h(3).FaceColor = [0,0,0];

legend(fliplr(h),fliplr({'Mild','Severe','Deceased'}))
set(gca,'XTickLabel',t.time)
text([1,1,1]-0.15,cumsum(y(1,:))-3,num2str(t{1,2:end}'),'Color','w')
text([2,2,2]-0.15,cumsum(y(2,:))-3,num2str(t{2,2:end}'),'Color','w')
ylabel('hospitalized (% of all patients)')
box off
title('Ratio of hospitalized by group, age 15+')
ylim([0 80])
set(gca,'FontSize',13,'ygrid','on')
% xtickangle(15)
set(gcf,'Color','w')

%%
yyp = [3927222,777529,1775761;76797,21773,1842;25763,7514,459;2427,1066,152;1314,709,93;206,193,24];
yyn = [yyp(1,:);yyp(2:end,:)./yyp(1,:)*10^6];
tit = {'Population','cases','symptoms','hospitalizations','severe','deaths'};
figure;
subplot(2,3,1)
for ii = 1:6
    subplot(2,3,ii)
    h = bar(yyn(ii,:));
    title(tit{ii})
    ax = gca;
    ax.YRuler.Exponent = 0;
    set(gca,'XTickLabel',t.time,'ygrid','on')
    xtickangle(15)
end
set(gcf,'Color','w')
    