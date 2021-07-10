% get https://docs.google.com/spreadsheets/d/1kiOrQxOtBg0__IoLkEZgqhMDpIQCXbBxEE78BwqcOs4/edit?usp=sharing
% !wget 'https://docs.google.com/uc?export=download&id=IoLkEZgqhMDpIQCXbBxEE78BwqcOs4&output=csv' -O ~/covid-19-israel-matlab/data/Israel/delta.csv --no-check-certificate 

!wget --no-check-certificate -O ~/covid-19-israel-matlab/data/Israel/delta.csv 'https://docs.google.com/spreadsheets/d/1kiOrQxOtBg0__IoLkEZgqhMDpIQCXbBxEE78BwqcOs4/export?gid=472501586&format=csv'
delta = readtable('~/covid-19-israel-matlab/data/Israel/delta.csv');

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