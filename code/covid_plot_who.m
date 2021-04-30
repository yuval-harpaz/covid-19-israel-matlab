function [fig,date,y,countryHeb,order,ht] = covid_plot_who(criterionDays,large,cum,mustHave,eng)
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
    mustHave = '';
end
if isempty(mustHave)
    mustHave = 'Israel';
end
if ~exist('eng','var')
    eng = false;
end
cd ~/covid-19-israel-matlab/
nCountries = 20;
try
    [~,~] = system('wget -O tmp.csv https://covid19.who.int/WHO-COVID-19-global-data.csv');
    whoData = readtable('tmp.csv');
    writetable(whoData,'data/who.csv','Delimiter',',','WriteVariableNames',true);
catch
    disp('NO WHO, Reading Previous!')
    whoData = readtable('who.csv');
end
date = unique(whoData.x_Date_reported);
whoCountry = unique(whoData.Country);
deaths = nan(length(date),length(whoCountry));
for iCou = 1:length(whoCountry)
    row = find(ismember(whoData.Country,whoCountry{iCou}));
    rowDate = whoData.x_Date_reported(row);
    deaths(ismember(date,rowDate),iCou) = whoData.New_deaths(row);
end

% for slovenia use J H
[dataMatrix] = readCoronaData('deaths');
[~,timeVector,mergedData] = processCoronaData(dataMatrix);
deaths(21:end-1,ismember(whoCountry,'Slovenia')) = diff(mergedData{ismember(mergedData(:,1),'Slovenia'),2}(1:length(date)-20));
popWM = readtable('data/worldometer_data.csv');

