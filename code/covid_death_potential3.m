function covid_death_potential3

cd ~/covid-19-israel-matlab/data/Israel
jf=java.text.DecimalFormat;
json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinationsPerAge');
json = jsondecode(json);
tv = struct2table(json);

json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectedByAgeAndGenderPublic');
json = jsondecode(json);
ti = struct2table(json);

% population0 = [sum(vacc.pop1000(1:2))*1000;vacc.pop1000(3:8)*1000;vacc.pop1000(9)*1000];
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
vaccinated1 = [tv.vaccinated_first_dose(1);tv.vaccinated_first_dose(2:7);sum(tv.vaccinated_first_dose(8:9))];
vaccinated2 = [tv.vaccinated_second_dose(1);tv.vaccinated_second_dose(2:7);sum(tv.vaccinated_second_dose(8:9))];
vaccinated1 = vaccinated1-vaccinated2;
confirmed = [sum(sum(ti{1:2,2:3}));sum(ti{3:8,2:3},2);sum(sum(ti{9:10,2:3}))];
age = [{'0-20'};tv.age_group(2:end-1)];
age{end} = '80+';
ifr = [0.00002;0.0001;0.0002;0.001;0.002;0.01;0.045;0.15];
tt = table(age,population,confirmed,vaccinated1,vaccinated2,ifr);
tt.age(end+1:end+2) = {'0-49';'50+'};
tt{9:10,2:5} = [sum(tt{1:4,2:5});sum(tt{5:8,2:5})];
tt.ifr(9) = sum(tt.ifr(1:4).*tt.population(1:4))./sum(tt.population(1:4));
tt.ifr(10) = sum(tt.ifr(5:8).*tt.population(5:8))./sum(tt.population(5:8));

%% deaths for vaccinated / recovered

yy = round(tt{9:10,3:5}.*tt.ifr(9:10).*[(1-0.72),(1-0.72),(1-0.92)]);
yl = [100,5000];
tit = {'צעירים מ- 50','מבוגרים מ- 50'};
figure;
for ip = 1:2
    subplot(1,2,ip)
    bar(yy(ip,:))
    ylim([0 yl(ip)])
    title(tit{ip})
    box off
    set(gca,'ygrid','on','XTickLabel',{'מחלימים','מנה I','מנה II'},'fontsize',13)
end
set(gcf,'Color','w')
disp('done')
% 
% bar(yy)
% yy = min(tt.vaccinated1+tt.confirmed,population);
% % yy = tt.vaccinated1+tt.confirmed;
% yy = round(yy.*[ifr*0.01,ifr*0.05]);
% yy(yy < 0) = 0;
% yy(end+1,:) = sum(yy);
% %%
% figure('position',[100,100,1000,650]);
% h = bar(yy);
% ylim([0.1 max(max(yy))*1.75])
% set(gca, 'YScale', 'log')
% grid on
% text((1:9)-0.35,yy(:,1)*1.25,str(round(yy(:,1))),'Color',h(1).FaceColor)
% text((1:9),yy(:,2)*1.25,str(round(yy(:,2))),'Color',h(2).FaceColor)
% % text((1:9),y(:,3)*1.25,str(round(y(:,3))),'Color',h(3).FaceColor)
% 
% set(gca,'XTickLabel',[age;{'סה"כ'}],'fontsize',13)
% set(gcf,'Color','w')
% ylabel('תמותה')
% % xlabel('שכבת גיל')
% legend('IFR x 1%','IFR x 5%','location','northwest')
% title('פוטנציאל התמותה בקרב המחוסנים,  לפי אחוז פגיעות מקל (1%) ומחמיר (%5)')
% 
% for iAge = 1:length(ifr)
%     txtx{iAge,1} = ['1:',char(jf.format(round(1./(ifr(iAge)*0.01))))];
%     txtx{iAge,2} = ['1:',char(jf.format(round(1./(ifr(iAge)*0.05))))];
% end
% 
% % strrep(cellstr([repmat('1/',8,1),num2str(round(1./(ifr*0.01)))]),' ','')
% 
% text((1:8)-0.25,repmat(0.05,1,8),txtx(:,1),'Color',h(1).FaceColor)
% text((1:8)-0.25,repmat(0.035,1,8),txtx(:,2),'Color',h(2).FaceColor)
% text(0.3,0.07,'גיל','FontSize',13)
% text(0.3,0.05,'IFR','Color',h(1).FaceColor)
% text(0.3,0.035,'IFR','Color',h(2).FaceColor)
% 
% tt.death_unprotected_low = round(y(1:end-1,1));
% tt.death_unprotected_high = round(y(1:end-1,2));
% tt.death_protected_low = round(yy(1:end-1,1));
% tt.death_protected_high = round(yy(1:end-1,2));
% writetable(tt,'death_potential.csv','Delimiter',',','WriteVariableNames',true)
% 
