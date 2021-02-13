% time = {'Dose I +13';'Dose I 14+';'Dose II +6';'Dose II 7-14';'Dose II 14+'};
% community60 = [10724;;991;976];
% community = [16620;5198;966;639];
% mild60 = [375;224;38;46];
% mild = [130;33;nan;nan];
% moderate60 = [218;115;16;nan];
% moderate = [60;nan;0;nan];
% severe60 = [232;164;46;36];
% severe = [71;20;nan;nan];
% critical60 = [43;37;11;nan];
% critical = [11;nan;nan;nan];
% deceased60 = [311;165;32;17];
% deceased = [16;nan;nan;0];
% total60 = [7190;5017;1134;1093];
% total = [16908;5273;977;643];
% t = table(time,community60,mild60,moderate60,severe60,critical60,deceased60,total60,...
%     community,mild,moderate,severe,critical,deceased,total);
t = readtable('~/covid-19-israel-matlab/data/Israel/11 Feb 2021.csv');
y = t{:,3:7};
y = y./sum(sum(y,2))*100;
% r = t{4,8}-nansum(t{4,2:7});
% y(4,[2,4]) = r*[2/3,1/3];
% y = y./t{:,7}*100;
figure;
subplot(1,2,1)
h = bar(y,'stacked','EdgeColor','none');
for ii = 1:5
    col(ii,1:3) = h(ii).FaceColor;
end
h(1).FaceColor = col(5,:);
h(2).FaceColor = col(1,:);
h(3).FaceColor = col(4,:);
h(4).FaceColor = col(2,:);
h(5).FaceColor = [0,0,0];
legend(fliplr(h),fliplr({'Mild','Moderate','Severe','Critical','Deceased'}))
set(gca,'XTickLabel',{'dose I, days 0-13';'dose I, 14 days or more';'dose II, days 0-6';'dose II, days 7-14';'dose II, more than 14 days'},'ygrid','on')
text([1,1,1,1,1]-0.15,cumsum(y(1,:))-1,num2str(t{1,3:7}'),'Color','w')
text([2,2,2,2,2]-0.15,cumsum(y(2,:))-1,num2str(t{2,3:7}'),'Color','w')
ylabel('hospitalized (% of all 60+ vaccinated patients)')
box off
title('Older than 60')
ylim([0 80])
set(gca,'FontSize',13)
xtickangle(15)

y = t{:,9:13};
y = y./sum(sum(y,2))*100;
subplot(1,2,2)
h = bar(y,'stacked','EdgeColor','none');
h(1).FaceColor = col(5,:);
h(2).FaceColor = col(1,:);
h(3).FaceColor = col(4,:);
h(4).FaceColor = col(2,:);
h(5).FaceColor = [0,0,0];
% legend(fliplr(h),fliplr({'Mild','Moderate','Severe','Critical','Deceased'}))
set(gca,'XTickLabel',{'dose I, days 0-13';'dose I, 14 days or more';'dose II, days 0-6';'dose II, days 7-14';'dose II, more than 14 days'},'ygrid','on')
text([1,1,1,1,1]-0.15,cumsum(y(1,:))-1,num2str(t{1,9:13}'),'Color','w')
text([2,2,2,2,2]-0.15,cumsum(y(2,:))-1,num2str(t{2,9:13}'),'Color','w')
ylabel('hospitalized (% of all <60 vaccinated patients)')
box off
title('Younger than 60')
set(gcf,'Color','w')
set(gca,'FontSize',13)
xtickangle(15)