function t = covid_excess_proj2

cd ~/covid-19-israel-matlab/data/
!wget -O tmp.csv https://raw.githubusercontent.com/dkobak/excess-mortality/main/excess-mortality.csv
t = readtable('tmp.csv');
t.Country = strrep(t.Country,'United Kingdom','UK');
[~,order] = sort(t.ExcessAs_OfAnnualBaseline,'descend');
t = t(order,:);
t.date = datetime(t.DataUntil,'InputFormat','MMM dd, yyyy');


try
    [~,~] = system('wget -O tmp.csv https://covid19.who.int/WHO-COVID-19-global-data.csv');
    whoData = readtable('tmp.csv');
    writetable(whoData,'who.csv','Delimiter',',','WriteVariableNames',true);
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
    deathsC(ismember(date,rowDate),iCou) = whoData.Cumulative_deaths(row);
end
popWM = readtable('worldometer_data.csv');
missing = {'American Samoa','';'Anguilla','';'Bolivia (Plurinational State of)','Bolivia';'Bonaire, Sint Eustatius and Saba','';'British Virgin Islands','';'Brunei Darussalam','';'Central African Republic','CAR';'Cook Islands','';'Côte d’Ivoire','Ivory Coast';'Democratic People''s Republic of Korea','';'Democratic Republic of the Congo','DRC';'Falkland Islands (Malvinas)','Falkland Islands';'Faroe Islands','Faeroe Islands';'Guam','';'Guernsey','';'Holy See','';'Iran (Islamic Republic of)','Iran';'Jersey','';'Kiribati','';'Kosovo[1]','';'Lao People''s Democratic Republic','Laos';'Marshall Islands','';'Micronesia (Federated States of)','';'Montserrat','';'Nauru','';'Niue','';'Northern Mariana Islands (Commonwealth of the)','';'Other','';'Palau','';'Pitcairn Islands','';'Puerto Rico','';'Republic of Korea','S. Korea';'Republic of Moldova','Moldova';'Russian Federation','Russia';'Saint Barthélemy','';'Saint Helena','';'Saint Kitts and Nevis','';'Saint Pierre and Miquelon','';'Saint Vincent and the Grenadines','';'Samoa','';'Syrian Arab Republic','Syria';'The United Kingdom','UK';'Tokelau','';'Tonga','';'Turkmenistan','';'Turks and Caicos Islands','';'Tuvalu','';'United Arab Emirates','UAE';'United Republic of Tanzania','';'United States Virgin Islands','';'United States of America','USA';'Venezuela (Bolivarian Republic of)','Venezuela';'Viet Nam','Vietnam';'Wallis and Futuna','';'occupied Palestinian territory, including east Jerusalem','Palestine'};
missing(cellfun(@isempty,missing(:,2)),:) = [];
[~,idx] = ismember(missing(:,1),whoCountry);
whoCountry(idx) = missing(:,2);
iMiss = ~ismember(whoCountry,popWM.Country_Other);
deaths(:,iMiss) = [];
deathsC(:,iMiss) = [];
whoCountry(iMiss) = [];
countryHeb = {'אפגניסטן','אלבניה',['אלג''','יריה'],'אנדורה','אנגולה','אנטיגואה וברבודה','ארגנטינה','ארמניה','ארובה','אוסטרליה','אוסטריה','''אזרבייג''ן''','איי בהאמה','בחריין','בנגלדש','ברבדוס','בלארוס','בלגיה','בליז','בנין','ברמודה','בהוטן','בוליביה','בוסניה','בוצואנה','ברזיל','בולגריה','בורקינה פאסו','בורונדי','אוטו','קאבו ורדה','קמבודיה','קמרון','קנדה','הולנד הקריבית','איי קיימן',['צ''','אד'],'איי התעלה',['צ''','ילה'],'סין','קולומביה','קומורו','קונגו','קוסטה ריקה','קרואטיה','קובה','קוראסאו','קַפרִיסִין',['צ''','כיה'],'DRC','דנמרק','נסיכת היהלום',['ג''','יבוטי'],'דומיניקה','הרפובליקה הדומיניקנית','אקוודור','מצרים','אל סלבדור','גיניאה המשוונית','אריתריאה','אסטוניה','Eswatini','אתיופיה','איי פארו','איי פוקלנד',['פיג''','י'],'פינלנד','צרפת','גיאנה הצרפתית','פולינזיה הצרפתית','גבון','גמביה','גאורגיה','גרמניה','גאנה','גיברלטר','יוון','גרינלנד','גרנדה','גוואדלופ','גואטמלה','גינאה','גינאה ביסאו','גיאנה','האיטי','הונדורס','הונג קונג','הונגריה','אִיסלַנד','הוֹדוּ','אִינדוֹנֵזִיָה','איראן','עִירַאק','אירלנד','האי מאן','ישראל','איטליה','חוף שנהב',['ג''','מייקה'],'יפן','ירדן','קזחסטן','קניה','כווית','קירגיזסטן','לאוס','לטביה','לבנון','לסוטו','ליבריה','לוב','ליכטנשטיין','ליטא','לוקסמבורג','MS Zaandam','מדגסקר','מלאווי','מלזיה','מלדיבים','מאלי','מלטה','מרטיניק','מאוריטניה','מאוריציוס','מיוט','מקסיקו','מולדובה','מונקו','מונגוליה','מונטנגרו','מָרוֹקוֹ','מוזמביק','מיאנמר','נמיביה','נפאל','הולנד','קלדוניה החדשה','ניו זילנד','ניקרגואה',['ניז''','ר'],'ניגריה','צ. מקדוניה','נורווגיה','עומאן','פקיסטן','השטחים','פנמה','פפואה גינאה החדשה','פרגוואי','פרו','פיליפינים','פולין','פורטוגל','קטאר','רומניה','רוסיה','רואנדה','ראוניון','ד. קוריאה','סנט לוסיה','מרטין הקדוש','סנט פייר מיקלון','סן מרינו','סאו טומה ופרינסיפה','ערב הסעודית','סנגל','סרביה','סיישל','סיירה לאון','סינגפור','סנט מארטן','סלובקיה','סלובניה','איי שלמה','סומליה','דרום אפריקה','דרום סודן','ספרד','סרי לנקה','רחוב. בארת ','סט. וינסנט גרנדינים','סודן','סורינאם','שבדיה','שוויץ','סוריה','טייוואן',['טג''','יקיסטן'],'טנזניה','תאילנד','טימור-לסטה','ללכת','טרינידד וטובגו','תוניסיה','טורקיה','טורקס וקייקוס','איחוד האמירויות','בריטניה','ארה"ב','אוגנדה','אוקראינה','אורוגוואי','אוזבקיסטן','ונואטו','עיר הותיקן','ונצואלה','וייטנאם','סהרה המערבית','תֵימָן','זמביה','זימבבואה'}';
[~,iwm] = ismember(whoCountry,popWM.Country_Other);
popWM = popWM(iwm,:);
countryHeb = countryHeb(iwm);
% small = popWM.Population < 1000000;
% whoData(small,:) = [];
% whoCountry(small) = [];
% countryHeb(small) = [];
% popWM(small,:) = [];
% deaths(:,small) = [];
t.Country{ismember(t.Country,'Bosnia')} = 'Bosnia and Herzegovina';
t.Country{ismember(t.Country,'South Korea')} = 'S. Korea';
t.Country{ismember(t.Country,'United States')} = 'USA';
t(~ismember(t.Country,whoCountry),:) = [];


