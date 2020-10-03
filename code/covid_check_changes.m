
cd ~/covid-19-israel-matlab/
% % [~,msg] = system('git log --oneline > tmp.log')
% !git log --pretty=tformat:"%H" --shortstat > tmp.log
log = importdata('tmp.log');
log = log(1:2:300);
%%
for ii = 1:length(log)
    [~,msg] = system(['wget -O tmp.csv https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/',...
        log{ii},'/data/Israel/dashboard_timeseries.csv']);
    t = readtable('tmp.csv');
%     t.CountHardStatus(isnan(t.CountHardStatus)) = 0;
%     t.CountDeath(isnan(t.CountDeath)) = 0;
%     t.CountEasyStatus(isnan(t.CountEasyStatus)) = 0;
%     t.CountMediumStatus(isnan(t.CountMediumStatus)) = 0;
    t = t(1:end-1,:);
    len(ii,1) = height(t);
     if ii == 1
        date = t.date;
        posMax = t.tests_positive;
        posMin = t.tests_positive;
        stat = zeros(height(t),length(log));
        statNeg = zeros(height(t),length(log));
     else
         [~,iExist] = ismember(t.date,date);
         
         iDif = posMax(iExist) < t.tests_positive;
         if any(iDif)
             statNeg(iExist(iDif)+length(date)-length(iExist),ii) = 1;
         end
         iDif = posMax(iExist) > t.tests_positive;
         if any(iDif)
             stat(iExist(iDif)+length(date)-length(iExist),ii) = 1;
             posMax(iExist) = max([posMax(iExist),t.tests_positive],[],2);
             posMin(iExist) = min([posMin(iExist),t.tests_positive],[],2);
         end
     end
end
     
%%    

figure;
plot(-length(date):-1,mean(stat,2))
xlim([-50 -1])
set(gca,'XTick',[-50:5:-5,-1])
title('ההסתברות לתיקון חיוביים בדיעבד')
xlabel('היום בו בוצע התיקון ביחס לפרסום')
ylabel('שיעור המקרים שתוקנו')
box off
grid on
grid minor
ylim([0 1])

figure;
line([t.date(end) t.date(end)],[0 150],'color','k','linestyle','--')
hold on
plot(date,posMax-posMin)
plot(date,mediumMax-mediumMin)
plot(date,hardMax-hardMin)
plot(date,deathMax-deathMin)
xlim([datetime(2020,7,1) date(end)])
legend('תחילת הסקר','קל','בינוני','קשה','נפטר')
grid on
ylabel('גודל מקסימלי של התיקון לאחור')
title('תיקון נתונים לאחור לפי תאריך ומצב החולה')


figure;
plot(-length(date):-1,mean(statNeg,2))
xlim([-50 -1])
set(gca,'XTick',[-50:5:-5,-1])
title('ההסתברות לתיקון נפטרים בדיעבד')
xlabel('היום בו בוצע התיקון ביחס לפרסום')
ylabel('שיעור המקרים שתוקנו')
box off
grid on
grid minor
ylim([0 1])