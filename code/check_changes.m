
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
    t.CountHardStatus(isnan(t.CountHardStatus)) = 0;
    t.CountDeath(isnan(t.CountDeath)) = 0;
    t.CountEasyStatus(isnan(t.CountEasyStatus)) = 0;
    t.CountMediumStatus(isnan(t.CountMediumStatus)) = 0;
    t = t(1:end-1,:);
     if ii == 1
        date = t.date;
        hardMax = t.CountHardStatus;
        hardMin = t.CountHardStatus;
        mediumMax = t.CountMediumStatus;
        mediumMin = t.CountMediumStatus;
        easyMax = t.CountEasyStatus;
        easyMin = t.CountEasyStatus;
        deathMax = t.CountDeath;
        deathMin = t.CountDeath;
        stat = zeros(height(t),length(log));
        statNeg = zeros(height(t),length(log));
     else
         [~,iExist] = ismember(t.date,date);
         
         iDif = easyMax(iExist)<t.CountEasyStatus;
         if any(iDif)
             statNeg(iExist(iDif)+length(date)-length(iExist),ii) = 1;
         end
         
         
         hardMax(iExist) = max([hardMax(iExist),t.CountHardStatus],[],2);
         hardMin(iExist) = min([hardMin(iExist),t.CountHardStatus],[],2);
         mediumMax(iExist) = max([mediumMax(iExist),t.CountMediumStatus],[],2);
         mediumMin(iExist) = min([mediumMin(iExist),t.CountMediumStatus],[],2);
         easyMax(iExist) = max([easyMax(iExist),t.CountEasyStatus],[],2);
         easyMin(iExist) = min([easyMin(iExist),t.CountEasyStatus],[],2);
         iDif = deathMax(iExist)>t.CountDeath;
         if any(iDif)
             stat(iExist(iDif)+length(date)-length(iExist),ii) = 1;
         end
         
         deathMax(iExist) = max([deathMax(iExist),t.CountDeath],[],2);
         deathMin(iExist) = min([deathMin(iExist),t.CountDeath],[],2);
         
     end
end
     
%%        
figure;
plot(-length(date):-1,mean(stat,2))
xlim([-50 -1])
set(gca,'XTick',[-50:5:-5,-1])
title('ההסתברות לתיקון נפטרים בדיעבד')
xlabel('היום בו בוצע התיקון ביחס לפרסום')
ylabel('שיעור המקרים שתוקנו')
box off
grid on
grid minor
ylim([0 1])

figure;
line([t.date(end) t.date(end)],[0 150],'color','k','linestyle','--')
hold on
plot(date,easyMax-easyMin)
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