missing = {'American Samoa','';'Anguilla','';'Bolivia (Plurinational State of)','Bolivia';'Bonaire, Sint Eustatius and Saba','';'British Virgin Islands','';'Brunei Darussalam','';'Central African Republic','CAR';'Cook Islands','';'Côte d’Ivoire','Ivory Coast';'Democratic People''s Republic of Korea','';'Democratic Republic of the Congo','DRC';'Falkland Islands (Malvinas)','Falkland Islands';'Faroe Islands','Faeroe Islands';'Guam','';'Guernsey','';'Holy See','';'Iran (Islamic Republic of)','Iran';'Jersey','';'Kiribati','';'Kosovo[1]','';'Lao People''s Democratic Republic','Laos';'Marshall Islands','';'Micronesia (Federated States of)','';'Montserrat','';'Nauru','';'Niue','';'Northern Mariana Islands (Commonwealth of the)','';'Other','';'Palau','';'Pitcairn Islands','';'Puerto Rico','';'Republic of Korea','S. Korea';'Republic of Moldova','Moldova';'Russian Federation','Russia';'Saint Barthélemy','';'Saint Helena','';'Saint Kitts and Nevis','';'Saint Pierre and Miquelon','';'Saint Vincent and the Grenadines','';'Samoa','';'Syrian Arab Republic','Syria';'The United Kingdom','UK';'Tokelau','';'Tonga','';'Turkmenistan','';'Turks and Caicos Islands','';'Tuvalu','';'United Arab Emirates','UAE';'United Republic of Tanzania','';'United States Virgin Islands','';'United States of America','USA';'Venezuela (Bolivarian Republic of)','Venezuela';'Viet Nam','Vietnam';'Wallis and Futuna','';'occupied Palestinian territory, including east Jerusalem','Palestine'};
missing(cellfun(@isempty,missing(:,2)),:) = [];
[~,idx] = ismember(missing(:,1),whoCountry);
whoCountry(idx) = missing(:,2);
iMiss = ~ismember(whoCountry,popWM.Country_Other);
deaths(:,iMiss) = [];
whoCountry(iMiss) = [];
countryHeb = {'אפגניסטן','אלבניה',['אלג''','יריה'],'אנדורה','אנגולה','אנטיגואה וברבודה','ארגנטינה','ארמניה','ארובה','אוסטרליה','אוסטריה','''אזרבייג''ן''','איי בהאמה','בחריין','בנגלדש','ברבדוס','בלארוס','בלגיה','בליז','בנין','ברמודה','בהוטן','בוליביה','בוסניה','בוצואנה','ברזיל','בולגריה','בורקינה פאסו','בורונדי','אוטו','קאבו ורדה','קמבודיה','קמרון','קנדה','הולנד הקריבית','איי קיימן',['צ''','אד'],'איי התעלה',['צ''','ילה'],'סין','קולומביה','קומורו','קונגו','קוסטה ריקה','קרואטיה','קובה','קוראסאו','קַפרִיסִין',['צ''','כיה'],'DRC','דנמרק','נסיכת היהלום',['ג''','יבוטי'],'דומיניקה','הרפובליקה הדומיניקנית','אקוודור','מצרים','אל סלבדור','גיניאה המשוונית','אריתריאה','אסטוניה','Eswatini','אתיופיה','איי פארו','איי פוקלנד',['פיג''','י'],'פינלנד','צרפת','גיאנה הצרפתית','פולינזיה הצרפתית','גבון','גמביה','גאורגיה','גרמניה','גאנה','גיברלטר','יוון','גרינלנד','גרנדה','גוואדלופ','גואטמלה','גינאה','גינאה ביסאו','גיאנה','האיטי','הונדורס','הונג קונג','הונגריה','אִיסלַנד','הוֹדוּ','אִינדוֹנֵזִיָה','איראן','עִירַאק','אירלנד','האי מאן','ישראל','איטליה','חוף שנהב',['ג''','מייקה'],'יפן','ירדן','קזחסטן','קניה','כווית','קירגיזסטן','לאוס','לטביה','לבנון','לסוטו','ליבריה','לוב','ליכטנשטיין','ליטא','לוקסמבורג','MS Zaandam','מדגסקר','מלאווי','מלזיה','מלדיבים','מאלי','מלטה','מרטיניק','מאוריטניה','מאוריציוס','מיוט','מקסיקו','מולדובה','מונקו','מונגוליה','מונטנגרו','מָרוֹקוֹ','מוזמביק','מיאנמר','נמיביה','נפאל','הולנד','קלדוניה החדשה','ניו זילנד','ניקרגואה',['ניז''','ר'],'ניגריה','צ. מקדוניה','נורווגיה','עומאן','פקיסטן','השטחים','פנמה','פפואה גינאה החדשה','פרגוואי','פרו','פיליפינים','פולין','פורטוגל','קטאר','רומניה','רוסיה','רואנדה','ראוניון','ד. קוריאה','סנט לוסיה','מרטין הקדוש','סנט פייר מיקלון','סן מרינו','סאו טומה ופרינסיפה','ערב הסעודית','סנגל','סרביה','סיישל','סיירה לאון','סינגפור','סנט מארטן','סלובקיה','סלובניה','איי שלמה','סומליה','דרום אפריקה','דרום סודן','ספרד','סרי לנקה','רחוב. בארת ','סט. וינסנט גרנדינים','סודן','סורינאם','שבדיה','שוויץ','סוריה','טייוואן',['טג''','יקיסטן'],'טנזניה','תאילנד','טימור-לסטה','ללכת','טרינידד וטובגו','תוניסיה','טורקיה','טורקס וקייקוס','איחוד האמירויות','בריטניה','ארה"ב','אוגנדה','אוקראינה','אורוגוואי','אוזבקיסטן','ונואטו','עיר הותיקן','ונצואלה','וייטנאם','סהרה המערבית','תֵימָן','זמביה','זימבבואה'}';
[~,iwm] = ismember(whoCountry,popWM.Country_Other);
popWM = popWM(iwm,:);
countryHeb = countryHeb(iwm);
if large
    small = popWM.Population < 1000000;
    whoData(small,:) = [];
    whoCountry(small) = [];
    countryHeb(small) = [];
    popWM(small,:) = [];
    deaths(:,small) = [];
end
% ecu = urlread('https://raw.githubusercontent.com/andrab/ecuacovid/master/datos_crudos/ecuacovid.csv');
% fid = fopen('tmp.csv','w');
% fwrite(fid,ecu);
% fclose(fid);
% ecu = readtable('tmp.csv');
% !rm tmp.*
% date = datetime(2020,3,13);
% date = date:date+height(ecu);
% [isxEcu,idxEcu] = ismember(date,timeVector);
% isxEcu = isxEcu(1:height(ecu));
% idxEcu = idxEcu(1:height(ecu));
% iEcu = find(ismember(mergedData(:,1),'Ecuador'));
% % mergedData{iEsp,2}(idxEsp(1:end-7)) = sum(esp(1:end-7,:),2);
% mergedData{iEcu,2}(idxEcu(isxEcu)) = sum(ecu{isxEcu,[5,6]},2);
cd ~/covid-19-israel-matlab/
%%
mil = popWM.Population'/10^6;
[~,iMustHave] = ismember(mustHave,whoCountry);
if strcmp(mustHave,'Israel')
    listD = readtable('data/Israel/dashboard_timeseries.csv');
    listD.CountDeath(isnan(listD.CountDeath)) = 0;
    [isDate,iDate] = ismember(listD.date,date);
    deaths(iDate(isDate),iMustHave) = listD.CountDeath(isDate);
