function fig = covid_plot(mergedData,timeVector,nCountries,criterion,criterionDays,mustHave,ymax,dashboard,heb)
cd ~/covid-19-israel-matlab/
if ~exist('heb','var')
    heb = true;
end
% showDateEvery = 7; % days
warning off
pop = readtable('data/population.csv','delimiter',',');
for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
warning on
mergedData(~ismember(mergedData(:,1),pop.Country_orDependency_),:) = [];
deaths = nan(length(timeVector),length(mergedData));
if heb
    countryName = {'אפגניסטן';'אלבניה';'''אלג''יריה''';'אנדורה';'אנגולה';'אנטיגואה וברבודה';'ארגנטינה';'אַרְמֶנִיָה';'אוֹסטְרַלִיָה';'אוֹסְטְרֵיָה';'''אזרבייג''ן''';'איי בהאמה';'בחריין';'בנגלדש';'ברבדוס';'בלארוס';'בלגיה';'בליז';'בנין';'בהוטן';'בוליביה';'בוסניה והרצגובינה';'בוצואנה';'ברזיל';'ברוניי';'בולגריה';'בורקינה פאסו';'בורמה';'בורונדי';'קאבו ורדה';'קמבודיה';'קמרון';'קנדה';'הרפובליקה המרכז - אפריקאית';'צ''אד';['צ''','ילה'];'חרסינה';'קולומביה';'קונגו (בראזוויל)';'קונגו (קינשאסה)';'קוסטה ריקה';'חוף השנהב';'קרואטיה';'קובה';'קַפרִיסִין';'''צ''כיה''';'דנמרק';'ג''יבוטי';'דומיניקה';'הרפובליקה הדומיניקנית';'אקוודור';'מִצְרַיִם';'אל סלבדור';'גיניאה המשוונית';'אריתריאה';'אסטוניה';'Eswatini';'אֶתִיוֹפִּיָה';'''פיג''י''';'פינלנד';'צָרְפַת';'גבון';'גמביה';'''ג''ורג''יה''';'גֶרמָנִיָה';'גאנה';'יָוָן';'גרנדה';'גואטמלה';'גינאה';'גינאה ביסאו';'גיאנה';'האיטי';'הכס הקדוש';'הונדורס';'הונגריה';'אִיסלַנד';'הוֹדוּ';'אִינדוֹנֵזִיָה';'איראן';'עִירַאק';'אירלנד';'ישראל';'אִיטַלִיָה';'ג''מייקה';'יפן';'יַרדֵן';'קזחסטן';'קניה';'קוריאה, דרום';'קוסובו';'כווית';'קירגיזסטן';'לאוס';'לטביה';'לבנון';'ליבריה';'לוב';'ליכטנשטיין';'ליטא';'לוקסמבורג';'מדגסקר';'מלזיה';'מלדיבים';'מאלי';'מלטה';'מאוריטניה';'מאוריציוס';'מקסיקו';'מולדובה';'מונקו';'מונגוליה';'מונטנגרו';'מָרוֹקוֹ';'מוזמביק';'נמיביה';'נפאל';'הולנד';'ניו זילנד';'ניקרגואה';'''ניז''ר''';'ניגריה';'צפון מקדוניה';'נורווגיה';'עומאן';'פקיסטן';'פנמה';'פפואה גינאה החדשה';'פרגוואי';'פרו';'פיליפינים';'פּוֹלִין';'פּוֹרטוּגָל';'קטאר';'רומניה';'רוּסִיָה';'רואנדה';'סנט לוסיה';'סן מרינו';'ערב הסעודית';'סנגל';'סרביה';'סיישל';'סיירה לאון';'סינגפור';'סלובקיה';'סלובניה';'סומליה';'דרום אפריקה';'ספרד';'סרי לנקה';'סודן';'סורינאם';'שבדיה';'שוויץ';'סוּריָה';'טייוואן *';'טנזניה';'תאילנד';'טימור-לסטה';'ללכת';'טרינידד וטובגו';'תוניסיה';'טורקיה';'ארה"ב';'אוגנדה';'אוקראינה';'איחוד האמירויות הערביות';'הממלכה המאוחדת';'אורוגוואי';'אוזבקיסטן';'ונצואלה';'וייטנאם';'הגדה המערבית ועזה';'זמביה'};
else
    countryName = mergedData(:,1);
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

switch criterion
    case 'd'
        y = deaths;
        tit = 'Deaths';
    case 'dpm'
        y = deaths./mil;
        tit = 'Deaths per million';
    case 'dd'
        y = [deaths(1,:);diff(deaths)];
        tit = 'Daily deaths';
    case 'ddpm'
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
        tit = 'Daily deaths per million';
end
y(y < 0) = 0;
y = movmean(y,[6 0],'omitnan');
if exist('isNeg','var')
    y(isNeg) = nan;
    %y(isJump) = jump(isJump);
end

[~,order] = sort(nanmean(y(end-criterionDays+1:end,:),1),'descend'); % most deaths
[~,iMustHave] = ismember(iMustHave,order);
y = y(:,order);
fig = figure('units','normalized','position',[0,0,0.5,0.5]);
hAll = plot(timeVector,y,'linewidth',1,'color',[0.65 0.65 0.65]);
hold on
h = plot(timeVector,y(:,1:nCountries),'linewidth',1,'marker','.','MarkerSize',8);
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
xlabel('Weeks')
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

