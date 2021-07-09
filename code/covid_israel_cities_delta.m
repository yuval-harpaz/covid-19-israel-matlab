% % gil = readtable('~/Downloads/contagionDataPerCityPublic_orig.csv')
% city = {'תל אביב - יפו';'פתח תקווה';'כפר סבא';'כפר יונה';'נתניה';'ראשון לציון';'הרצליה';'מעלה אדומים';'הוד השרון';'מודיעין-מכבים-רעות';'פרדס חנה-כרכור';'רחובות';'חולון';'שערי תקווה';'יהוד';'ירושלים';'חיפה';'רעננה';'קרית אונו';'חדרה';'רמת גן';'רמלה';'צופים';'רמת השרון';'כוכב יאיר';'גבעתיים';'גני תקווה';'בנימינה-גבעת עדה';'באר יעקב';'חריש';'באר שבע';'ראש העין';'בת ים';'אשקלון';'אשדוד';'נס ציונה';'יבנה';'אורנית';'קדימה-צורן';'לוד';'עץ אפרים';'אור יהודה';'בית חשמונאי';'קרני שומרון';'כפר קאסם';'קרית גת';'גדרה';'קרית ביאליק';'קרית מוצקין';'צור יצחק';'דאלית אל-כרמל';'מג''ד אל-כרום';'נשר';'ירוחם';'אלעזר';'אפרת';'פסגות';'עלי זהב';'ג''סר א-זרקא';'עתלית';'ערערה';'ג''ת';'ברכה';'אילת';'גבעת זאב';'נצרת';'גבעת שמואל';'שילה';'טייבה';'נוקדים';'ראמה';'אופקים';'עפולה';'נתיבות';'יקיר';'טירה';'ביר אל-מכסור';'אלקנה';'אריאל';'דימונה';'עפרה';'עכו';'חשמונאים';'ראש פינה';'לפיד';'ג''דיידה-מכר';'תל מונד';'אלפי מנשה';'פרדסיה';'אבו סנאן';'דייר חנא';'כאבול';'קרית ים';'כפר מנדא';'קרית טבעון';'נהריה';'מעיליא';'אעבלין';'שפרעם';'מזכרת בתיה';'קרית ארבע';'כפר האורנים';'סביון';'מודיעין עילית';'קרית אתא';'כפר קרע';'שלומי';'באקה אל-גרביה';'כרמיאל';'אבני חפץ';'רבבה';'טלמון';'יקנעם עילית';'פדואל';'מיתר';'להבים';'קדומים';'בית שמש';'שוהם';'אלעד';'מתן';'בת חפר';'בית אריה';'זכרון יעקב';'עילוט';'טמרה';'סח''נין';'בית יצחק-שער חפר';'גבעת ברנר';'כפר אדומים';'עומר';'שדרות';'אור עקיבא';'ריינה';'בני ברק';'קצרין';'קרית שמונה';'כעביה-טבאש-חג''אג''רה';'מסעודין אל-עזאזמה';'רמת ישי';'שבלי - אום אל-גנם';'קרית מלאכי';'מבשרת ציון';'מגדל העמק';'גן יבנה';'חצור הגלילית';'ג''לג''וליה';'בועיינה-נוג''ידאת';'בית דגן';'בית ג''ן';'ביתר עילית';'גני מודיעין';'מבוא חורון';'מצפה רמון';'אבן יהודה';'נופית';'נווה דניאל';'אלון שבות';'כפר יאסיף';'עין נקובא';'יד בנימין';'כוכב השחר';'מעלות-תרשיחא';'אבו רוקייק (שבט)';'אבו ג''ווייעד (שבט)';'אבו קורינאת (שבט)';'טובא-זנגריה';'נוף הגליל';'ערערה-בנגב';'כאוכב אבו אל-היג''א';'כפר ורדים';'גבעת אבני';'כסרא-סמיע';'מעלה עירון';'נוף איילון';'יפיע';'אום אל-פחם';'רומת הייב';'אטרש (שבט)';'מסעדה';'ע''ג''ר';'אעצם (שבט)';'משהד';'אבטין';'מייסר';'סולם';'סאג''ור';'נאעורה';'עמנואל';'לא ידוע';'שגב-שלום';'בסמ"ה';'שמשית';'אל סייד';'חורה';'זמר';'הושעיה';'קיסריה';'לקיה';'כסיפה';'בוקעאתא';'זרזיר';'רכסים';'קלנסווה';'כפר ברא';'אזור';'פסוטה';'עין מאהל';'עיילבון';'מזרעה';'בית שאן';'כפר מצר';'כפר כמא';'רהט';'יבנאל';'קרית עקרון';'אליכין';'קצר א-סר';'בית אל';'מגאר';'אבו גוש';'ניצן';'שעב';'עספיא';'עראבה';'טבריה';'נחף';'כפר כנא';'ירכא';'הר אדר';'סלמה';'גן נר';'ערד';'ג''ולס';'בענה';'אכסאל';'מוקייבלה';'צור משה';'תקוע';'מג''דל שמס';'צור הדסה';'בני עי"ש';'תל שבע';'כפר חב"ד';'פוריידיס';'ביר הדאג''';'חורפיש';'עין קנייא';'דבוריה';'הוואשלה (שבט)';'יאנוח-ג''ת';'אחוזת ברק';'סייד (שבט)';'כפר תבור';'מרכז שפירא';'מצפה יריחו';'שייח'' דנון';'טירת כרמל';'גבע בנימין';'כוכב יעקב';'קרית יערים';'אבו רובייעה (שבט)';'צפת';'קודייראת א-צאנע(שבט)';'בסמת טבעון';'אום בטין';'אבו תלול';'פקיעין (בוקייעה)';'דייר אל-אסד';'ג''ש (גוש חלב)';'תפרח';'עוזייר';'עלי';'נעלה';'טורעאן'};
% % city = {'ירושלים';'תל אביב';'חיפה';'ראשון לציון';'פתח תקווה';'אשדוד';'נתניה';'באר שבע';'בני ברק';'חולון';'רמת גן';'אשקלון';'רחובות'};
% % population = [919438;451523;283640;251719;244275;224628;217243;209002;198863;194273;159160;145967;141579];
% % pop = table(city,population);
% %  listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
% warning off
% for ii = 1:length(city)
%     data = urlread(['https://data.gov.il/api/3/action/datastore_search?q=',city{ii},'&resource_id=8a21d39d-91e3-40db-aca1-f73f7ab1df69&limit=10000000']);
%     data = jsondecode(data);
%     data = struct2table(data.result.records);
%     dateRow = datetime(data.Date);
%     [dateRow,order] = unique(dateRow);
% %     if ii == 1
% %         nMonths = 11+month(dateRow(end));
% %     end
%     data = data(order,:);
% %     data.Cumulated_deaths = strrep(data.Cumulated_deaths,'<15','0');
%     data.Cumulative_verified_cases = strrep(data.Cumulative_verified_cases,'<15','0');
% %     deathRow = cellfun(@str2num,data.Cumulated_deaths);
%     caseRow = cellfun(@str2num,data.Cumulative_verified_cases);
%     if ii == 1
%         cases = [0;diff(caseRow)];
%     else
%         cases(:,ii) = [0;diff(caseRow)];
%     end
%     datePrev = dateRow;
%     IEprog(ii)
% end
% save tmp.mat cases city dateRow
% 
% date = dateRow;
% figure;
% plot(dateRow,cases)
%%
dLim = [datetime(2020,5,15),datetime(2020,8,1);datetime(2021,1,7),datetime('today')-14];
for jj = 1:2
    for kk = 1:2
        dSamp(jj,kk) = find(date == dLim(jj,kk));
    end