%     deaths(iDate(isDate),iMustHave) = cumsum(deaths(iDate(isDate),iMustHave));
end

if cum
    y = cumsum(deaths)./mil;
    y = movmean(y,[6 0],'omitnan');
    tit = 'מתים למליון, מצטבר';
    xl = 'דירוג המדינות (מעל מליון איש) בהן שיעור התמותה מקורונה היה גבוה ביותר במצטבר';
else
    y = deaths./mil;
    y(y < 0) = nan;
    isJump = [false(1,size(y,2));diff(y) > 20];
    y(isJump) = nan;
    y = movmean(y,[6 0],'omitnan');
    tit = 'מתים למליון ליום, דירוג לפי ממוצע בשבוע האחרון';
    xl = 'דירוג המדינות (מעל מליון איש) בהן הקורונה קטלנית ביותר כרגע';
end
if ~large
    strrep(xl,'(מעל מליון איש) ','')
end
[~,order] = sort(nanmean(y(end-criterionDays+1:end,:),1),'descend'); % most deaths
[~,iMustHave] = ismember(iMustHave,order);
y = y(:,order);
%%
fig = figure('units','normalized','position',[0,0,0.5,0.5]);
hAll = plot(date,y,'linewidth',1,'color',[0.65 0.65 0.65]);
hold on
h = plot(date,y(:,11:20),'color',[0.65 0.65 0.65],'linewidth',1,'marker','.','MarkerSize',8);
h = [plot(date,y(:,1:10),'linewidth',1,'marker','.','MarkerSize',8);h];
co = hsv(10);
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
for ic = 1:10
    h(ic).Color = co(ic,:);
end
if ~isempty(iMustHave)
    for im = 1:length(iMustHave)
        hm(im) = plot(date,y(:,iMustHave(im)),'linewidth',1,'marker','.','MarkerSize',8);
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
xlim([datetime(2020,3,1) date(end)])
box off
grid on
% xlabel('Weeks')
title(tit)
if ~exist('ymax','var')
    ymax = max(max(y(end-14:end,:)))*1.1;
end
ylim([0 ymax])
yt = fliplr(ymax/nCountries:ymax/20:ymax);
x = size(y,1);
for iAnn = 1:nCountries
    ht(iAnn) = text(x,yt(iAnn),countryHeb{order(iAnn)},...
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
        if strcmp(mustHave,'Sweden') && ~cum
            [~,place] = sort(deaths(end-10,:),'descend');
            place = find(place == order(iMustHave));
            ht(end+1) = text(x,ya(im),[countryHeb{io},'(',num2str(place),')'],...
                'FontSize',10,'Color',hm(im).Color,'FontWeight','bold');
        else
            ht(end+1) = text(x,ya(im),[countryHeb{io},'(',num2str(iMustHave(im)),')'],...
                'FontSize',10,'Color',hm(im).Color,'FontWeight','bold');
        end
    end
end
ylabel('מתים למליון')
set(gcf,'Color','w')
xlabel(xl)
xtickformat('MMM')
set(gca,'XTick',datetime(2020,3:25,1),'FontSize',13)
countryHeb(:,2) = whoCountry;
if eng
    title('Daily deaths per million, rank by last week average')
    if cum
        title('Cumulative deaths per million, rank by last week average')
    end
        
    ylabel('deaths per million')
    xlabel('Rank of >1m people countries by COVID19 deaths')
    for it = 1:20
        cr = ismember(countryHeb(:,1),ht(it).String);
        ht(it).String = countryHeb{[false(size(cr)),cr]};
    end
    coco = ht(21).String(1:find(ismember(ht(21).String,'('),1)-1);
    cr = ismember(countryHeb(:,1),coco);
    coco1 = countryHeb{[false(size(cr)),cr]};
    ht(21).String = strrep(ht(21).String,coco,coco1);
end