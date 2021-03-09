function covid_seger(mustHave,eng)

mustHave = IEdefault('mustHave','Israel');
eng = IEdefault('eng',false);


[fig,timeVector,yy,countryName,order] = covid_plot_who(1,1,0,mustHave,false);
close;
countryName = countryName(order,:);

cc = {'AE','United Arab Emirates';'AF','Afghanistan';'AG','Antigua and Barbuda';'AO','Angola';'AR','Argentina';'AT','Austria';'AU','Australia';'AW','Aruba';'BA','Bosnia and Herzegovina';'BB','Barbados';'BD','Bangladesh';'BE','Belgium';'BF','Burkina Faso';'BG','Bulgaria';'BH','Bahrain';'BJ','Benin';'BO','Bolivia';'BR','Brazil';'BS','The Bahamas';'BW','Botswana';'BY','Belarus';'BZ','Belize';'CA','Canada';'CH','Switzerland';'CI','Côte d''Ivoire';'CL','Chile';'CM','Cameroon';'CO','Colombia';'CR','Costa Rica';'CV','Cape Verde';'CZ','Czechia';'DE','Germany';'DK','Denmark';'DO','Dominican Republic';'EC','Ecuador';'EE','Estonia';'EG','Egypt';'ES','Spain';'FI','Finland';'FJ','Fiji';'FR','France';'GA','Gabon';'GB','UK';'GE','Georgia';'GH','Ghana';'GR','Greece';'GT','Guatemala';'GW','Guinea-Bissau';'HK','Hong Kong';'HN','Honduras';'HR','Croatia';'HT','Haiti';'HU','Hungary';'ID','Indonesia';'IE','Ireland';'IL','Israel';'IN','India';'IQ','Iraq';'IT','Italy';'JM','Jamaica';'JO','Jordan';'JP','Japan';'KE','Kenya';'KG','Kyrgyzstan';'KH','Cambodia';'KR','South Korea';'KW','Kuwait';'KZ','Kazakhstan';'LA','Laos';'LB','Lebanon';'LI','Liechtenstein';'LK','Sri Lanka';'LT','Lithuania';'LU','Luxembourg';'LV','Latvia';'LY','Libya';'MA','Morocco';'MD','Moldova';'MK','North Macedonia';'ML','Mali';'MM','Myanmar (Burma)';'MN','Mongolia';'MT','Malta';'MU','Mauritius';'MX','Mexico';'MY','Malaysia';'MZ','Mozambique';'NA','Namibia';'NE','Niger';'NG','Nigeria';'NI','Nicaragua';'NL','Netherlands';'NO','Norway';'NP','Nepal';'NZ','New Zealand';'OM','Oman';'PA','Panama';'PE','Peru';'PG','Papua New Guinea';'PH','Philippines';'PK','Pakistan';'PL','Poland';'PR','Puerto Rico';'PT','Portugal';'PY','Paraguay';'QA','Qatar';'RE','Réunion';'RO','Romania';'RS','Serbia';'RU','Russia';'RW','Rwanda';'SA','Saudi Arabia';'SE','Sweden';'SG','Singapore';'SI','Slovenia';'SK','Slovakia';'SN','Senegal';'SV','El Salvador';'TG','Togo';'TH','Thailand';'TJ','Tajikistan';'TR','Turkey';'TT','Trinidad and Tobago';'TW','Taiwan';'TZ','Tanzania';'UA','Ukraine';'UG','Uganda';'US','USA';'UY','Uruguay';'VE','Venezuela';'VN','Vietnam';'YE','Yemen';'ZA','South Africa';'ZM','Zambia';'ZW','Zimbabwe'};
[isx,idx] = ismember(countryName(:,2),cc(:,2));
countryName(~isx,:) = [];
idx(~isx) = [];
yy(:,~isx) = [];
inclusion = 5; % countries with more than 200 deaths per million
included = max(yy) > inclusion;

countryName = countryName(included,:);
idx = idx(included);
yy = yy(:,included);

