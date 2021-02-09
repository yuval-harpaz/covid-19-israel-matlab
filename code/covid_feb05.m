time = {'Dose I +13';'Dose I 14+';'Dose II +6';'Dose II 7+'};
community60 = [6011;4312;991;976];
community = [16620;5198;966;639];
mild60 = [375;224;38;46];
mild = [130;33;nan;nan];
moderate60 = [218;115;16;nan];
moderate = [60;nan;0;nan];
severe60 = [232;164;46;36];
severe = [71;20;nan;nan];
critical60 = [43;37;11;nan];
critical = [11;nan;nan;nan];
deceased60 = [311;165;32;17];
deceased = [16;nan;nan;0];
total60 = [7190;5017;1134;1093];
total = [16908;5273;977;643];
t = table(time,community60,mild60,moderate60,severe60,critical60,deceased60,total60,...
    community,mild,moderate,severe,critical,deceased,total);

y = t{:,3:7};
r = t{4,8}-nansum(t{4,2:7});
y(4,[2,4]) = r*[2/3,1/3];
% y = y./t{:,7}*100;
figure;
subplot(1,2,1)
h = bar(y./(sum(t{:,8})-sum(t{:,2}))*100,'stacked','EdgeColor','none');
for ii = 1:5
    col(ii,1:3) = h(ii).FaceColor;
end
h(1).FaceColor = col(5,:);
h(2).FaceColor = col(1,:);
h(3).FaceColor = col(4,:);
h(4).FaceColor = col(2,:);
h(5).FaceColor = [0,0,0];
legend(fliplr(h),fliplr({'Mild','Moderate','Severe','Critical','Deceased'}))
set(gca,'XTickLabel',time,'ygrid','on')
text([1,1,1,1,1]-0.15,cumsum(y(1,:))./(sum(t{:,8})-sum(t{:,2}))*100-1,num2str(t{1,3:7}'),'Color','w')
text([2,2,2,2,2]-0.15,cumsum(y(2,:))./(sum(t{:,8})-sum(t{:,2}))*100-1,num2str(t{2,3:7}'),'Color','w')
ylabel('hospitalized (%)')
box off
title('Older than 60')
ylim([0 80])

y = t{:,10:14};
d = diff(t{:,[9,15]}')';
r = d-nansum(y,2);
y(2,[2,4,5])=[12,5,5];
y(3,[1,3,4,5])=[5,3,2,1];
y(3,1:4) = 1;
subplot(1,2,2)
h = bar(y./(sum(t{:,15})-sum(t{:,9}))*100,'stacked','EdgeColor','none');
h(1).FaceColor = col(5,:);
h(2).FaceColor = col(1,:);
h(3).FaceColor = col(4,:);
h(4).FaceColor = col(2,:);
h(5).FaceColor = [0,0,0];
% legend(fliplr(h),fliplr({'Mild','Moderate','Severe','Critical','Deceased'}))
set(gca,'XTickLabel',time,'ygrid','on')
text([1,1,1,1,1]-0.15,cumsum(y(1,:))./(sum(t{:,15})-sum(t{:,9}))*100-1,{'130','60','71','<15','16'},'Color','w')
text([2,2,2,2,2]-0.15,cumsum(y(2,:))./(sum(t{:,15})-sum(t{:,9}))*100-1,{'33','<15','20','','<15'},'Color','w')
ylabel('hospitalized (%)')
box off
title('Younger than 60')
set(gcf,'Color','w')