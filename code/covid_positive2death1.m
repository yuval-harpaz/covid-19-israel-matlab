
tt112 = readtable('~/Downloads/corona_deceased_ver_00112.csv');
tt152 = readtable('~/Downloads/corona_deceased_ver_00152.csv');
p2d112 = cellfun(@str2num ,strrep(tt112.Time_between_positive_and_death,'NULL','-999'));
p2d112(p2d112 == -999) = nan;
p2d152 = cellfun(@str2num ,strrep(tt152.Time_between_positive_and_death,'NULL','-999'));
p2d152(p2d152 == -999) = nan;

ages = unique(tt112.Age_group);
clear Nmale112 male112 Nfemale112 female112 Nmale152 male152 Nfemale152 female152
mx = 50;
for ia = 1:length(ages)
    tmp = p2d112(ismember(tt112.Age_group,ages{ia}) & ismember(tt112.x_gender,'זכר'));
    tmp(tmp<0) = 0;
    tmp(tmp>mx) = mx;
    Nmale112(1,ia) = sum(~isnan(tmp));
    male112(1,ia) = nansum(tmp);
    tmp = p2d112(ismember(tt112.Age_group,ages{ia}) & ismember(tt112.x_gender,'נקבה'));
    tmp(tmp<0) = 0;
    tmp(tmp>mx) = mx;
    Nfemale112(1,ia) = sum(~isnan(tmp));
    female112(1,ia) = nansum(tmp);
    
    tmp = p2d152(ismember(tt152.Age_group,ages{ia}) & ismember(tt152.x_gender,'זכר'));
    tmp(tmp<0) = 0;
    tmp(tmp>mx) = mx;
    Nmale152(1,ia) = sum(~isnan(tmp));
    male152(1,ia) = nansum(tmp);
    tmp = p2d152(ismember(tt152.Age_group,ages{ia}) & ismember(tt152.x_gender,'נקבה'));
    tmp(tmp<0) = 0;
    tmp(tmp>mx) = mx;
    Nfemale152(1,ia) = sum(~isnan(tmp));
    female152(1,ia) = nansum(tmp);
end

M112 = male112./Nmale112;
F112 = female112./Nfemale112;
M152 = (male152-male112)./(Nmale152-Nmale112);
F152 = (female152-female112)./(Nfemale152-Nfemale112);

figure;
subplot(1,2,1)
bar([M112',F112'])
set(gca,'XTickLabel',ages,'ygrid','on')
legend('Male','Female')
title('average positive-to-death untill 20 Apr 2021')
box off

subplot(1,2,2)
bar([M152',F152'])
set(gca,'XTickLabel',ages,'ygrid','on')
legend('Male','Female')
title('average positive-to-death since 20 Apr 2021')
box off


