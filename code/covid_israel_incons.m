
cd ~/covid-19_data_analysis/
records = readtable('data/Israel/corona_hospitalization_ver_001.csv');

list = readtable('data/Israel/Israel_ministry_of_health.csv');

figure;
subplot(2,2,1)
plot(records.date,records.hospitalized,'k','linewidth',2)
hold on
plot(list.date,list.hospitalized,'b','linewidth',2)
title('מאושפזים')
ylabel('patients')
grid on
legend('Timna','Telegram')
subplot(2,2,3)
plot(records.date,records.severe,'k','linewidth',2)
hold on
plot(list.date,list.severe,'b','linewidth',2)
title('בינוני')
ylabel('patients')
grid on
subplot(2,2,4)
plot(records.date,records.critical,'k','linewidth',2)
hold on
plot(list.date,list.critical,'b','linewidth',2)
title('קשה')
ylabel('patients')
grid on
mild = list.hospitalized - list.severe - list.critical;
subplot(2,2,2)
plot(records.date,records.mild,'k','linewidth',2)
hold on
plot(list.date,mild,'b','linewidth',2)
title('קל')
ylabel('patients')
grid on



% 
% figure;
% idx = ~isnan(list.on_ventilator);
% plot(list.date(idx),list.on_ventilator(idx),'r')
% hold on
% v =  cellfun(@(x) str2num(strrep(x,'<15','0')),t.on_ventilator);
% plot(t.date,v,'g')
% figure;
% idx = ~isnan(list.critical);
% plot(list.date(idx),list.critical(idx),'r')
% hold on
% c =  cellfun(@(x) str2num(strrep(x,'<15','0')),t.critical);
% plot(t.date,c,'g')
% figure;
% idx = ~isnan(list.severe);
% plot(list.date(idx),list.severe(idx),'r')
% hold on
% plot(t.date,cellfun(@(x) str2num(strrep(strrep(x,'NULL','0'),'<15','0')),t.severe),'g')
% figure;
% 
% 
% for ii = 1:length(t.Properties.VariableNames)
%     if is