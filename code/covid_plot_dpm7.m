function covid_plot_dpm7(criterionDays,large)
    
if ~exist('large','var')
    large = true;
end

if ~exist('criterionDays','var')
    criterionDays = 7;
end
saveFigs = false;
listName = 'data/Israel/dashboard_timeseries.csv';
cd ~/covid-19-israel-matlab/
myCountry = 'Israel';
nCountries = 20;

[dataMatrix] = readCoronaData('deaths');
[~,timeVector,mergedData] = processCoronaData(dataMatrix);
% iBahamas = find(ismember(mergedData(:,1),{'Bahamas','Malta','Guyana'}));

pop = readtable('data/population.csv','delimiter',',');
mergedData(~ismember(mergedData(:,1),pop.Country_orDependency_),:) = [];
[~,idx1] = ismember(mergedData(:,1),pop.Country_orDependency_);
pop = pop(idx1,:);
if large
    small = pop.Population_2020_ < 1000000;
    mergedData(small,:) = [];
end
[esp,~,date] = covid_spain;
[~,idxEsp] = ismember(date,timeVector);
iEsp = find(ismember(mergedData(:,1),'Spain'));
mergedData{iEsp,2}(idxEsp(1:end-7)) = sum(esp(1:end-7,:),2);

criterion = 'ddpm';
mustHave = 'Israel';
ymax = 10;
cd ~/covid-19-israel-matlab/

% showDateEvery = 7; % days
warning off