co = hsv(10);
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
co = repmat(co,2,1);
co(end+1:height(t),1:3) = 0.65;

[~,idxD] = ismember(t.Country,whoCountry);
% [~,idxP] = ismember(t.Country,popWM.Country_Other);


% pop = t.ExcessDeaths./t.ExcessPer100k*10^5;




annualDeath = t.ExcessDeaths./t.ExcessAs_OfAnnualBaseline*100;
acu = t.UndercountRatio;
acu(isnan(acu)) = 1;
acu(acu < 1) = 1;
deathsCorrected = nansum(deaths(:,idxD))'.*acu;
deathsCorrectedC = nansum(deathsC(:,idxD))'.*acu;
t.correctedAnnual = deathsCorrected./annualDeath;
t.correctedAnnualC = deathsCorrectedC./annualDeath;
[~,order] = sort(t.correctedAnnual,'descend');
[~,orderC] = sort(t.correctedAnnualC,'descend');
to = t(order,:);
toC = t(orderC,:);
We = {'Monaco','Marino','Andorra','USA','Italy','Liech','Spain','UK','Portugal','France',...
    'Ireland','Canada','Belgium','Swit','Swed','Netherl','Austria','Luxem',...
    'Denmark','German','Icel','Finl','Norw','Gibraltar'};
west = find(contains(to.Country,We));
EE = {'Russia','Albania','Macedo','Slovak','Armen','Czec','Belarus','Moldova','Bulgar','Poland',...
    'Monteneg','Serbia','Lithuan','Roman','Slovenia','Hungary','Georgia','Croatia','Ukrain',...
    'Estonia','Latvia','Cyprus','Greece','Malta','Bosnia'};
eastEU = find(contains(to.Country,EE));
isr = find(contains(to.Country,'Israel'));
LA = {'Argentina','Antigua and Barbuda','Aruba',...
    'Barbados','Belize','Bermuda','Costa Rica','Cuba','Jamaica','Guadeloupe',...
    'Peru','Ecuador','Martinique','Mexico','Bolivia','El Salva','Nicara',...
    'Colombia','Brazil','Chile','Panama','Parag','Guate','Uruguay','Dominican Republic','Suriname'};
