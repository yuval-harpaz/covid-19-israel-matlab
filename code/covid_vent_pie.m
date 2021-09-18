dose(1,1) = 2+3+4+1+1+4+2+3+3+5+2+4+4+2+8+1+5+2+4+4;
dose(2,1) = 4;
dose(3,1) = 14;
dose(4,1) = 10;
figure;
h = pie(dose);
h(1).FaceColor = [1,0.55, 0.55];
h(3).FaceColor = [1,0.55, 0.35];
h(5).FaceColor = [0.55,0.9, 0.55];
h(7).FaceColor = [0,0.55, 0];
set(gcf,'Color','w')
legend([str(dose(1)),' with ','0 doses'],['  ',str(dose(2)),' with ','1 dose'],...
    [str(dose(3)),' with ','2 doses'],[str(dose(4)),' with ','3 doses'],'location','northwest')
title({'New ventilated by vaccination status for','60+ years old between 29 Aug and 17 Sep'})

pop = [143734;nan;288838;1116560];
ve2 = 100*(1-(dose(3)/pop(3))/(dose(1)/pop(1)));
ve3 = 100*(1-(dose(4)/pop(4))/(dose(1)/pop(1)));