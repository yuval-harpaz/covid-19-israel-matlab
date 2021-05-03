function [tt,Hasinut] = covid_herd_timecourse(hidden)
% deathVE = IEdefault('deathVE',[0.02 0.08]);
% fac = IEdefault('fac',[2/3,1]);
vac = 2;  % dose 1 or 2
hidden = IEdefault('hidden',linspace(3.5,2,8)'); %how much to multiply to get confirmed + hidden
cd ~/covid-19-israel-matlab/data/Israel
[agf, agDate] = covid_fix_age('');
confirmed = [sum(agf{end,2:3});agf{end,4:9}';sum(agf{end,10:11})];
!wget -O tmp.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/vaccinated_by_age.csv
agVacc = readtable('tmp.csv');
agVaccDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),agVacc.Date);
vaccinated = [agVacc{end,4:3:22},sum(agVacc{end,[25,28]})]';
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
age = {'0-19';'20-29';'30-39';'40-49';'50-59';'60-69';'70-79';'80+'};%vacc.age(2:end);
notConf = population-confirmed;
recovered_and_vacc = round((confirmed.*hidden./notConf) .* (vaccinated./notConf) .* notConf);
recovered_not_vacc = confirmed.*hidden-recovered_and_vacc+confirmed;
immune = vaccinated+recovered_not_vacc;
tt = table(age,population,confirmed,vaccinated,notConf,recovered_and_vacc,recovered_not_vacc,immune);
for ii = 2:size(tt,2)
    tt{:,ii} = round(tt{:,ii});
end
Hasinut = round(100*sum(immune)./sum(population));
%%
figure('position',[100,100,1000,650]);
h = bar(1:8,tt.immune./tt.population);
hold on
bar(1:8,(tt.recovered_not_vacc+tt.recovered_and_vacc)./tt.population);
bar(1:8,tt.recovered_not_vacc./tt.population);
plot(1:8,tt.confirmed./tt.population,'ok','MarkerFaceColor','k');
legend('vaccinated','recovered + vaccinated','recovered','confirmed','location','east')
set(gca,'XTickLabel',tt.age,'FontSize',13,'ygrid','on','YTickLabel',0:10:100)
title(['herd immunity by age. total: ',str(Hasinut),'%  :','חיסון עדר לפי גיל. סה"כ',])
set(gcf,'Color','w')
ylabel('%')
% writetable(tt,'herd_immunity.csv','Delimiter',',','WriteVariableNames',true)
%%
date = unique(dateshift(agDate,'start','day'));
dateInf = dateshift(agDate,'start','day');
dateVacc = dateshift(agVaccDate,'start','day');
clear vaccinated confirmed immune
for iDate = 1:length(date)
    rowInf = find(ismember(dateInf,date(iDate)),1,'last');
    conf = [sum(agf{rowInf,2:3});agf{rowInf,4:9}';sum(agf{rowInf,10:11})];
    rowVacc = find(ismember(dateVacc,date(iDate)),1,'last');
    if isempty(rowVacc)
        vaccinated = zeros(8,1);
    else
        vaccinated = [agVacc{rowVacc,4:3:22},sum(agVacc{rowVacc,[25,28]})]';
    end
    notConf = population-conf;
    recovered_and_vacc = round((conf.*hidden./notConf) .* (vaccinated./notConf) .* notConf);
    recovered_not_vacc = conf.*hidden-recovered_and_vacc+conf;
    imm = vaccinated+recovered_not_vacc;
    confirmed(iDate,1) = sum(conf);
    confirmed_or_vaccinated(iDate,1) = confirmed(iDate,1) + sum(vaccinated);
    immune(iDate,1) = sum(imm);
    herd_immunity(iDate,1) = round(100*sum(imm)./sum(population),1);
    
end
ttt = table(date,confirmed,confirmed_or_vaccinated,immune,herd_immunity);
writetable(ttt,'herd_immunity_by_date.csv','Delimiter',',','WriteVariableNames',true)
%%
figure;

yyaxis right
plot(ttt.date,ttt{:,end});
hold on
for ii = 1:11
    line([ttt.date(1),ttt.date(end)],[(ii-1)*10 (ii-1)*10],'linestyle',':');
    
end

ylim([0 100])

yyaxis left
plot(ttt.date,ttt{:,2:end-2});
ylim([0 sum(population)])

xlim([ttt.date(1),ttt.date(end)])
legend(strrep(ttt.Properties.VariableNames(2:end-1),'_',' '),'Location','northwest')
% grid on
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis(1).TickLabelFormat = '%,.0f';
set(gca,'XGrid','on')
xtickformat('MMM')
set(gcf,'Color','w')
title('Herd-Immunity estimate for Israel')