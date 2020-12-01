function [fig,timeVector,y,countryName,order] = covid_plot_heb(criterionDays,large,cum,mustHave)
if ~exist('large','var')
    large = true;
end
if ~exist('cum','var')
    cum = false;
end
if ~exist('criterionDays','var')
    criterionDays = 1;
end
if ~exist('mustHave','var')
    mustHave = 'Israel';
end
cd ~/covid-19-israel-matlab/
nCountries = 20;

[~,~] = system('wget -O tmp.csv https://covid19.who.int/WHO-COVID-19-global-data.csv');
whoData = readtable('tmp.csv');
[dataMatrix] = readCoronaData('deaths');
[~,timeVector,mergedData] = processCoronaData(dataMatrix);
pop = readtable('data/population.csv','delimiter',',');
popw = readtable('data/worldometer_data.csv');
[isx,idx] = ismember(pop.Country_orDependency_,popw.Country_Other);
pop.Population_2020_(isx) = popw.Population(idx(isx));
% replace = {
% cou = unique(whoData.Country);
% cou = strrep(cou,'United Republic of ','');
% whoData.Country = strrep(whoData.Country,'United Republic of ','');
% iii = ismember(cou,popw.Country_Other);
% cou(~iii)
mergedData(~ismember(mergedData(:,1),pop.Country_orDependency_),:) = [];
[~,idx1] = ismember(mergedData(:,1),pop.Country_orDependency_);
pop = pop(idx1,:);

if large
    small = pop.Population_2020_ < 1000000;
    mergedData(small,:) = [];
end

%% replace shitty data
[esp,~,date] = covid_spain;
[~,idxEsp] = ismember(date,timeVector);
iEsp = find(ismember(mergedData(:,1),'Spain'));
% mergedData{iEsp,2}(idxEsp(1:end-7)) = sum(esp(1:end-7,:),2);
mergedData{iEsp,2}(idxEsp) = sum(esp,2);

[bel,~,date] = covid_belgium;
[isxB,idxB] = ismember(date,timeVector);
iB = find(ismember(mergedData(:,1),'Belgium'));
lastBdifs = diff(mergedData{iB,2}(end-2:end));
mergedData{iB,2}(idxB(isxB)) = cumsum(sum(bel(isxB,:),2));

ecu = urlread('https://raw.githubusercontent.com/andrab/ecuacovid/master/datos_crudos/ecuacovid.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,ecu);
fclose(fid);
ecu = readtable('tmp.csv');
!rm tmp.*
date = datetime(2020,3,13);
date = date:date+height(ecu);
[isxEcu,idxEcu] = ismember(date,timeVector);
isxEcu = isxEcu(1:height(ecu));
idxEcu = idxEcu(1:height(ecu));
iEcu = find(ismember(mergedData(:,1),'Ecuador'));
% mergedData{iEsp,2}(idxEsp(1:end-7)) = sum(esp(1:end-7,:),2);
mergedData{iEcu,2}(idxEcu(isxEcu)) = sum(ecu{isxEcu,[5,6]},2);

per = urlread('https://raw.githubusercontent.com/krmnino/Peru_COVID19_OpenData/master/data/PER_data.csv');
fid = fopen('tmp.csv','w');
fwrite(fid,per);
fclose(fid);
per = readtable('tmp.csv');
!rm tmp.*
% criterion = 'ddpm';

% ymax = 10;
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
countryName = {'אפגניסטן';'אלבניה';'''אלג''יריה''';'אנדורה';'אנגולה';'אנטיגואה וברבודה';'ארגנטינה';'ארמניה';'אוסטרליה';'אוסטריה';'''אזרבייג''ן''';'איי בהאמה';'בחריין';'בנגלדש';'ברבדוס';'בלארוס';'בלגיה';'בליז';'בנין';'בהוטן';'בוליביה';'בוסניה';'בוצואנה';'ברזיל';'ברוניי';'בולגריה';'בורקינה פאסו';'בורמה';'בורונדי';'קאבו ורדה';'קמבודיה';'קמרון';'קנדה';'הרפובליקה המרכז - אפריקאית';'צ''אד';['צ''','ילה'];'סין';'קולומביה';'קונגו (בראזוויל)';'קונגו (קינשאסה)';'קוסטה ריקה';'חוף השנהב';'קרואטיה';'קובה';'קַפרִיסִין';['צ','''כיה'];'דנמרק';'ג''יבוטי';'דומיניקה';'הרפובליקה הדומיניקנית';'אקוודור';'מִצְרַיִם';'אל סלבדור';'גיניאה המשוונית';'אריתריאה';'אסטוניה';'Eswatini';'אֶתִיוֹפִּיָה';'''פיג''י''';'פינלנד';'צרפת';'גבון';'גמביה';'גאורגיה';'גֶרמָנִיָה';'גאנה';'יָוָן';'גרנדה';'גואטמלה';'גינאה';'גינאה ביסאו';'גיאנה';'האיטי';'הכס הקדוש';'הונדורס';'הונגריה';'אִיסלַנד';'הוֹדוּ';'אִינדוֹנֵזִיָה';'איראן';'עִירַאק';'אירלנד';'ישראל';'איטליה';'ג''מייקה';'יפן';'ירדן';'קזחסטן';'קניה';'קוריאה, דרום';'קוסובו';'כווית';'קירגיזסטן';'לאוס';'לטביה';'לבנון';'ליבריה';'לוב';'ליכטנשטיין';'ליטא';'לוקסמבורג';'מדגסקר';'מלזיה';'מלדיבים';'מאלי';'מלטה';'מאוריטניה';'מאוריציוס';'מקסיקו';'מולדובה';'מונקו';'מונגוליה';'מונטנגרו';'מָרוֹקוֹ';'מוזמביק';'נמיביה';'נפאל';'הולנד';'ניו זילנד';'ניקרגואה';'''ניז''ר''';'ניגריה';'צ. מקדוניה';'נורווגיה';'עומאן';'פקיסטן';'פנמה';'פפואה גינאה החדשה';'פרגוואי';'פרו';'פיליפינים';'פולין';'פּוֹרטוּגָל';'קטאר';'רומניה';'רוּסִיָה';'רואנדה';'סנט לוסיה';'סן מרינו';'ערב הסעודית';'סנגל';'סרביה';'סיישל';'סיירה לאון';'סינגפור';'סלובקיה';'סלובניה';'סומליה';'דרום אפריקה';'ספרד';'סרי לנקה';'סודן';'סורינאם';'שבדיה';'שוויץ';'סוּריָה';'טייוואן *';'טנזניה';'תאילנד';'טימור-לסטה';'ללכת';'טרינידד וטובגו';'תוניסיה';'טורקיה';'ארה"ב';'אוגנדה';'אוקראינה';'איחוד האמירויות הערביות';'בריטניה';'אורוגוואי';'אוזבקיסטן';'ונצואלה';'וייטנאם';'הגדה המערבית ועזה';'זמביה'};
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

if strcmp(mustHave,'Israel')
    listD = readtable('data/Israel/dashboard_timeseries.csv');
    listD.CountDeath(isnan(listD.CountDeath)) = 0;
    [isDate,iDate] = ismember(listD.date,timeVector);
    deaths(iDate(isDate),iMustHave) = listD.CountDeath(isDate);
    deaths(iDate(isDate),iMustHave) = cumsum(deaths(iDate(isDate),iMustHave));
end

if cum
    y = deaths./mil;
else
    y = [deaths(1,:);diff(deaths)]./mil;
    lastBdifs = lastBdifs./mil(iB);
end
isNeg = y < 0;
y(isNeg) = nan;
if ~cum
    isJump = [false(1,size(y,2));diff(y) > 20];
%     isJump = y > 20;
%     jump = nan(size(y));
%     jump(isJump) = y(isJump);
%     ib = ismember(mergedData(:,1),'Belgium');
%     belge = y(1:100,ib);
    y(isJump) = nan;
%     y(1:100,ib) = belge;
    iF = ismember(mergedData(:,1),'France');
    y(119,iF) = y(120,iF);
    y(end-1:end,iB) = lastBdifs;
    iM = ismember(mergedData(:,1),'Mexico');
    y(258,iM) = y(259,iM);
    iB = ismember(mergedData(:,1),'Belgium');
    y(119,iF) = y(120,iF);
end

if cum
    tit = 'מתים למליון, מצטבר';
    xl = 'דירוג המדינות (מעל מליון איש) בהן שיעור התמותה מקורונה היה גבוה ביותר במצטבר';
else
    tit = 'מתים למליון ליום, דירוג לפי ממוצע בשבוע האחרון';
    xl = 'דירוג המדינות (מעל מליון איש) בהן הקורונה קטלנית ביותר כרגע';
end
if ~large
    strrep(xl,'(מעל מליון איש) ','')
end

y(y < 0) = 0;
if ~cum
    y = movmean(y,[6 0],'omitnan');
end
if exist('isNeg','var')
    y(isNeg) = nan;
    %y(isJump) = jump(isJump);
end
y(end,isnan(y(end,:))) = y(end-1,isnan(y(end,:)));
[~,order] = sort(nanmean(y(end-criterionDays+1:end,:),1),'descend'); % most deaths
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
xlabel(xl)
countryName(:,2) = mergedData(:,1);