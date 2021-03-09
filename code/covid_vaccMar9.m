
vac50 = [69,1574,131,67,26;26,152,41,26,44;19,61,10,3.9,22];
vacc = [358,2958,729,311,413,1547;129,346,224,141,370,597;192,143,62,26,150,381];
vaccY = vacc;
vaccY(:,1:5) = vaccY(:,1:5)-vac50;
col = [0.255,0.51,0.282;0,0.224,0.631;0,0.529,0.984;0.855,0.925,0.976;1,1,1;0.863,0.863,0.863];
figure('units','normalized','position',[0.3,0.45,0.25*2,0.55]);
subplot(1,2,1)
hy = bar(vaccY./(sum(vaccY,2)),'stacked');
for ii = 1:6
    hy(ii).FaceColor = col(ii,:);
end
set(gca,'YTickLabel',0:10:100,'XTickLabel',{'General','Arab','Haredi'},...
    'fontsize',13,'ygrid','on');
title('vaccination below 50')
legend(fliplr(hy),fliplr({'recovered','dose II+7','dose I+14','dose I','no vaccine','children'}))
box off

subplot(1,2,2)
hy = bar(vac50./(sum(vac50,2)),'stacked');
for ii = 1:4
    hy(ii).FaceColor = col(ii,:);
end
set(gca,'YTickLabel',0:10:100,'XTickLabel',{'General','Arab','Haredi'},...
    'fontsize',13,'ygrid','on');
title('vaccination over 50')
% legend(fliplr(hy),fliplr({'recovered','dose II+7','dose I+14','dose I','no vaccine','children'}))
box off
