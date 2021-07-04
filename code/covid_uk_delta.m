% age = readtable('~/Downloads/UK.csv','ReadVariableNames',true);
hosp = readtable('~/Downloads/data_2021-Jul-02.csv');
age = readtable('~/Downloads/nation_E92000001_2021-07-03.csv');
age.age = strrep(age.age,'+','_');
date = unique(age.date);
ages = unique(age.age);
for iDate = 1:length(date)
    idx = age.date == date(iDate);
    for iAge = 1:length(ages)
        iax = find(ismember(age.age,ages{iAge}) & idx);
        eval(['age_',ages{iAge},'(iDate,1) = age.cases(iax);'])
    end
end

cases70 = age_70_74+age_75_79+age_80_84+age_85_89+age_90_;

% figure;
% yyaxis left
% plot(hosp.date,hosp.newAdmissions)
% yyaxis right
% plot(date,cases70)
% ylim([0 6000])
%%
figure;
yyaxis left
plot(hosp.date,hosp.newAdmissions)
ylabel('Hospital admissions')
yyaxis right
plot(date,age_60_)
ylim([0 10000])
ylabel('New cases 60+ years old')
grid on
set(gcf,'Color','w')
legend('Hospitalizations','Cases 60+')
title('Cases (60+) vs Hospitalizations')
xtickformat('MMM');
set(gca,'xtick',datetime(2020,4:30,1))
xlim([datetime(2020,8,1) datetime('tomorrow')]);

t = table(age_00_04,age_05_09,age_10_14,age_15_19,age_20_24,age_25_29,age_30_34,...
    age_35_39,age_40_44,age_45_49,age_50_54,age_55_59,age_60_64,age_65_69,age_70_74,age_75_79,age_80_84,age_85_89,age_90_);
yy = movmean(t{:,:},[3 3]);
figure;
h = bar(date,yy,'stacked')
xlim([datetime(2020,8,1) datetime('tomorrow')])

idx = find(ismember(date,[datetime(2020,10,18),datetime(2020,12,09)]));
idx(3) = height(t);
figure;
h3 = bar(1:3,yy(idx,:),'stacked');
ag = t.Properties.VariableNames;
ag = strrep(ag,'age_','');
ag = strrep(ag,'_','-');
ag{end} = '90+';
legend(fliplr(h3),fliplr(ag))
set(gca,'ygrid','on','XTickLabel',{'18.10.20','09.12.20','28.06.21'})
xlim([0 5])
% xlim([datetime(2020,8,1) datetime('tomorrow')])
% date(idx)