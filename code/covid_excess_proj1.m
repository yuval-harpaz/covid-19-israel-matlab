function covid_excess_proj1

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
popWM = readtable('worldometer_data.csv');
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
[~,idxP] = ismember(t.Country,popWM.Country_Other);

% figure;
% plot(cumsum(deaths(:,idxD))./popWM.Population(idxP)'*10^6.*t.UndercountRatio');
pop = t.ExcessDeaths./t.ExcessPer100k*10^5;
dpm = cumsum(deaths(:,idxD))./pop'*10^6.*t.UndercountRatio';

dpm2annual = t.ExcessAs_OfAnnualBaseline./(10*t.ExcessPer100k);

figure;
plot(dpm.*dpm2annual');
% for ii = 1:height(t)
%     wCol = ismember(whoCountry,t.Country{ii});
%     popRow = ismember(popWM.Country_Other,t.Country{ii});
%     y = cumsum(deaths(:,wCol))./popWM.Population(popRow)*10^6;
%     h(ii) = plot(date,y*t.UndercountRatio(ii),'Color',co(ii,:));
%     hold on
%     plot(t.date(ii),t.ExcessPer100k(ii)*10,'*','Color',co(ii,:))
% end
% ylabel('deaths per million')
% 
% set(gca,'ygrid','on')
% title('Excess deaths per million. Lines = estimates, "*" = reported')
% xtickformat('MMM')
% set(gca,'XTick',datetime(2020,1:25,1),'FontSize',13)
% grid on
% xlim([datetime(2020,3,1) datetime('tomorrow')])
% ii = find(ismember(t.Country,'Israel'));
% wCol = ismember(whoCountry,t.Country{ii});
% popRow = ismember(popWM.Country_Other,t.Country{ii});
% y = cumsum(deaths(:,wCol))./popWM.Population(popRow)*10^6;
% h(ii) = plot(date,y*t.UndercountRatio(ii),'Color','k');
% plot(t.date(ii),t.ExcessPer100k(ii)*10,'*','Color','k')
% legend(h,t.Country)
% % legend(h,t.Country([1:8,ii]))
% 



% co = hsv(10);
% co(3,:) = co(3,:)*0.75;
% co(4,2) = 0.7;
% co = repmat(co,2,1);
% co(end+1:height(t),1:3) = 0.65;
% co(ismember(t.Country,'Israel'),:) = 0;
% figure;
% for ii = 1:height(t)
% %     h(ii) = scatter(date(ii),t.ExcessAs_OfAnnualBaseline(ii),25,'fill');
%     h(ii) = scatter(date(ii),t.ExcessAs_OfAnnualBaseline(ii),1,'MarkerEdgeColor','none');
%     text(date(ii),t.ExcessAs_OfAnnualBaseline(ii),t.Country{ii},'Color',co(ii,:))
%     hold on
% end
% % xlim([datetime(2020,10,20) datetime('today')+100])
% xt = datetime(2020,3:100,1);
% xt(xt > dateshift(max(date),'end','month')+31) = [];
% set(gca,'XTick',xt)
% xtickformat('MMM')
% title({'Excess deaths as percents of annual','mortality by date of report               '})
% ylabel('% of annual deaths')
% set(gcf,'Color','w')
% set(gca,'FontSize',13)
% %%
% lim = datetime(2020,10,20);
% tr = t;
% tr(date < lim,:) = [];
% figure('units','normalized','position',[0,0.25,1,0.5]);
% bar(tr.ExcessAs_OfAnnualBaseline)
% set(gca,'XTick',1:height(tr),'XTickLabel',tr.Country,'ygrid','on','YTick',-10:10:100)
% xtickangle(90)
% % grid on
% text((1:height(tr))-0.35,repmat(-12,height(tr),1),str((1:height(tr))'))
% box off
% title('Excess deaths as percents of annual deaths')
% set(gcf,'Color','w')