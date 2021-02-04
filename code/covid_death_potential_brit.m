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

json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinationsPerAge');
json = jsondecode(json);
tv = struct2table(json);

json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectedByAgeAndGenderPublic');
json = jsondecode(json);
ti = struct2table(json);

population = [sum(vacc.pop1000(1:2))*1000;vacc.pop1000(3:8)*1000;vacc.pop1000(9)*1000];
vaccinated1 = [tv.vaccinated_first_dose(1);tv.vaccinated_first_dose(2:7);sum(tv.vaccinated_first_dose(8:9))];
confirmed = [sum(sum(ti{1:2,2:3}));sum(ti{3:8,2:3},2);sum(sum(ti{9:10,2:3}))];
age = vacc.age(2:end);
age{1} = '0-20';
ifr = [0.00002;0.0001;0.0002;0.001;0.002;0.01;0.045;0.15];
tt = table(age,population,confirmed,vaccinated1,ifr);

% ifrr = [0.00002;0.0001;0.0002;0.001;0.002;0.01;0.045;0.15];
y = population-vaccinated1-confirmed;
fac = 1;
notConf = population-confirmed;
vaccAndConf = round((confirmed*fac./notConf) .* (vaccinated1./notConf) .* notConf);
confNotVax = confirmed*fac-vaccAndConf;
y(:,2) = population-vaccinated1-confirmed*(1+fac);
y(:,3) = population-vaccinated1-confirmed-confNotVax;
y = y.*ifr;
y(end+1,:) = sum(y);
%%
figure;
h = bar(y);
ylim([10 max(y(:,1)*1.5)])
set(gca, 'YScale', 'log')
grid on
text((1:9)-0.5,y(:,1)*1.25,str(round(y(:,1))),'Color',h(1).FaceColor)
text((1:9)-0.25,y(:,2)*1.25,str(round(y(:,2))),'Color',h(2).FaceColor)
text((1:9),y(:,3)*1.25,str(round(y(:,3))),'Color',h(3).FaceColor)

set(gca,'XTickLabel',[age;{'Total'}],'fontsize',13)
set(gcf,'Color','w')
ylabel('תמותה')
xlabel('שכבת גיל')
legend('תמותת לא מוגנים ','תמותת לא מוגנים אם התגלו חצי מהנדבקים')
title('פוטנציאל התמותה לפי כמות הנדבקים והמחוסנים לפי שכבת גיל')

%% 

fac = 1;
notConf = population-confirmed;
vaccAndConf = round((confirmed*fac./notConf) .* (vaccinated1./notConf) .* notConf);
confNotVax = confirmed*fac-vaccAndConf;
y = population-vaccinated1-confirmed-confNotVax;
% easy ifr, herd immunity
fac = 1.3;
y = y.*[ifr,ifr*fac];
y(end+1,:) = sum(y);
Hasinut = sum((vaccinated1+confirmed+confNotVax))./sum(population);
Hasinut = [str(round(Hasinut*100)),'%'];
%%
figure('position',[100,100,900,600]);
h = bar(y);
ylim([10 max(max(y))*1.5])
set(gca, 'YScale', 'log')
grid on
text((1:9)-0.35,y(:,1)*1.25,str(round(y(:,1))),'Color',h(1).FaceColor)
text((1:9),y(:,2)*1.25,str(round(y(:,2))),'Color',h(2).FaceColor)
% text((1:9),y(:,3)*1.25,str(round(y(:,3))),'Color',h(3).FaceColor)

set(gca,'XTickLabel',[age;{'Total'}],'fontsize',13)
set(gcf,'Color','w')
ylabel('תמותה')
% xlabel('שכבת גיל')
legend('IFR x 1',['IFR x ',str(fac)],'location','northwest')
title({'פוטנציאל התמותה לפי כמות הנדבקים והמחוסנים לפי שכבת גיל',['החסינות כרגע ',Hasinut]})
text((1:8)-0.25,repmat(6,1,8),strrep(cellstr([repmat('1/',8,1),num2str(round(1./(ifr)))]),' ',''),'Color',h(1).FaceColor)
text((1:8)-0.25,repmat(5,1,8),strrep(cellstr([repmat('1/',8,1),num2str(round(1./(ifr*fac)))]),' ',''),'Color',h(2).FaceColor)
text(0.3,8,'גיל','FontSize',13)
text(0.3,6,'IFR','Color',h(1).FaceColor)
text(0.3,5,'IFR','Color',h(2).FaceColor)