function covid_world_wane(prc,measure)
if ~exist('prc','var')
    prc = 30;
end
R = false;
if ~exist('measure','var')
    measure = 'cases';
elseif strcmp(measure,'R')
    measure = 'cases';
    R = true;
end
if ~exist('large','var')
    large = true;
end
if ~exist('cum','var')
    cum = false;
end
% if ~exist('criterionDays','var')
%     criterionDays = 1;
% end
if ~exist('mustHave','var')
    mustHave = '';
end
if isempty(mustHave)
    mustHave = 'Israel';
end
% if ~exist('eng','var')
%     eng = false;
% end
cd ~/covid-19-israel-matlab/
% nCountries = 20;
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
yyyyy = nan(length(date),length(whoCountry));
for iCou = 1:length(whoCountry)
    row = find(ismember(whoData.Country,whoCountry{iCou}));
    rowDate = whoData.x_Date_reported(row);
    yyyyy(ismember(date,rowDate),iCou) = eval(['whoData.New_',measure,'(row);']);
end

% for slovenia use J H
[dataMatrix] = readCoronaData(measure);
[~,~,mergedData] = processCoronaData(dataMatrix);
yyyyy(21:end-1,ismember(whoCountry,'Slovenia')) = diff(mergedData{ismember(mergedData(:,1),'Slovenia'),2}(1:length(date)-20));
popWM = readtable('data/worldometer_data.csv');

