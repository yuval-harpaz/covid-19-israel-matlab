[~,~] = system('wget -O tmp.json https://covidtrackerapi.bsg.ox.ac.uk/api/v2/stringency/date-range/2020-02-15/2020-11-11');
fid = fopen('tmp.json','r');
json = fread(fid);
fclose(fid)
json = jsondecode(native2unicode(json)');
dates = fieldnames(json.data);
date = datetime(strrep(strrep(dates,'x',''),'_','-'));
for ii = 1:length(date)
    dat = eval(['json.data.',dates{ii},'.ISR']);
    if isempty(dat.deaths)
        deaths(ii,1) = nan;
    else
        deaths(ii,1) = dat.deaths;
    end
    if isempty(dat.confirmed)
        confirmed(ii,1) = nan;
    else
        confirmed(ii,1) = dat.confirmed;
    end
    stringency(ii,1) = dat.stringency;
end

t = table(date,stringency,confirmed,deaths);
t.deaths(ismember(t.date,datetime(2020,8,20))) = nan;


mob = readtable('~/Downloads/Region_Mobility_Report_CSVs/2020_IL_Region_Mobility_Report.csv');
mob = mob(1:find(contains(mob.sub_region_1,'Center District'),1)-1,8:end);
[isx,idx] = ismember(t.date,mob.date);
figure;
fill([t.date;flipud(t.date)],[t.stringency;-flipud(t.stringency)],[0.9,0.9,0.9],'linestyle','none')
hold on
colorset;
plot(mob.date,movmedian(mob{:,2:end},[3 3]))
plot(t.date(2:end),diff(t.deaths),'k')
legend('מדד צעדי מנע של אוקספורד','חנויות','מכולות','פארקים','תחנות אוטובוס','עבודה','בית','תמותה')
title('השוואה בין המדדים של אוקספורד לגוגל לחומרת צעדי המנע בישראל')
grid on
box off
set(gcf,'Color','w')
