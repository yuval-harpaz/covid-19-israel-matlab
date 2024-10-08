function glob = covid_google2(mustHave,eng)

mustHave = IEdefault('mustHave','Israel');
eng = IEdefault('eng',false);


[fig,timeVector,yy,countryName,order] = covid_plot_who(1,1,0,mustHave,eng);

xlim([datetime(2020,2,15) datetime('today')]);
% [fig,timeVector,yy,countryName,order] = covid_plot_heb(1,1,0,mustHave);
iMust = find(order == find(ismember(countryName(:,2),mustHave)));
countryName = countryName(order(1:10),:);
cc = {'AE','United Arab Emirates';'AF','Afghanistan';'AG','Antigua and Barbuda';'AO','Angola';'AR','Argentina';'AT','Austria';'AU','Australia';'AW','Aruba';'BA','Bosnia and Herzegovina';'BB','Barbados';'BD','Bangladesh';'BE','Belgium';'BF','Burkina Faso';'BG','Bulgaria';'BH','Bahrain';'BJ','Benin';'BO','Bolivia';'BR','Brazil';'BS','The Bahamas';'BW','Botswana';'BY','Belarus';'BZ','Belize';'CA','Canada';'CH','Switzerland';'CI','Côte d''Ivoire';'CL','Chile';'CM','Cameroon';'CO','Colombia';'CR','Costa Rica';'CV','Cape Verde';'CZ','Czechia';'DE','Germany';'DK','Denmark';'DO','Dominican Republic';'EC','Ecuador';'EE','Estonia';'EG','Egypt';'ES','Spain';'FI','Finland';'FJ','Fiji';'FR','France';'GA','Gabon';'GB','UK';'GE','Georgia';'GH','Ghana';'GR','Greece';'GT','Guatemala';'GW','Guinea-Bissau';'HK','Hong Kong';'HN','Honduras';'HR','Croatia';'HT','Haiti';'HU','Hungary';'ID','Indonesia';'IE','Ireland';'IL','Israel';'IN','India';'IQ','Iraq';'IT','Italy';'JM','Jamaica';'JO','Jordan';'JP','Japan';'KE','Kenya';'KG','Kyrgyzstan';'KH','Cambodia';'KR','South Korea';'KW','Kuwait';'KZ','Kazakhstan';'LA','Laos';'LB','Lebanon';'LI','Liechtenstein';'LK','Sri Lanka';'LT','Lithuania';'LU','Luxembourg';'LV','Latvia';'LY','Libya';'MA','Morocco';'MD','Moldova';'MK','North Macedonia';'ML','Mali';'MM','Myanmar (Burma)';'MN','Mongolia';'MT','Malta';'MU','Mauritius';'MX','Mexico';'MY','Malaysia';'MZ','Mozambique';'NA','Namibia';'NE','Niger';'NG','Nigeria';'NI','Nicaragua';'NL','Netherlands';'NO','Norway';'NP','Nepal';'NZ','New Zealand';'OM','Oman';'PA','Panama';'PE','Peru';'PG','Papua New Guinea';'PH','Philippines';'PK','Pakistan';'PL','Poland';'PR','Puerto Rico';'PT','Portugal';'PY','Paraguay';'QA','Qatar';'RE','Réunion';'RO','Romania';'RS','Serbia';'RU','Russia';'RW','Rwanda';'SA','Saudi Arabia';'SE','Sweden';'SG','Singapore';'SI','Slovenia';'SK','Slovakia';'SN','Senegal';'SV','El Salvador';'TG','Togo';'TH','Thailand';'TJ','Tajikistan';'TR','Turkey';'TT','Trinidad and Tobago';'TW','Taiwan';'TZ','Tanzania';'UA','Ukraine';'UG','Uganda';'US','USA';'UY','Uruguay';'VE','Venezuela';'VN','Vietnam';'YE','Yemen';'ZA','South Africa';'ZM','Zambia';'ZW','Zimbabwe'};
[isx,idx] = ismember(countryName(:,2),cc(:,2));
if any(~isx)
    warning('some countries not found')
    disp(countryName(isx == 0,2))