end
nDays = 31;
bl = 5;
for wave = 1:2
    aligned = nan(nDays,length(city));
    if wave == 1
        cas = cases(1:dSamp(wave,2)+31,:);
    else
        cas = cases;
    end
    for ii = 1:length(city)
        iLast = find(movmean(cas(:,ii),[2,0]) <= 3,1,'last');
        iLast = iLast - bl;
        vec = cas(iLast:end,ii);
        fin = length(vec);
        if iLast < dSamp(wave,1) || iLast > dSamp(wave,2)  %< datetime(2021,1,7)
            disp(city(ii))
        elseif length(vec) < bl+2
            % nothing
        else
            fin = min(fin,nDays);
            aligned(1:fin,ii) = vec(1:fin);
        end
    end
    dat{wave,1} = aligned;
end

col = [0.7 0.7 0.7;0,0,0.7];
figure
for iw = 1:2
    h{iw,1} = plot(movmean(dat{iw},[3 3]),'Color',col(iw,:))
    hold on
end
xlim([1 31])
grid on
ylabel('cases')
xlabel('days')
legend([h{1}(1),h{2}(1)],'wave II','wave IV','location','northwest')
title('City case count by days from outbreak')
% legend(city)
%%
col = colormap(jet(13));
col = flipud(col);
[~,order] = sort(ddpm(7,:),'descend');
% col = col(order,:);
figure;
subplot(1,2,1)
for ii = 1:13
    hb(ii) = bar(ii,dpm(ii),'linestyle','none','FaceColor',col(order == ii,:));
    hold on
