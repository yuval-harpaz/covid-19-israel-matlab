
N = [50,1000,450,1500];
% sick = [0.4,0.2,0.1,4/180].*N;
sick = [25 20 35 1];
healthy = N - sick;
ve = 100*(1-(sick(3:4)./healthy(3:4))./(sick(1:2)./healthy(1:2)));
vea = 100*(1-(sum(sick(3:4))./sum(healthy(3:4)))./(sum(sick(1:2))./sum(healthy(1:2))));
disp([ve,vea])
sig = [-1,1;1,1;-1,-1;1,-1];
iCol = [1;1;2;2];

%%
figure;
for ii = 1:4
    co = 0.9-ii/10;
    fill([sig(ii,1)*sqrt(N(ii)) 0 0 sig(ii,1)*sqrt(N(ii))],[0 0 sig(ii,2)*sqrt(N(ii)) sig(ii,2)*sqrt(N(ii))],[co co co],'linestyle','none');
    hold on
    cos = [0.2 0.2 0.2];
    cos(iCol(ii)) = 0.7;
    fill([sig(ii,1)*sqrt(sick(ii)) 0 0 sig(ii,1)*sqrt(sick(ii))],[0 0 sig(ii,2)*sqrt(sick(ii)) sig(ii,2)*sqrt(sick(ii))],cos,'linestyle','none');
end

axis equal
box off
text([-15,15],[30,30],{'old','young'},'FontSize',13)
text([-30,-30],[15,-15],{'unvacc','vacc'},'rotation',90,'FontSize',13)
in = 2;
text([-in,in,-in,in],[in,in,-in,-in],cellstr(str(sick'))')
ex = 6.5;
text([-ex,ex,-ex,ex],[ex,ex,-ex,-ex],cellstr(str(healthy'))')
set(gca,'FontSize',13)
% set(gca,'ytick',-15:5:10)
% ylim([-15 10])
% xlim([-10 15])
%%
% 
% fill([-sqrt(10) 0 0 -sqrt(10)],[0 0 sqrt(10) sqrt(10)],[0.8 0.8 0.8],'linestyle','none') % old unvac
% hold on
% fill([sqrt(90) 0 0 sqrt(90)],[0 0 sqrt(90) sqrt(90)],[0.7 0.7 0.7],'linestyle','none') % young unvac
% fill([-sqrt(20) 0 0 -sqrt(20)],[0 0 -sqrt(20) -sqrt(20)],[0.6 0.6 0.6],'linestyle','none') % old vac
% fill([sqrt(180) 0 0 sqrt(180)],[0 0 -sqrt(180) -sqrt(180)],[0.5 0.5 0.5],'linestyle','none') % young vac
% 
% fill([-sqrt(2) 0 0 -sqrt(2)],[0 0 sqrt(2) sqrt(2)],[0.7 0.2 0.2],'linestyle','none') % old unvac
% hold on
% fill([sqrt(18) 0 0 sqrt(18)],[0 0 sqrt(18) sqrt(18)],[0.7 0.2 0.2],'linestyle','none') % young unvac
% fill([-sqrt(2) 0 0 -sqrt(2)],[0 0 -sqrt(2) -sqrt(2)],[0.2 0.7 0.2],'linestyle','none') % old vac
% fill([sqrt(18) 0 0 sqrt(18)],[0 0 -sqrt(18) -sqrt(18)],[0.2 0.7 0.2],'linestyle','none') % young vac
