function covid_update_html
% show the worst countries by different criteria
cd ~/covid-19_data_analysis/

list = readtable('data/Israel/Israel_ministry_of_health.csv');
yesterdate = datestr(datetime-1,'dd.mm.yyyy');
% highest countries
fName = 'docs/highest_countries.html';
fid = fopen(fName,'r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
iDate = strfind(txt,'2020');
txt(iDate-6:iDate+3) = yesterdate;
fid = fopen(fName,'w');
fwrite(fid,txt);
fclose(fid);
% realigned
fName = 'docs/realigned.html';
fid = fopen(fName,'r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
iDate = strfind(txt,'2020');
txt(iDate-6:iDate+3) = yesterdate;
fid = fopen(fName,'w');
fwrite(fid,txt);
fclose(fid);
% index
fName = 'docs/README.md';
fid = fopen(fName,'r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
iDate = strfind(txt,'2020');
txt(iDate-6:iDate+3) = yesterdate;
fid = fopen(fName,'w');
fwrite(fid,txt);
fclose(fid);
% Israel
fName = 'docs/myCountry.html';
fid = fopen(fName,'r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
iDate = strfind(txt,'2020');
txt(iDate-6:iDate+3) = yesterdate;
counter1 = strfind(txt,'יום ממוות אחד');
counter0 = strfind(txt,'כיום,');
count = datenum(datetime('today'))-datenum(datetime('22-Jan-2020'))-65;
txt = [txt(1:counter0-1),'כיום, ',str(count),' ',txt(counter1:end)];
idx = strfind(txt,'מצב התמותה');
daten = datenum(list.date);
daten = daten-daten(1);
last5 = find(daten > daten(end)-4,1);
x = daten(last5:end);
x = [ones(length(x),1) x];
y = list.deceased(last5:end);
b = x\y;

ins = ['מצב התמותה - ', '(בחמשת הימים האחרונים)',' כ ',str(round(b(2))),' נפטרים ליום ',];
txt = [txt(1:idx-1),ins,txt(idx+find(ismember(txt(idx:end),'<'),1)-1:end)];

idx = strfind(txt,'מצב המונשמים');
y = list.on_ventilator(last5:end);
b = x\y;
mun5 = round(b(2));

if mun5 >= 0
    ins = ['מצב המונשמים - ', '(בחמשת הימים האחרונים)',' כל יום יש כ ',str(mun5),' מונשמים יותר  ',];
else
    ins = ['מצב המונשמים - ', '(בחמשת הימים האחרונים)',' כל יום יש כ ',str(-mun5),' מונשמים פחות',];
end
txt = [txt(1:idx-1),ins,txt(idx+find(ismember(txt(idx:end),'<'),1)-1:end)];

fid = fopen(fName,'w');
fwrite(fid,unicode2native(txt));
fclose(fid);
%% push
!git add -A
!git commit -m "daily update"
!git push
%% old
