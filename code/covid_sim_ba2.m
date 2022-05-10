pop = 15710;
vu1 = [993,800];
vu = round(vu1/(1571000/pop));

x = rand(pop,1);
y = rand(pop,1);
vax = false(pop,1);
vax(x < 0.92) = true;
ba1 = false(pop,1);
ba1(y < 0.5) = true;
ba2 = false(pop,1);
ba2(y < 0.75 & y > 0.25) = true;


rng(3)
dead = false(pop,1);
tmp = find(ba1 & vax);
dead(tmp(randperm(length(tmp),vu(1)))) = true;
tmp = find(ba1 & ~vax);
dead(tmp(randperm(length(tmp),vu(2)))) = true;
dead2 = false(pop,1);
tmp = find(ba2 & vax & ~ba1);
dead2(tmp(randperm(length(tmp),vu(1)/2))) = true;
tmp = find(ba2 & ~vax & ~ba1);
dead2(tmp(randperm(length(tmp),vu(2)/2))) = true;
ratio = vu1./(0.5.*[0.92 0.08].*1571000);
%%
fig1 = figure('position',[810,20,800,600]);
hh(1) = plot(x(~vax & ~ba1),y(~vax & ~ba1),'.m');
hold on
hh(2) = plot(x(vax & ~ba1),y(vax & ~ba1),'.g');
text([0.2,1],[0.9,0.9],{'Vaccinated','Unvaccinated'},'fontsize',15);
axis square
axis off
saveas(fig1,'tmp1.png');

fig2 = figure('position',[810,20,800,600]);
hh(1) = plot(x(~vax & ~ba1),y(~vax & ~ba1),'.m');
hold on
hh(2) = plot(x(vax & ~ba1),y(vax & ~ba1),'.g');
hh(3) = plot(x(ba1),y(ba1),'.','MarkerEdgeColor',[0.1,0.8,0.1],'MarkerSize',4);
hh(4) = plot(x(dead),y(dead),'.k','MarkerSize',15);
axis square
axis off
hl = legend(hh(4),'deaths');
hl.Box = 'off';
hl.Position(1) = 0;
hl.FontSize = 13;
text([0.2,1,0.4],[0.9,0.9,0.2],{'Vaccinated','Unvaccinated','BA1'},'fontsize',15);
saveas(fig2,'tmp2.png');

fig3 = figure('position',[20,20,800,600]);
hh(1) = plot(x(~vax & ~ba1 & ~ba2),y(~vax & ~ba1 & ~ba2),'.m');
hold on
hh(2) = plot(x(vax & ~ba1 & ~ba2),y(vax & ~ba1 & ~ba2),'.g');
hh(3) = plot(x(ba1 & ~ba2),y(ba1 & ~ba2),'.','MarkerEdgeColor',[0.1,0.8,0.1],'MarkerSize',4);
hh(4) = plot(x(ba2), y(ba2),'.','MarkerEdgeColor',[0.1,0.5,0.1],'MarkerSize',4);
hh(5) = plot(x(dead),y(dead),'.k','MarkerSize',15);
hh(6) = plot(x(dead2),y(dead2),'.','MarkerEdgeColor',[0.1,0.1,0.8],'MarkerSize',15);
axis square
axis off
hl = legend(hh(5:6),'deaths','expected deaths');
hl.Box = 'off';
hl.Position(1) = 0.05;
hl.FontSize = 13;
text([0.2,1,0.4, 0.4],[0.9,0.9,0.2, 0.35],{'Vaccinated','Unvaccinated','BA1','BA2'},'fontsize',15);
saveas(fig3,'tmp3.png');
