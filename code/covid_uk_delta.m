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

figure;
yyaxis left
plot(hosp.date,hosp.newAdmissions)
yyaxis right
plot(date,cases70)
ylim([0 6000])
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
