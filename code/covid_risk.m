myo = 1/6576;
misc = 1/2000;
severe = 1/1674;
r = sqrt([myo,misc,severe]*100000/pi);
xx = [200,158+300,158+330];
yy = [80,100,120];
% viscircles([1,1;2,1;3,1.5],r)

I = uint8(256*ones(316,316*2,3));
I(:,1:316,[1,3]) = 200;
I(:,317:end,2:3) = 200;

for ir = 1:3
    I = insertShape(I,'FilledCircle',[xx(ir) yy(ir) r(ir)],'color','r','LineWidth',100);
end
figure;
imshow(I)
title({'Risk for kids from vaccination and severe covid                    ',...
    '100,000 vaccinated kids                       100,000 infected kids'})
set(gcf,'Color','w')
issue = {'Myocarditis (15)','MIS-C (50)','Severe COVID19 (60)'};
for ii = 1:3
    text(xx(ii)+10,yy(ii),issue{ii})
end
    
% hold on
% plot(100,100,'.','MarkerSize',50)
% axis equal