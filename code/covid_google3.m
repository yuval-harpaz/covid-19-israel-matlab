
% countryName = countryName(order(1:10),:);
% cc = {'AE','United Arab Emirates';'AF','Afghanistan';'AG','Antigua and Barbuda';'AO','Angola';'AR','Argentina';'AT','Austria';'AU','Australia';'AW','Aruba';'BA','Bosnia and Herzegovina';'BB','Barbados';'BD','Bangladesh';'BE','Belgium';'BF','Burkina Faso';'BG','Bulgaria';'BH','Bahrain';'BJ','Benin';'BO','Bolivia';'BR','Brazil';'BS','The Bahamas';'BW','Botswana';'BY','Belarus';'BZ','Belize';'CA','Canada';'CH','Switzerland';'CI','Côte d''Ivoire';'CL','Chile';'CM','Cameroon';'CO','Colombia';'CR','Costa Rica';'CV','Cape Verde';'CZ','Czechia';'DE','Germany';'DK','Denmark';'DO','Dominican Republic';'EC','Ecuador';'EE','Estonia';'EG','Egypt';'ES','Spain';'FI','Finland';'FJ','Fiji';'FR','France';'GA','Gabon';'GB','United Kingdom';'GE','Georgia';'GH','Ghana';'GR','Greece';'GT','Guatemala';'GW','Guinea-Bissau';'HK','Hong Kong';'HN','Honduras';'HR','Croatia';'HT','Haiti';'HU','Hungary';'ID','Indonesia';'IE','Ireland';'IL','Israel';'IN','India';'IQ','Iraq';'IT','Italy';'JM','Jamaica';'JO','Jordan';'JP','Japan';'KE','Kenya';'KG','Kyrgyzstan';'KH','Cambodia';'KR','South Korea';'KW','Kuwait';'KZ','Kazakhstan';'LA','Laos';'LB','Lebanon';'LI','Liechtenstein';'LK','Sri Lanka';'LT','Lithuania';'LU','Luxembourg';'LV','Latvia';'LY','Libya';'MA','Morocco';'MD','Moldova';'MK','North Macedonia';'ML','Mali';'MM','Myanmar (Burma)';'MN','Mongolia';'MT','Malta';'MU','Mauritius';'MX','Mexico';'MY','Malaysia';'MZ','Mozambique';'NA','Namibia';'NE','Niger';'NG','Nigeria';'NI','Nicaragua';'NL','Netherlands';'NO','Norway';'NP','Nepal';'NZ','New Zealand';'OM','Oman';'PA','Panama';'PE','Peru';'PG','Papua New Guinea';'PH','Philippines';'PK','Pakistan';'PL','Poland';'PR','Puerto Rico';'PT','Portugal';'PY','Paraguay';'QA','Qatar';'RE','Réunion';'RO','Romania';'RS','Serbia';'RU','Russia';'RW','Rwanda';'SA','Saudi Arabia';'SE','Sweden';'SG','Singapore';'SI','Slovenia';'SK','Slovakia';'SN','Senegal';'SV','El Salvador';'TG','Togo';'TH','Thailand';'TJ','Tajikistan';'TR','Turkey';'TT','Trinidad and Tobago';'TW','Taiwan';'TZ','Tanzania';'UA','Ukraine';'UG','Uganda';'US','United States';'UY','Uruguay';'VE','Venezuela';'VN','Vietnam';'YE','Yemen';'ZA','South Africa';'ZM','Zambia';'ZW','Zimbabwe'};
% [isx,idx] = ismember(countryName(:,2),cc(:,2));
% if any(isx)
%     warning('some countries not found')
%     disp(countryName(isx == 0,2))
% end
% cc = cc(idx,:);
cd ~/covid-19-israel-matlab/data/
% [~,~] = system('wget -O tmp.zip https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip');
% unzip('tmp.zip','tmp')
% !rm tmp.zip
cd tmp



t = readtable(['2020_IL_Region_Mobility_Report.csv']); 
iEnd = find(cellfun(@isempty,t.sub_region_1),1,'last');
glob = t{1:iEnd,9:end};
glob = movmean(movmedian(glob,[3 3]),[3 3]);
%     mob = mob./(-min(mob));
glob = mean(glob(:,[1,4,5]),2);
       




FIXME read tests
yy(yy < 1/3) = 0;

for ii = 2:length(yy)
    d1(ii,1:150) = yy(ii,:)./yy(ii-1,:);
end
for ii = 2:length(yy)-1
    d2(ii,1:150) = (yy(ii+1,:)-yy(ii-1,:))./yy(ii-1,:)./2+1;
end
d1(isinf(d1)) = nan;
d1(d1 == 0) = 1;
d1(isnan(d1)) = 1;
d1s = movmean(d1,[3 3],'omitnan');
figure;
plot(timeVector,d1s(:,isr))
hold on
plot(t.date(1:iEnd),(glob(:,11) < -25)/10+1)
