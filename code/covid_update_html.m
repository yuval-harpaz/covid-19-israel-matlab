function covid_update_html
cd ~/covid-19-israel-matlab/
list = readtable('data/Israel/dashboard_timeseries.csv');
fName = 'docs/README.md';
fid = fopen(fName,'r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
iDate = strfind(txt,'2022');
txt(iDate-6:iDate+3) = datestr(list.date(end),'dd.mm.yyyy');
fid = fopen(fName,'w');
fwrite(fid,txt);
fclose(fid);
fName = 'docs/myCountry.html';
fid = fopen(fName,'r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
iDate = strfind(txt,'2022');
txt(iDate-6:iDate+3) = datestr(list.date(end),'dd.mm.yyyy');
idx = strfind(txt,'מצב התמותה');
 list.CountDeath(isnan(list.CountDeath)) = 0;
y = cumsum(list.CountDeath);
y = y(end-7:end-1);
x = (1:7)';
x = [ones(length(x),1) x];
b = x\y;
ins = ['מצב התמותה - ', '(בשבעת הימים האחרונים)',' כ ',str(round(b(2))),' נפטרים ליום ',];
txt = [txt(1:idx-1),ins,txt(idx+find(ismember(txt(idx:end),'<'),1)-1:end)];
idx = strfind(txt,'מצב המונשמים');
list.CountBreath(isnan(list.CountBreath)) = 0;
y = list.CountBreath(end-7:end-1);
b = x\y;
mun7 = round(b(2));
if mun7 >= 0
    ins = ['מצב המונשמים - ', '(בשבעת הימים האחרונים)',' כל יום יש כ ',str(mun7),' מונשמים יותר  ',];
else
    ins = ['מצב המונשמים - ', '(בשבעת הימים האחרונים)',' כל יום יש כ ',str(-mun7),' מונשמים פחות',];
end
txt = [txt(1:idx-1),ins,txt(idx+find(ismember(txt(idx:end),'<'),1)-1:end)];
fid = fopen(fName,'w');
fwrite(fid,unicode2native(txt));
fclose(fid);
%% push
[~,~] = system('git add -A');
[~,~] = system('git commit -m "daily update"');
[~,~] = system('git pull');
[~,~] = system('git push');

