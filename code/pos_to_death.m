
cd ~/covid-19-israel-matlab/
% % [~,msg] = system('git log --oneline > tmp.log')
% !git log --pretty=tformat:"%H" --shortstat > tmp.log
% https://github.com/yuval-harpaz/covid-19-israel-matlab/commit/8a10e582934e76006bcd987fe43142b9444e9737#diff-43a113abbb98a0dff48e96c4858cdc9a56fe30931c08459c6fdd1281c530ca2d

log = importdata('tmp.log');
log = log(~contains(log,' '));
% log = log(find(contains(log,'8a10e582934e')):end);
log = flipud(log(1:find(contains(log,'8a10e582934e'))));
%%
ageGroup = {'<65';'65-74';'75-84';'85+'};
vars = {'sum_65','N_65';'sum_65_74','N_65_74';'sum_75_84','N_75_84';'sum_85','N_85'};
%%
sum_65=0;N_65=0;sum_65_74=0;N_65_74=0;sum_75_84=0;N_75_84=0;sum_85=0;N_85=0;date=datetime('31-Dec-2020 19:03:00');
pos2death = table(date,sum_65,N_65,sum_65_74,N_65_74,sum_75_84,N_75_84,sum_85,N_85);
hosp2death = pos2death;
warning off
for ii = 1:length(log)
    [~,msg] = system(['wget -O tmp.csv https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/',...
        log{ii},'/data/Israel/dashboard_age_gen.csv']);
    ag = readtable('tmp.csv');
    pos2death.date(ii,1) = ag.date(end);
    hosp2death.date(ii,1) = ag.date(end);
    [~,msg] = system(['wget -O tmp.csv https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/',...
        log{ii},'/data/Israel/deaths.csv']);
    t = readtable('tmp.csv');
    t = t(1:end-1,:);
    for iVar = 1:4
        idx = ismember(t.age_group,ageGroup{iVar}) &...
            t.Time_between_positive_and_death >= 0 & t.Length_of_hospitalization >= 0 &...
            t.Time_between_positive_and_death < 100 & t.Length_of_hospitalization < 100;
        eval(['pos2death.',vars{iVar,1},'(ii,1) = sum(t.Time_between_positive_and_death(idx));']);
        eval(['pos2death.',vars{iVar,2},'(ii,1) = length(t.Time_between_positive_and_death(idx));']);
        eval(['hosp2death.',vars{iVar,1},'(ii,1) = sum(t.Length_of_hospitalization(idx));']);
        eval(['hosp2death.',vars{iVar,2},'(ii,1) = length(t.Length_of_hospitalization(idx));']);
    end
   IEprog(ii)
end
mon = unique(month(pos2death.date));
mon(mon > month(datetime('today'))) = []; 
row = 1; % find(dateshift(pos2death.date,'start','month') == datetime(2020,12,1),1,'last');
for iMon = 1:length(mon)
    row(iMon+1,1) = find(dateshift(pos2death.date,'start','month') == datetime(2021,mon(iMon),1),1,'last');
end
clear age;
for iRow = 1:length(row)
    if iRow == 1
        alll(iRow,1) = sum(pos2death{row(iRow),2:2:8})/sum(pos2death{row(iRow),3:2:9});
        alll(iRow,2) = sum(hosp2death{row(iRow),2:2:8})/sum(hosp2death{row(iRow),3:2:9});
        for iAge = 1:4
            age{iAge}(iRow,1) = pos2death{row(iRow),iAge*2}/pos2death{row(iRow),iAge*2+1};
        	age{iAge}(iRow,2) = hosp2death{row(iRow),iAge*2}/hosp2death{row(iRow),iAge*2+1};
        end
    else
        alll(iRow,1) = (sum(pos2death{row(iRow),2:2:8})-sum(pos2death{row(iRow-1),2:2:8}))...
            /(sum(pos2death{row(iRow),3:2:9})-sum(pos2death{row(iRow-1),3:2:9}));
        alll(iRow,2) = (sum(hosp2death{row(iRow),2:2:8})-sum(hosp2death{row(iRow-1),2:2:8}))...
            /(sum(hosp2death{row(iRow),3:2:9})-sum(hosp2death{row(iRow-1),3:2:9}));
        for iAge = 1:4
            age{iAge}(iRow,1) = (pos2death{row(iRow),iAge*2}-pos2death{row(iRow-1),iAge*2})...
                /(pos2death{row(iRow),iAge*2+1}-pos2death{row(iRow-1),iAge*2+1});
        	age{iAge}(iRow,2) = (hosp2death{row(iRow),iAge*2}-hosp2death{row(iRow-1),iAge*2})...
                /(hosp2death{row(iRow),iAge*2+1}-hosp2death{row(iRow-1),iAge*2+1});
        end
    end
end
%%     
age{end+1} = alll;
figure;
for ii = 1:length(age)
    subplot(1,length(age),ii)
    bar(age{ii})
    if ii == 1
        legend('positive to death','hospitalization to death')
    end
    set(gca,'XTickLabel',{'2020','Jan','Feb','Mar','Apr'},'ygrid','on')
    ylim([0 100])
    if ii < length(age)
        title(ageGroup{ii})
    else
        title('All ages')
    end
    ylabel('days')
end
% 
% figure;
% line([t.date(end) t.date(end)],[0 150],'color','k','linestyle','--')
% hold on
% plot(date,easyMax-easyMin)
% plot(date,mediumMax-mediumMin)
% plot(date,hardMax-hardMin)
% plot(date,deathMax-deathMin)
% xlim([datetime(2020,7,1) date(end)])
% legend('תחילת הסקר','קל','בינוני','קשה','נפטר')
% grid on
% ylabel('גודל מקסימלי של התיקון לאחור')
% title('תיקון נתונים לאחור לפי תאריך ומצב החולה')
% 
% 
% figure;
% plot(-length(date):-1,mean(statNeg,2))
% xlim([-50 -1])
% set(gca,'XTick',[-50:5:-5,-1])
% title('ההסתברות לתיקון נפטרים בדיעבד')
% xlabel('היום בו בוצע התיקון ביחס לפרסום')
% ylabel('שיעור המקרים שתוקנו')
% box off
% grid on
% grid minor
% ylim([0 1])