end
set(gca,'XTick',1:13,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מתים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('תמותה למליון סך הכל')
subplot(1,2,2)
% yyaxis left
h = plot(datetime(2020,4:nMonths,1),ddpm,'linewidth',1);
shape = repmat({'o','s','^'},1,5);
for ii = 1:13
    h(ii).Color = hb(ii).FaceColor;
    h(ii).Marker = shape{order == ii};
    h(ii).MarkerFaceColor = h(ii).Color;
end
legend(h(order),pop.city(order),'location','northwest')
set(gcf,'Color','w')
xlim([datetime(2020,3,15) datetime(2020,3+size(ddpm,1),15)])
xlabel('חודש')
ylabel('מתים למליון')
set(gca,'xtick',datetime(2020,4:3+size(ddpm,1),1))
grid on
box off
title('תמותה למליון לחודש')
xtickformat('MMM')


figure;
subplot(1,2,1)
for ii = 1:13
    hb(ii) = bar(ii,cpm(ii),'linestyle','none','FaceColor',col(order == ii,:));
    hold on
end
% bar(cpm,'linestyle','none')
set(gca,'XTick',1:13,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מקרים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('מקרים למליון סך הכל')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
subplot(1,2,2)
h = plot(datetime(2020,4:nMonths,1),dcpm,'linewidth',1);
for ii = 1:13
    h(ii).Color = hb(ii).FaceColor;
    h(ii).Marker = shape{order == ii};
    h(ii).MarkerFaceColor = h(ii).Color;
end
legend(h(order),pop.city(order))
set(gcf,'Color','w')
xlim([datetime(2020,3,15) datetime(2020,3+size(ddpm,1),15)])
xlabel('חודש')
ylabel('מקרים למליון')
set(gca,'xtick',datetime(2020,4:3+size(ddpm,1),1))
grid on
box off
title('מקרים למליון לחודש')
xtickformat('MMM')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';


%%
json1 = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=64edd0ee-3d5d-43ce-8562-c336c24dbc1f&limit=5000');;
json = jsondecode(json1);
js = struct2cell(json.result.records);
popA = reshape([js{10:end,:}],7,size(js,2))';
[~,orderA] = sort(popA(:,1),'descend');
popA = popA(orderA,:);

cn = {json.result.records(orderA(1:15)).x_______}';
cn(2) = city(2);
[isx,idx] = ismember(strrep(city,' ',''),strrep(cn,' ',''));
pop13 = popA(idx,:);

ddpm = diff(death)./pop13(:,end)'*10^6;
dpm = death(end,:)./pop13(:,end)'*10^6;
dcpm = diff(cases)./pop13(:,end)'*10^6;
cpm = cases(end,:)./pop13(:,end)'*10^6;

% col = colormap(jet(13));
% col = flipud(col);
% [~,order] = sort(ddpm(7,:),'descend');
% col = col(order,:);
figure;
subplot(1,2,1)
for ii = 1:13
    hb(ii) = bar(ii,dpm(ii),'linestyle','none','FaceColor',col(order == ii,:));
    hold on
end
set(gca,'XTick',1:13,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מתים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('תמותה למליון סך הכל')
subplot(1,2,2)
% yyaxis left
h = plot(datetime(2020,4:size(ddpm,1)+3,1),ddpm,'linewidth',1);
shape = repmat({'o','s','^'},1,5);
for ii = 1:length(h)
    h(ii).Color = hb(ii).FaceColor;
    h(ii).Marker = shape{order == ii};
    h(ii).MarkerFaceColor = h(ii).Color;
end
legend(h(order),pop.city(order))
% hold on
% h2 = plot(datetime(2020,4:13,1),ddpm(:,9),'r','linewidth',2);
% legend([h1(1),h2],'ערים בישראל','בני ברק','location','northwest')
set(gcf,'Color','w')
xlim([datetime(2020,3,15) datetime(2020,3+size(ddpm,1),15)])
xlabel('חודש')
ylabel('מתים למליון')
set(gca,'xtick',datetime(2020,4:3+size(ddpm,1),1))
grid on
box off
title('תמותה למליון לחודש')
xtickformat('MMM')


figure;
subplot(1,2,1)
for ii = 1:13
    hb(ii) = bar(ii,cpm(ii),'linestyle','none','FaceColor',col(order == ii,:));
    hold on
end
% bar(cpm,'linestyle','none')
set(gca,'XTick',1:13,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מקרים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('מקרים למליון סך הכל')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
subplot(1,2,2)
h = plot(datetime(2020,4:size(dcpm,1)+3,1),dcpm,'linewidth',1);
for ii = 1:13
    h(ii).Color = hb(ii).FaceColor;
    h(ii).Marker = shape{order == ii};
    h(ii).MarkerFaceColor = h(ii).Color;
end
legend(h(order),pop.city(order))
set(gcf,'Color','w')
xlim([datetime(2020,3,15) datetime(2020,3+size(ddpm,1),15)])
xlabel('חודש')
ylabel('מקרים למליון')
set(gca,'xtick',datetime(2020,4:3+size(ddpm,1),1))
grid on
box off
title('מקרים למליון לחודש')
xtickformat('MMM')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';