latinA =  find(contains(to.Country,LA));
indi = {1:height(to);west;eastEU;latinA;isr};
col = [0.6 0.25 0.75;0.15 0.15 0.85;0.25 0.55 0.75;0.2 0.4 0.2;0 0 0;];
%%
% figure;
% clear hh
% for ii = 1:length(indi)
%     y = nan(height(to),1);
%     y(indi{ii}) = to.correctedAnnual(indi{ii});
%     hh(ii) = bar(y*100);
%     hold on
%     hh(ii).EdgeColor = 'none';
%     hh(ii).FaceColor = col(ii,:);
% end
% set(gca,'XTickLabel',to.Country,'XTick',1:height(to))
% xtickangle(90)
% legend(hh([2,3,4,5,1]),'West','East Europe','Latin America','Israel','Other')
% ylabel('%')
% title('Excess mortality as % of annual deaths (projected to today)')
% set(gcf,'Color','w')
% set(gca,'YTick',0:10:140,'YGrid','on')
% box off
%%
yy = deaths;
yy(:,:,2) = deathsC;
yy(:,:,3) = yy(:,:,2);
%%
% dateC = datetime(toC.DataUntil,'InputFormat','MMM dd, yyyy');
for iii = 1:height(toC)
    dt = t.date(iii);
    if dt > datetime(2020,7,1)
        acuYH(iii,1) = t.ExcessDeaths(iii)/deathsC(date == dt,idxD(iii));
    else
        acuYH(iii,1) = 1;
    end
end
acuYH(acuYH <= 0) = 1;
for ii = 1:3
    % ii = 2;
    dDeathsCorrected = yy(:,idxD,ii)'.*acuYH;
    dCorrectedAnnual = dDeathsCorrected./annualDeath;
    if ii == 1
        dCorrectedAnnual(dCorrectedAnnual > 0.04) = nan;
        ddad = movmean(dCorrectedAnnual',[6 0],'omitnan');
    else
        ddad = dCorrectedAnnual';
        replace =  isnan(ddad(end,:)) & ~isnan(ddad(end-1,:));
        ddad(end,replace) = ddad(end-1,replace);
        ddad(end,isnan(ddad(end,:))) = 0;
    end
    if ii == 3
        orderNext = order2;
        order2 = order1st;
    else
        [~,order2] = sort(ddad(end,:),'descend');
    end
    if ii == 1
        order1st = order2;
    end
    co2 = t.Country(order2);
    figure;
    plot(date,100*ddad(:,order2),'Color',[0.65 0.65 0.65])
    hold on
    h2 = plot(date,100*ddad(:,order2(11:20)));
    h1 = plot(date,100*ddad(:,order2(1:10)),'LineWidth',2);
    for ic = 1:10
        h1(ic).Color = co(ic,:);
        h2(ic).Color = co(ic,:);
    end
    if ii == 1
        ylim([0 1])
    end
    xlim([datetime(2020,3,1) datetime('tomorrow')])
    xtickformat('MMM')
    set(gca,'XTick',datetime(2020,1:25,1),'FontSize',13)
    ylabel('% annual deaths')
    box off
    grid on
    if ii == 1
        title('Daily excess mortality (%) תמותה עודפת יומית ')
    else
        title('Excess mortality (%) תמותה עודפת ')
    end
    set(gcf,'Color','w')
    
    if ii > 1
        dateCC = datetime(t.DataUntil(order2),'InputFormat','MMM dd, yyyy');
        for ic = 1:10
            hhLast(ic) = plot(dateCC(ic),t.ExcessAs_OfAnnualBaseline(order2(ic)),'*',...
                'Color',co(ic,:),'MarkerSize',10);
            hhLast(ic+10) = plot(dateCC(ic+10),t.ExcessAs_OfAnnualBaseline(order2(ic+10)),'*',...
                'Color',co(ic,:),'MarkerSize',10);
        end
        h3 = plot(dateCC(1),nan,'*k','MarkerSize',10);
        legend([h1;h2;h3],[co2(1:20);{'Last reported excess mortality'}],'location','northwest');
    else
        legend([h1;h2],co2(1:20),'location','northwest');
    end
end
% end
%%
toyh = t(orderNext,:);
west = find(contains(toyh.Country,We));
eastEU = find(contains(toyh.Country,EE));
isr = find(contains(toyh.Country,'Israel'));
latinA =  find(contains(toyh.Country,LA));
indi = {1:height(toyh);west;eastEU;latinA;isr};
col = [0.6 0.25 0.75;0.15 0.15 0.85;0.25 0.55 0.75;0.2 0.4 0.2;0 0 0;];
figure;
clear hh
for ii = 1:length(indi)
    y = nan(height(toyh),1);
    y(indi{ii}) = ddad(end,orderNext(indi{ii}));  % toyh.correctedAnnual(indi{ii});
    hh(ii) = bar(y*100);
    hold on
    hh(ii).EdgeColor = 'none';
    hh(ii).FaceColor = col(ii,:);
end
set(gca,'XTickLabel',toyh.Country,'XTick',1:height(toyh))
xtickangle(90)
legend(hh([2,3,4,5,1]),'West','East Europe','Latin America','Israel','Other')
ylabel('%')
title('Excess mortality as % of annual deaths (projected to today)')
set(gcf,'Color','w')
set(gca,'YTick',0:10:140,'YGrid','on')
box off

%% 