end
% cc = cc(idx,:);
cd ~/covid-19-israel-matlab/data/
% [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
% unzip('tmp.zip','tmp')
% !rm tmp.zip
dateCheck = dir('tmp/2021_BF_Region_Mobility_Report.csv');
if now-datenum(dateCheck.date) > 7
    [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
    unzip('tmp.zip','tmp')
    !rm tmp.zip
end
cd tmp


ini = cell(11,1);
switch mustHave
    case 'Israel'
        ini{11} = 'IL';
        countryName{11,1} = 'ישראל';
        countryName{11,2} = 'Israel';
    case 'Sweden'
        ini{11} = 'SE';
        countryName{11,1} = 'שבדיה';
        countryName{11,2} = 'Sweden';
    case 'USA'
        ini{11} = 'US';
        countryName{11,1} = 'ארה"ב';
        countryName{11,2} = 'USA';
    case 'Iran'
        ini{11} = 'BR';
        error('me Brazil')
        countryName{11,1} = 'איראן';
        countryName{11,2} = 'Iran';
    case 'Belarus'
        ini{11} = 'BY';
        countryName{11,1} = 'בלרוס';
        countryName{11,2} = 'Belarus';
    case 'Slovakia'
        ini{11} = 'SK';
        countryName{11,1} = 'סלובקיה';
        countryName{11,2} = 'Slovakia';
    case 'Ireland'
        ini{11} = 'IE';
        countryName{11,1} = 'אירלנד';
        countryName{11,2} = 'Ireland';
    case 'Belgium'
        ini{11} = 'BE';
        countryName{11,1} = 'בלגיה';
        countryName{11,2} = 'Belgium';
    case 'UK'
        ini{11} = 'GB';
        countryName{11,1} = 'בריטניה';
        countryName{11,2} = 'UK';
    case 'India'
        ini{11} = 'IN';
        countryName{11,1} = 'הודו';
        countryName{11,2} = 'India';
        
end
ini(isx) = cc(idx(isx),1);

for ii = [11,1:10]
    if isempty(ini{ii})
        glob(:,ii) = nan;
    else
        t2020 = readtable(['2020_',ini{ii},'_Region_Mobility_Report.csv']);
        t2021 = readtable(['2021_',ini{ii},'_Region_Mobility_Report.csv']);
        if iscell(t2020.sub_region_1(1))
            t = [t2020(cellfun(@isempty,t2020.sub_region_1),:);t2021(cellfun(@isempty,t2021.sub_region_1),:)];
            if iscell(t.metro_area(1))
                t = t(cellfun(@isempty,t.metro_area),:);
            end
        else
            t = [t2020;t2021];
        end
        if ~exist('date','var')
            date = t.date;
        end
        if ~isequal(unique(date),date)
            error('dates not unique or not sorted')
        end
        if ~isequal(t.date,date)
            error('dates mismatch')
        end
        mob = t{:,10:end};
        mob = movmean(movmedian(mob,[3 3]),[3 3]);
    %     mob = mob./(-min(mob));
        mob = mean(mob(:,[1,4,5]),2);
        glob(1:length(mob),ii) = mob;
    end
end


co = hsv(10);
co(3,:) = co(3,:)*0.75;
co(4,2) = 0.7;
co(11,1:3) = 0;

figure('units','normalized','position',[0,0,0.5,0.5]);
h = plot(date,glob,'linewidth',1);
for ii = 1:11
    h(ii).Color = co(ii,:);
end
xlim([t.date(1) datetime('today')])
box off
grid on
if eng
    ylabel('change compared to baseline (%)')
    title('Google mobility report')
else
    ylabel('שינוי ביחס לשגרה (%)')
    title('מדד התנועתיות של גוגל')
end
set(gcf,'Color','w')

yt = linspace(10,-40,11);
if eng
    lang = 2;
else
    lang = 1;
end
for iAnn = 1:11
    text(length(glob),yt(iAnn),countryName{iAnn,lang},...
        'FontSize',10,'Color',h(iAnn).Color,'FontWeight','bold');
end
xtickformat('MMM')
set(gca,'XTick',datetime(2020,3:25,1),'FontSize',13)
%%
% yy(yy < 1/3) = 0;
% 
% for ii = 2:length(yy)
%     d1(ii,1:size(yy,2)) = yy(ii,:)./yy(ii-1,:);
% end
% for ii = 2:length(yy)-1
%     d2(ii,1:size(yy,2)) = (yy(ii+1,:)-yy(ii-1,:))./yy(ii-1,:)./2+1;
% end
% d1(isinf(d1)) = nan;
% d1(d1 == 0) = 1;
% d1(isnan(d1)) = 1;
% d1s = movmean(d1,[3 3],'omitnan');
% figure;
% plot(timeVector,d1s(:,iMust))
% hold on
% plot(t.date(1:iEnd),(glob(:,11) < -25)/10+1)
