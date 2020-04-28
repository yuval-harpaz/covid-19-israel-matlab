

system('telegram-cli -W --json -e "history @MOHreport 100" | tee tcoutput.txt');
fid = fopen('~/tcoutput.txt');
txt = fread(fid);
fclose(fid);
txtStr = native2unicode(txt');
txtStr = strrep(txtStr,[27,91,75,62,32,13],'');
strfind(txtStr,'_חדש_')
% iGT = ismember(txtStr,'>');
% iGT(strfind(txtStr,'>>>')) = false;
% iGT(strfind(txtStr,'>>>')+1) = false;
% iGT(strfind(txtStr,'>>>')+2) = false;
% iGT(strfind(txtStr,'>>')) = false;
% iGT(strfind(txtStr,'>>')+1) = false;
% iGT = find(iGT);
% jsonData = jsondecode(txtStr(iGT(1)+6:iGT(2)-2));
% for ii = 1:length(jsonData)
%     
%%
list = readtable('data/Israel/Israel_ministry_of_health.csv');

toPlot = {'hospitalized_xlsx','critical','deceased'};
dif = [false;false;true];
figure;
for iLine = 1:length(toPlot)
    x = eval(['list.',toPlot{iLine},';']);
    idx = find(~isnan(x));
    x = x(idx);
    if dif(iLine)
        x = [0;diff(x)];
    end
    plot(list.date(idx),x);
    hold on
end
legend(toPlot)

txt = 

xlsx = dateshift(list.date,'end','day')-list.date == duration([0,0,1]);
figure;
plot(list.date(xlsx),list.deceased(xlsx))
hold on
plot(list.date(~xlsx),list.deceased(~xlsx))
plot(list.date(xlsx),list.critical(xlsx))
plot(list.date(~xlsx),list.critical(~xlsx))

days = unique(dateshift(list.date,'start','day'));
for iDay = 1:length(days)
    dec(iDay,1) = nanmax(list.deceased(ismember(dateshift(list.date,'start','day'),days(iDay))));
    cri(iDay,1) = nanmax(list.critical(ismember(dateshift(list.date,'start','day'),days(iDay))));
end
dec7 = dec(8:end)-dec(1:end-7);
figure;plot(days,[cri,dec])
hold on
plot(days(1:end-7),dec7,'k')

figure;
plot(days(1:end-7),cri(1:end-7)./dec7(1:end))

%%
nif = importdata('/media/innereye/1T/Docs/niftarim')';
kas = importdata('/media/innereye/1T/Docs/kashim')';
list = readtable('data/Israel/Israel_ministry_of_health.csv');
morning = list(41:end,[1,4,6]);
day = unique(dateshift(morning.date,'start','day'));
isMorn = false(height(morning),1);
for iDay = 1:length(day)
    iToday = find(dateshift(morning.date,'start','day')==day(iDay),1);
    isMorn(iToday,1)  = true;
%     dec(iDay,1) = nanmax(list.deceased(ismember(dateshift(list.date,'start','day'),days(iDay))));
%     cri(iDay,1) = nanmax(list.critical(ismember(dateshift(list.date,'start','day'),days(iDay))));
end
morning = morning(isMorn,:);