missing = {'American Samoa','';'Anguilla','';'Bolivia (Plurinational State of)','Bolivia';'Bonaire, Sint Eustatius and Saba','';'British Virgin Islands','';'Brunei Darussalam','';'Central African Republic','CAR';'Cook Islands','';'Côte d’Ivoire','Ivory Coast';'Democratic People''s Republic of Korea','';'Democratic Republic of the Congo','DRC';'Falkland Islands (Malvinas)','Falkland Islands';'Faroe Islands','Faeroe Islands';'Guam','';'Guernsey','';'Holy See','';'Iran (Islamic Republic of)','Iran';'Jersey','';'Kiribati','';'Kosovo[1]','';'Lao People''s Democratic Republic','Laos';'Marshall Islands','';'Micronesia (Federated States of)','';'Montserrat','';'Nauru','';'Niue','';'Northern Mariana Islands (Commonwealth of the)','';'Other','';'Palau','';'Pitcairn Islands','';'Puerto Rico','';'Republic of Korea','S. Korea';'Republic of Moldova','Moldova';'Russian Federation','Russia';'Saint Barthélemy','';'Saint Helena','';'Saint Kitts and Nevis','';'Saint Pierre and Miquelon','';'Saint Vincent and the Grenadines','';'Samoa','';'Syrian Arab Republic','Syria';'The United Kingdom','UK';'Tokelau','';'Tonga','';'Turkmenistan','';'Turks and Caicos Islands','';'Tuvalu','';'United Arab Emirates','UAE';'United Republic of Tanzania','';'United States Virgin Islands','';'United States of America','USA';'Venezuela (Bolivarian Republic of)','Venezuela';'Viet Nam','Vietnam';'Wallis and Futuna','';'occupied Palestinian territory, including east Jerusalem','Palestine'};
missing(cellfun(@isempty,missing(:,2)),:) = [];
[~,idx] = ismember(missing(:,1),whoCountry);
whoCountry(idx) = missing(:,2);
iMiss = ~ismember(whoCountry,popWM.Country_Other);
yyyyy(:,iMiss) = [];
whoCountry(iMiss) = [];
% countryHeb = {'אפגניסטן','אלבניה',['אלג''','יריה'],'אנדורה','אנגולה','אנטיגואה וברבודה','ארגנטינה','ארמניה','ארובה','אוסטרליה','אוסטריה','''אזרבייג''ן''','איי בהאמה','בחריין','בנגלדש','ברבדוס','בלארוס','בלגיה','בליז','בנין','ברמודה','בהוטן','בוליביה','בוסניה','בוצואנה','ברזיל','בולגריה','בורקינה פאסו','בורונדי','אוטו','קאבו ורדה','קמבודיה','קמרון','קנדה','הולנד הקריבית','איי קיימן',['צ''','אד'],'איי התעלה',['צ''','ילה'],'סין','קולומביה','קומורו','קונגו','קוסטה ריקה','קרואטיה','קובה','קוראסאו','קַפרִיסִין',['צ''','כיה'],'DRC','דנמרק','נסיכת היהלום',['ג''','יבוטי'],'דומיניקה','הרפובליקה הדומיניקנית','אקוודור','מצרים','אל סלבדור','גיניאה המשוונית','אריתריאה','אסטוניה','Eswatini','אתיופיה','איי פארו','איי פוקלנד',['פיג''','י'],'פינלנד','צרפת','גיאנה הצרפתית','פולינזיה הצרפתית','גבון','גמביה','גאורגיה','גרמניה','גאנה','גיברלטר','יוון','גרינלנד','גרנדה','גוואדלופ','גואטמלה','גינאה','גינאה ביסאו','גיאנה','האיטי','הונדורס','הונג קונג','הונגריה','אִיסלַנד','הוֹדוּ','אִינדוֹנֵזִיָה','איראן','עִירַאק','אירלנד','האי מאן','ישראל','איטליה','חוף שנהב',['ג''','מייקה'],'יפן','ירדן','קזחסטן','קניה','כווית','קירגיזסטן','לאוס','לטביה','לבנון','לסוטו','ליבריה','לוב','ליכטנשטיין','ליטא','לוקסמבורג','MS Zaandam','מדגסקר','מלאווי','מלזיה','מלדיבים','מאלי','מלטה','מרטיניק','מאוריטניה','מאוריציוס','מיוט','מקסיקו','מולדובה','מונקו','מונגוליה','מונטנגרו','מָרוֹקוֹ','מוזמביק','מיאנמר','נמיביה','נפאל','הולנד','קלדוניה החדשה','ניו זילנד','ניקרגואה',['ניז''','ר'],'ניגריה','צ. מקדוניה','נורווגיה','עומאן','פקיסטן','השטחים','פנמה','פפואה גינאה החדשה','פרגוואי','פרו','פיליפינים','פולין','פורטוגל','קטאר','רומניה','רוסיה','רואנדה','ראוניון','ד. קוריאה','סנט לוסיה','מרטין הקדוש','סנט פייר מיקלון','סן מרינו','סאו טומה ופרינסיפה','ערב הסעודית','סנגל','סרביה','סיישל','סיירה לאון','סינגפור','סנט מארטן','סלובקיה','סלובניה','איי שלמה','סומליה','דרום אפריקה','דרום סודן','ספרד','סרי לנקה','רחוב. בארת ','סט. וינסנט גרנדינים','סודן','סורינאם','שבדיה','שוויץ','סוריה','טייוואן',['טג''','יקיסטן'],'טנזניה','תאילנד','טימור-לסטה','ללכת','טרינידד וטובגו','תוניסיה','טורקיה','טורקס וקייקוס','איחוד האמירויות','בריטניה','ארה"ב','אוגנדה','אוקראינה','אורוגוואי','אוזבקיסטן','ונואטו','עיר הותיקן','ונצואלה','וייטנאם','סהרה המערבית','תֵימָן','זמביה','זימבבואה'}';
[~,iwm] = ismember(whoCountry,popWM.Country_Other);
popWM = popWM(iwm,:);
% countryHeb = countryHeb(iwm);
if large
    small = popWM.Population < 1000000;
%     whoData(small,:) = [];
    whoCountry(small) = [];
%     countryHeb(small) = [];
    popWM(small,:) = [];
    yyyyy(:,small) = [];
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
    [isDate,iDate] = ismember(listD.date,date);
    if strcmp(measure,'cases')
        listD.tests_positive1(isnan(listD.tests_positive1)) = 0;
        yyyyy(iDate(isDate),iMustHave) = listD.tests_positive1(isDate);
    else
        listD.CountDeath(isnan(listD.CountDeath)) = 0;
        yyyyy(iDate(isDate),iMustHave) = listD.CountDeath(isDate);
    end
%     cases(iDate(isDate),iMustHave) = cumsum(cases(iDate(isDate),iMustHave));
end

if cum
    y = cumsum(yyyyy)./mil;
    y = movmean(y,[6 0],'omitnan');
    tit = 'מאומתים למליון, מצטבר';
    xl = 'דירוג המדינות (מעל מליון איש) בהן שיעור התמותה מקורונה היה גבוה ביותר במצטבר';