for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
warning on
mergedData(~ismember(mergedData(:,1),pop.Country_orDependency_),:) = [];
deaths = nan(length(timeVector),length(mergedData));
countryName = {'אפגניסטן';'אלבניה';'''אלג''יריה''';'אנדורה';'אנגולה';'אנטיגואה וברבודה';'ארגנטינה';'ארמניה';'אוֹסטְרַלִיָה';'אוֹסְטְרֵיָה';'''אזרבייג''ן''';'איי בהאמה';'בחריין';'בנגלדש';'ברבדוס';'בלארוס';'בלגיה';'בליז';'בנין';'בהוטן';'בוליביה';'בוסניה';'בוצואנה';'ברזיל';'ברוניי';'בולגריה';'בורקינה פאסו';'בורמה';'בורונדי';'קאבו ורדה';'קמבודיה';'קמרון';'קנדה';'הרפובליקה המרכז - אפריקאית';'צ''אד';['צ''','ילה'];'חרסינה';'קולומביה';'קונגו (בראזוויל)';'קונגו (קינשאסה)';'קוסטה ריקה';'חוף השנהב';'קרואטיה';'קובה';'קַפרִיסִין';['צ','''כיה'];'דנמרק';'ג''יבוטי';'דומיניקה';'הרפובליקה הדומיניקנית';'אקוודור';'מִצְרַיִם';'אל סלבדור';'גיניאה המשוונית';'אריתריאה';'אסטוניה';'Eswatini';'אֶתִיוֹפִּיָה';'''פיג''י''';'פינלנד';'צרפת';'גבון';'גמביה';'''ג''ורג''יה''';'גֶרמָנִיָה';'גאנה';'יָוָן';'גרנדה';'גואטמלה';'גינאה';'גינאה ביסאו';'גיאנה';'האיטי';'הכס הקדוש';'הונדורס';'הונגריה';'אִיסלַנד';'הוֹדוּ';'אִינדוֹנֵזִיָה';'איראן';'עִירַאק';'אירלנד';'ישראל';'אִיטַלִיָה';'ג''מייקה';'יפן';'ירדן';'קזחסטן';'קניה';'קוריאה, דרום';'קוסובו';'כווית';'קירגיזסטן';'לאוס';'לטביה';'לבנון';'ליבריה';'לוב';'ליכטנשטיין';'ליטא';'לוקסמבורג';'מדגסקר';'מלזיה';'מלדיבים';'מאלי';'מלטה';'מאוריטניה';'מאוריציוס';'מקסיקו';'מולדובה';'מונקו';'מונגוליה';'מונטנגרו';'מָרוֹקוֹ';'מוזמביק';'נמיביה';'נפאל';'הולנד';'ניו זילנד';'ניקרגואה';'''ניז''ר''';'ניגריה';'צ. מקדוניה';'נורווגיה';'עומאן';'פקיסטן';'פנמה';'פפואה גינאה החדשה';'פרגוואי';'פרו';'פיליפינים';'פּוֹלִין';'פּוֹרטוּגָל';'קטאר';'רומניה';'רוּסִיָה';'רואנדה';'סנט לוסיה';'סן מרינו';'ערב הסעודית';'סנגל';'סרביה';'סיישל';'סיירה לאון';'סינגפור';'סלובקיה';'סלובניה';'סומליה';'דרום אפריקה';'ספרד';'סרי לנקה';'סודן';'סורינאם';'שבדיה';'שוויץ';'סוּריָה';'טייוואן *';'טנזניה';'תאילנד';'טימור-לסטה';'ללכת';'טרינידד וטובגו';'תוניסיה';'טורקיה';'ארה"ב';'אוגנדה';'אוקראינה';'איחוד האמירויות הערביות';'הממלכה המאוחדת';'אורוגוואי';'אוזבקיסטן';'ונצואלה';'וייטנאם';'הגדה המערבית ועזה';'זמביה'};
if large
    countryName(small) = [];
end
for iCou = 1:length(mergedData)
    deaths(1:length(timeVector),iCou) = mergedData{iCou,2};
end
%%
[~,idx] = ismember(mergedData(:,1),pop.Country_orDependency_);
mil = pop.Population_2020_(idx)'/10^6;
[~,iMustHave] = ismember(mustHave,mergedData(:,1));
iMustHave(isempty(iMustHave)) = [];
if ~exist('dashboard','var')
    dashboard = true;
end
if dashboard
    listD = readtable('data/Israel/dashboard_timeseries.csv');
    listD.CountDeath(isnan(listD.CountDeath)) = 0;
    [isDate,iDate] = ismember(listD.date,timeVector);
    deaths(iDate(isDate),iMustHave) = listD.CountDeath(isDate);
    deaths(iDate(isDate),iMustHave) = cumsum(deaths(iDate(isDate),iMustHave));
end

y = [deaths(1,:);diff(deaths)]./mil;
isNeg = y < 0;
y(isNeg) = nan;
isJump = y > 20;
if ~dashboard
    isJump(211,83) = true;  % Israel's little jump
end
jump = nan(size(y));
jump(isJump) = y(isJump);
y(isJump) = nan;
tit = {'מתים למליון ליום, דירוג לפי ממוצע בשבוע האחרון','יש לכפול ב 9.2 לקבלת מתים ליום בישראל'};

y(y < 0) = 0;
% y = movmean(y,[6 0],'omitnan');
y = movmean(y,[3 3],'omitnan');
if exist('isNeg','var')
    y(isNeg) = nan;
    %y(isJump) = jump(isJump);
end
y(end,isnan(y(end,:))) = y(end-1,isnan(y(end,:)));
[means,order] = sort(nanmean(y(end-criterionDays+1:end,:),1),'descend'); % most deaths
[~,iMustHave] = ismember(iMustHave,order);
y = y(:,order);
%%
fig = figure('units','normalized','position',[0,0,0.5,0.5]);
hAll = plot(timeVector,y,'linewidth',1,'color',[0.65 0.65 0.65]);
hold on
h = plot(timeVector,y(:,11:20),'color',[0.65 0.65 0.65],'linewidth',1,'marker','.','MarkerSize',8);
h = [plot(timeVector,y(:,1:10),'linewidth',1,'marker','.','MarkerSize',8);h];
co = hsv(10);
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
for ic = 1:10
    h(ic).Color = co(ic,:);
end
if ~isempty(iMustHave)
    for im = 1:length(iMustHave)
        hm(im) = plot(timeVector,y(:,iMustHave(im)),'linewidth',1,'marker','.','MarkerSize',8);
        hm(im).Color = [0 0 0];
        if iMustHave(im) <= nCountries
            h(iMustHave(im)).Color = [0 0 0];
        end
    end
else
    hm = [];
end
ax = ancestor(hAll, 'axes');
ax{1}.YAxis.Exponent = 0;
xlim([datetime(2020,3,1) timeVector(end)])
box off
grid on
% xlabel('Weeks')
title(tit)
if ~exist('ymax','var')
    ymax = max(y(end,:))*1.1;
end
ylim([0 ymax])
yt = fliplr(ymax/nCountries:ymax/20:ymax);
x = size(y,1);
for iAnn = 1:nCountries
    text(x,yt(iAnn),countryName{order(iAnn)},...
        'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
end
if ~isempty(hm) && any(iMustHave > nCountries)
    if length(hm) == 1
        ya = 0;
    else
        ya = y(end,iMustHave);
    end
    for im = 1:length(hm)
        io = order(iMustHave(im));
        text(x,ya(im),[countryName{io},'(',num2str(iMustHave(im)),')'],...
            'FontSize',10,'Color',hm(im).Color,'FontWeight','bold');
    end
end
ylabel('מתים למליון')
set(gcf,'Color','w')
xlabel('דירוג המדינות (מעל מליון איש) בהן הקורונה קטלנית ביותר כרגע')

figure
for iAnn = 1:nCountries
    plot(iAnn,means(iAnn)*7,'*','Color',h(iAnn).Color)
    hold on
    ht = text(iAnn+0.5,means(iAnn)*7,countryName{order(iAnn)},...
        'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
    set(ht,'Rotation',30);
end
% ,countryName{order(iAnn)},...
%         'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');