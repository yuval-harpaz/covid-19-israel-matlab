
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');

!wget -O tmp.json --no-check-certificate https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily 
fid = fopen('tmp.json','r');
txt = fread(fid)';
fclose(fid);
json = native2unicode(txt);
% json = urlread('https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily');
json = jsondecode(json);
cases = struct2table(json);
cases.day_date = datetime(strrep(cases.day_date,'T00:00:00.000Z',''));
cases.Properties.VariableNames{1} = 'date';
cOld = ismember(cases.age_group,'מעל גיל 60');
cases = cases(cOld,:);
cases = cases(ismember(cases.date,listD.date),:);
y60 = zeros(length(listD.tests_positive1),1);
y60(ismember(listD.date,cases.date)) = sum(cases{:,3:5},2);

cco = [91, 163, 0; 137, 206, 0; 0, 115, 230; 230, 48, 148; 181, 25, 99; 0,0,0]/255;

R = covid_R31(listD.tests_positive1);
R(:,2) = covid_R31(y60);
R(:,3) = covid_R31(listD.new_hospitalized);
R(:,4) = covid_R31([0;diff(listD.CountSeriousCriticalCum)]);
shift = [0, 0, 2, 5];
figure;
for ll = 1:4
    hh(ll) = plot(listD.date(19:end-11)-shift(ll), R(26:end-4,ll),'-', 'LineWidth', 2);
    hh(ll).Color = cco(ll,:);
    hold on
end
line([listD.date(1) listD.date(end)], [1 1],'Color','k','linestyle','--')
% xlim([datetime(2021,7,1) datetime('today')])
xlim([datetime(2021,12,1) datetime('today')+14])
grid on
ylabel('R');
%     xlabel('Date');
legend(hh,'Cases','cases 60+','Hospital admissions','Severe cases','Location', 'Northeast');
title('R for cases and hospitalizations');
grid on
ylim([0.5 2.3])

% hh(1).Color = [0.106 0.62 0.467];
% hh(2).Color = hh(1).Color*1.25;
% hh(3).Color = [0.455 0.435 0.698];
% hh(4).Color = [0.851 0.373 0.008];
set(gca,'YTick',[0.6,0.8:0.1:1.2,1.4:0.2:2.2])
set(gcf,'Color','w')
%     else
%         plot(R, 'LineWidth', 2, 'DisplayName', 'R');
%     end
% end
