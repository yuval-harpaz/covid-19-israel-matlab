function covid_update_html(isr)
% show the worst countries by different criteria
cd ~/covid-19_data_analysis/
% highest = dir(['archive/highest*',datestr(datetime-1,'dd_mm_yyyy'),'*']);
% if isempty(highest)
%     error('run covid_news');
% end
% realigned = dir(['archive/realigned*',datestr(datetime-1,'dd_mm_yyyy'),'*']);
% if isempty(realigned)
%     error('run covid_realigned');
% end
yesterdate = datestr(datetime-1,'dd.mm.yyyy');
% highest countries
fName = 'docs/highest_countries.html'
fid = fopen(fName,'r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');
iDate = findstr(txt,'2020');
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
iDate = findstr(txt,'2020');
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
iDate = findstr(txt,'2020');
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
iDate = findstr(txt,'2020');
txt(iDate-6:iDate+3) = yesterdate;
counter1 = findstr(txt,'יום ממוות אחד');
counter0 = findstr(txt,'כיום,');
count = datenum(datetime('today'))-datenum(datetime('22-Jan-2020'))-65;
txt = [txt(1:counter0-1),'כיום, ',str(count),' ',txt(counter1:end)];
idx = findstr(txt,'מצב התמותה');
med = median(diff(isr.Deceased(end-4:end)));
% medPrev = median(diff(isr.Deceased(end-9:end-4)));
ins = ['מצב התמותה - ', '(בחמשת הימים האחרונים)',' כ ',str(med),' נפטרים ליום ',];
txt = [txt(1:idx-1),ins,txt(idx+find(ismember(txt(idx:end),'<'),1)-1:end)];

idx = findstr(txt,'מצב המונשמים');
med = median(diff(isr.Vent(end-4:end)));
% medPrev = median(diff(isr.Vent(end-9:end-4)));
if med >= 0
    ins = ['מצב המונשמים - ', '(בחמשת הימים האחרונים)',' כל יום יש כ ',str(med),' מונשמים יותר  ',];
else
    ins = ['מצב המונשמים - ', '(בחמשת הימים האחרונים)',' כל יום יש כ ',str(-med),' מונשמים פחות',];
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