else
    y = yyyyy./mil;
    y(y < 0) = nan;
    isJump = [false(1,size(y,2));diff(y) > 20];
    y(isJump) = nan;
    y = movmean(y,[6 0],'omitnan');
    tit = 'מאומתים למליון ליום, דירוג לפי ממוצע בשבוע האחרון';
    xl = 'דירוג המדינות (מעל מליון איש)';
end
if ~large
    strrep(xl,'(מעל מליון איש) ','')
end
% [~,order] = sort(nanmean(y(end-criterionDays+1:end,:),1),'descend'); % most cases
% [~,iMustHave] = ismember(iMustHave,order);
yo = y;
% y = y(:,order);

!wget -O tmp.csv https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv
tt = readtable('tmp.csv');
countryV = unique(tt.location);
date2 = NaT(size(countryV));
date3 = date2;
% prc = 30;
for ii = 1:length(countryV)
    idx = find(ismember(tt.location,countryV{ii}) & tt.people_fully_vaccinated_per_hundred >= prc);
    if ~isempty(idx)
        date2(ii) = min(tt.date(idx));
    end
    jdx = find(ismember(tt.location,countryV{ii}) & tt.total_boosters_per_hundred > 5);
    if ~isempty(jdx)
        date3(ii) = min(tt.date(jdx));
    end
end
countryV(isnat(date2)) = [];
date3(isnat(date2)) = [];
date2(isnat(date2)) = [];

countryV = strrep(countryV,'South Korea','S. Korea');
countryV = strrep(countryV,'United States','USA');
countryV = strrep(countryV,'United Kingdom','UK');

date2 = date2(ismember(countryV,whoCountry));
date3 = date3(ismember(countryV,whoCountry));
countryV = countryV(ismember(countryV,whoCountry));

co = hsv(length(countryV));
co(3,:) = co(3,:)*0.65;
[~,order] = sort(date2);
% co(order,:) = co;
% co(4,2) = 0.7;

BL = 50;
iy = [];
figure('units','normalized','position',[0,0,1,1]);
for ii = 1:length(countryV)
    iy(ii,1) = find(ismember(whoCountry,countryV{ii}));
    iDate = find(ismember(date,date2(ii)));
    yv = yo(iDate-BL:end,iy(ii));
    if R
        rr = covid_R31(yv);
        rr(1:30) = nan;
        rrr = nan(length(yv),1);
        rrr(1:end-9) = rr(10:end);
        yv = rrr;
    end
    hv(ii) = plot(-BL:length(yv)-BL-1,yv);
    if strcmp(countryV{ii},'Israel')
        iii = ii;
        hv(ii).Color = [0 0 0];
    else
        hv(ii).Color = co(ii,:);
    end
    ie = find(~isnan(yv),1,'last');
    text(ie-BL,yv(ie),countryV{ii},'Color',hv(ii).Color);
    hold on
    if ~isnat(date3(ii))
        iDate3 = find(ismember(date,date3(ii)));
        if iDate3 > iDate
            yv3 = nan(size(yv));
            yv3end = yo(iDate3:end,iy(ii));
            if R
                yv3end(:) = rrr(end-length(yv3end)+1-9:end-9);
                yv3(ie-length(yv3end)+1:ie) = yv3end;
            else
                yv3(length(yv3)-length(yv3end)+1:end) = yv3end;
            end
            hv3(ii) = plot(-BL:length(yv3)-BL-1,yv3,'LineWidth',2);
        else
            hv3(ii) = plot(-BL:length(yv)-BL-1,yv,'LineWidth',2);
        end
%         if strcmp(countryV{ii},'Israel')
%             disp(' ')
%         end
        hv3(ii).Color = hv(ii).Color;
    end
end
grid on
set(gca,'XTick',-30:30:1000,'FontSize',13)
xlabel(['Days from ',str(prc),'% fully vaccinated people'])
ylabel(['daily ',measure,' per million'])
set(gcf,'Color','w')
title({['Waning immunity around the world, ',measure,' time-locked to ',str(prc),'% vaccination'],'Thick lines for 5% booster or more'})
text(180,1650,[measure,' data from WHO, vaccine data from OWID'])
if strcmp(measure,'cases')
    if R
        ylim([0.5 2.5])
    else
        ylim([0 1700])
    end
else
    ylim([0 30])
end
yend = ceil((length(hv(iii).XData)-BL-1)/30)*30;
xlim([-50 yend])
box off