cd ~/covid-19-israel-matlab/data/Israel
load vacc
% how many old people are expected to die
ratOldDeaths = 0.01;
old = sum(vacc.pop1000(end-2:end)-vacc.recovered1000(end-2:end)-vacc.vacc1000(end-2:end))*ratOldDeaths*1000;
% fr = vacc.deathrate./vacc.perc_recovered;
% fr = fr/sum(fr);
deaths = [6;3;14;23;55;211;556;1034;1425+854];
fr = (deaths/1000)./(vacc.recovered1000+deaths/1000);
ifr = [0.00001;0.00003;0.0001;0.0002;0.001;0.002;0.01;0.045;0.15];
toll1 = old/sum(vacc.deathrate(end-2:end)).*vacc.deathrate;
% toll = sum(vacc.pop1000-vacc.recovered1000-vacc.vacc1000)*fr;
% toll = vacc.pop1000.*(100-vacc.perc_recovered+vacc.perc_vacc)/100.*fr*1000;
undescoveredRat = 2;
toll2 = vacc.pop1000.*(100-vacc.perc_recovered*undescoveredRat-vacc.perc_vacc)/100.*fr*1000;
undescoveredRat = 3;
toll3 = vacc.pop1000.*(100-vacc.perc_recovered*undescoveredRat-vacc.perc_vacc)/100.*fr*1000;

figure;
h = bar([deaths,toll3,toll2]);
set(gca, 'YScale', 'log')
grid on
text((1:9)-0.25,toll3*1.5,str(round(toll3)),'Color',h(2).FaceColor)
text((1:9)-0.5,deaths*1.25,str(round(deaths)),'Color',h(1).FaceColor)
set(gca,'XTickLabel',vacc.age,'fontsize',13)
set(gcf,'Color','w')
ylabel('תמותה')
xlabel('שכבת גיל')
legend('תמותה עד כה','תמותת לא מוגנים אם התגלו שליש מהנדבקים','תמותת לא מוגנים אם התגלו חצי מהנדבקים')
title('פוטנציאל התמותה לפי כמות הנדבקים והמחוסנים לפי שכבת גיל')