% 
% if any(~isx)
%     warning('some countries not found')
%     disp(countryName(isx == 0,2))
% end
% 
% % cc = cc(idx,:);
cd ~/covid-19-israel-matlab/data/
% [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
% unzip('tmp.zip','tmp')
% !rm tmp.zip
dateCheck = dir('tmp/2020_BF_Region_Mobility_Report.csv');
if now-datenum(dateCheck.date) > 3
    tx = input('download Google?','s');
    if strcmp(tx,'y')
        [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
        unzip('tmp.zip','tmp')
        !rm tmp.zip
    end
end
cd tmp

disp(['reading mobility ',str(length(idx))])
for ii = 1:length(idx)
    t = readtable(['2020_',cc{idx(ii)},'_Region_Mobility_Report.csv']);
    if ii == 1
        try
            iEnd = find(cellfun(@isempty,t.sub_region_1),1,'last');
        catch
            iEnd = find(isnan(t.sub_region_1),1,'last');
        end
        date = t.date(1:iEnd);
    end
    mob = t{1:iEnd,10:end};
    mob = movmean(movmedian(mob,[3 3]),[3 3]);
    %     mob = mob./(-min(mob));
    mob = -1*mob(:,end);
%     mob = mean(mob(:,[1,4,5]),2);
    glob(1:length(mob),ii) = mob;
    IEprog(ii)
end

%%
nDays = 14;
loss = -1;
seger = 5;
[~,ord] = sort(max(yy),'descend');
difs = [];
figure;
for ip = 1:length(idx)
    isp = ord(ip);
    ggl = -glob(:,isp);
    dead = yy(:,isp);
    dead = movmean(dead,[3 3]);
    xSlope = find(dead(nDays+1:end)-dead(1:end-nDays) < loss);
    for is = length(xSlope):-1:2
        if xSlope(is)-xSlope(is-1) < 30
            xSlope(is) = [];
        end
    end
    xSeger = find(ggl(nDays+1:end)-ggl(1:end-nDays) > seger)+nDays;
    for is = length(xSeger):-1:2
        if xSeger(is)-xSeger(is-1) < 30
            xSeger(is) = [];
        end
    end
    if ~isempty(xSlope)
        if isempty(xSeger)
            difs = [difs;nan];
        else
            for id = 1:length(xSlope)
                dss = date(xSeger);
                dd = find(timeVector(xSlope(id)) > dss,1,'last');
                if isempty(dd)
                    difs = [difs;nan];
                else
                    difs = [difs;datenum(timeVector(xSlope(id))-dss(dd))];
                end
            end
        end
    end
    subplot(7,7,ip+1)
    yyaxis left
    plot(date,ggl)
    ylim([0 50])
    if ~isempty(xSeger)
        hold on
        plot(date(xSeger),ggl(xSeger),'kd')
    end
    
    yyaxis right
    plot(timeVector,dead);
    if ~isempty(xSlope)
        hold on
        plot(timeVector(xSlope),dead(xSlope),'g*')
    end
    ylim([0 30])
    title(countryName{isp,2})
    axis off
    
end

subplot(7,7,1)
yyaxis left
plot(1:2,nan(2,1))
hold on
plot(1,nan,'kd')
yyaxis right
plot(1:2,nan(2,1));
hold on
plot(1,nan,'g*')
legend('stay-at-home','lockdown','deaths','deaths plummet')
set(gcf,'Color','w')
disp('karamba')
axis off
set(gca,'fontsize',13)
difsss = difs;
difsss(difsss > 55) = nan;

subplot(7,7,49)
yyaxis left
plot(1:2,nan(2,1))
hold on
plot(1,nan,'kd')
set(gca,'ytick',[0,1],'yticklabel',{'0','50'})
% ylabel('% change')
yyaxis right
plot(1:2,nan(2,1));
hold on
plot(1,nan,'g*')
set(gcf,'Color','w')
disp('karamba')
box off
set(gca,'Xtick',[0 1],'XTickLabel',datestr([datetime(2020,2,15) timeVector(end)]),...
    'ytick',[0,1],'yticklabel',{'0','30'})
set(gca,'fontsize',13)


difsss = difs;
difsss(difsss > 55) = nan;


[yyy,xxx] = hist(-difsss(~isnan(difsss)),-49:7:-7);
figure;
bar(xxx,yyy/length(difs)*100,0.95,'edgecolor','none')
ylabel('probability (%)')
xlabel('lag (days)')
set(gca,'ygrid','on')
title({'probability to have increased stay-at-home','before a decline in mortality'})
set(gcf,'Color','w')
ylim([0 25])

mean(isnan(difsss))
% figure;
% yyaxis left
% plot(date,-glob(:,1))
% yyaxis right
% plot(timeVector(2:end),diff(yy(:,1)))

