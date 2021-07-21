% get https://docs.google.com/spreadsheets/d/1kiOrQxOtBg0__IoLkEZgqhMDpIQCXbBxEE78BwqcOs4/edit?usp=sharing
% !wget 'https://docs.google.com/uc?export=download&id=IoLkEZgqhMDpIQCXbBxEE78BwqcOs4&output=csv' -O ~/covid-19-israel-matlab/data/Israel/delta.csv --no-check-certificate 

!wget --no-check-certificate -O ~/covid-19-israel-matlab/data/Israel/delta.csv 'https://docs.google.com/spreadsheets/d/1kiOrQxOtBg0__IoLkEZgqhMDpIQCXbBxEE78BwqcOs4/export?gid=472501586&format=csv'
delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv','ReadVariableNames',true);

figure;
yyaxis left
ylabel('cases')
plot(delta.date,movmean([delta.casesNoVacc,delta.casesVacc],[3 3]))
yyaxis right
plot(delta.date,movmean([delta.hospNoVacc,delta.hospVacc],[3 3]))
legend('cases no vacc','cases vacc','hosp no vacc','hosp vacc')
ylabel('hospital admissions')
title({'Cases vs Hospitalizations by vaccination status','מאומתים ומאושפזים לפי מצב חיסוני'})
grid on
ylim([0 10])

vacc30 = 1937000+2160000;
pop30 = 2317000+2462000;
vacc = 1000*(21+151+437+1020+1937+2160);
pop = 9500000;

figure;
yyaxis left
plot(delta.date,10^6*movmean([delta.casesNoVacc/(pop-vacc),delta.casesVacc/vacc],[3 3]))
ylabel('cases per Million')
yyaxis right
plot(delta.date,10^6*movmean([delta.hospNoVacc/(pop30-vacc30),delta.hospVacc/vacc30],[3 3]))
legend('cases no vacc','cases vacc','hosp no vacc','hosp vacc','location','northwest')
ylabel('hospital admissions per Million')
title({'Cases vs Hospitalizations by vaccination status','מאומתים ומאושפזים לפי מצב חיסוני'})
grid on
% ylim([0 10])
cd ~/covid-19-israel-matlab/
!git add ~/covid-19-israel-matlab/data/Israel/delta.csv
!git commit -m "gdrive to csv"
!git push

%%
figure;
yyaxis left
plot(delta.date,10^6*movmean([delta.casesNoVacc/(pop-vacc),delta.casesVacc/vacc],[3 3]))
ylabel('cases per Million')
yyaxis right
plot(delta.date,10^6*movmean([delta.severeNoVacc/(pop30-vacc30),delta.severeVacc/vacc30],[3 3]))
legend('cases no vacc','cases vacc','hosp no vacc','hosp vacc','location','northwest')
ylabel('hospital admissions per Million')
title({'Cases vs Severe by vaccination status','מאומתים ומאושפזים לפי מצב חיסוני'})
grid on
% ylim([0 10])
cd ~/covid-19-israel-matlab/

%%
figure
yyaxis left
plot(delta.date,delta.cases50_);
yyaxis right
plot(delta.date,delta.severe65_)