function covid_exp_fit1(logscale)
if nargin == 0
    logscale = true;
end
cd /home/innereye/covid-19-israel-matlab
listName = '/home/innereye/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv';
list = readtable(listName);
list.deceased = nan(height(list),1);
list.deceased =list.CountDeath;
i1 = find(~isnan(list.CountHospitalized),1);
list = list(i1:end,:);
fid = fopen('data/Israel/dashboard.json','r');
txt = fread(fid)';
fclose(fid);
txt = native2unicode(txt);
listE = list;
list = listE(1:end-1,:);
cco = [91, 163, 0; 137, 206, 0; 0, 115, 230; 230, 48, 148; 181, 25, 99; 0,0,0]/255;
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
cases = cases(ismember(cases.date,list.date),:);
y60 = zeros(length(list.tests_positive1),1);
y60(ismember(list.date,cases.date)) = sum(cases{:,3:5},2);
yy = [list.tests_positive1, y60,list.new_hospitalized, [0;diff(list.CountSeriousCriticalCum)]];
yy(2:end,5) = diff(list.CountBreathCum);
yy(:,6) = list.CountDeath;
% yy = yy(1:end-1,:);
last3 = yy(end-2:end,:);
yy = movmean(yy,[3 3]);
yy(1:324,2) = nan;
c = 0;
c = c+1;
exp_date(c,:) = [datetime(2020,6,22) datetime(2020,7,9)]; % wave II up
c = c+1;
exp_date(c,:) = [datetime(2020,8,23) datetime(2020,9,22)]; % wave II up again
c = c+1;
exp_date(c,:) = [datetime(2020,10,7) datetime(2020,10,26)]; % wave 2 down
c = c+1;
exp_date(c,:) = [datetime(2020,11,28) datetime(2021,1,3)]; % wave 3 up
c = c+1;
exp_date(c,:) = [datetime(2021,3,18) datetime(2021,4,30)]; % wave 3 down
c = c+1;
exp_date(c,:) = [datetime(2021,7,3) datetime(2021,7,28)]; % wave 4 up
c = c+1;
exp_date(c,:) = [datetime(2021,10,3) datetime(2021,10,25)]; % wavr IV down
c = c+1;
exp_date(c,:) = [datetime(2021,12,24) datetime(2022,1,7)]; % wave V up
c = c+1;
exp_date(c,:) = [datetime(2022,2,3) datetime(2022,2,25)]; % wave V down
c = c+1;
exp_date(c,:) = [datetime(2022,3,16) datetime(2022,3,21)]; % wave V up
c = c+1;
exp_date(c,:) = [datetime(2022,4,6) datetime(2022,4,14)]; % wave V up
c = c+1;
exp_date(c,:) = [datetime(2022,6,3) datetime(2022,6,10)]; % wave VI up
c = c+1;
% exp_date(c,:) = [datetime(2022,7,15) datetime('today')-4]; % wave VI down
exp_date(c,:) = [datetime(2022,7,15) datetime(2022,7,31)]; % wave VI down
c = c+1;
exp_date(c,:) = [datetime(2022,8,10) datetime(2022,8,22)]; % wave VI down
c = c+1;
exp_date(c,:) = [datetime(2022,11,4) datetime(2022,11,20)]; % wave VI down
% exp_date(c,:) = [datetime('today')-11 datetime('today')-4]; % wave VI down
%%
figure('units','normalized','position',[0,0,0.5,1]);
hh = plot(list.date(1:end-3), yy(1:end-3,:), 'linewidth', 1.5);
for ii = 1:6
    hh(ii).Color = cco(ii,:);
end
hold on
hhd = plot(list.date(end-2:end), last3,'.','markersize',8);
for ii = 1:length(hh)
    hhd(ii).Color = hh(ii).Color;
end
grid on
box off
set(gcf,'Color','w')
grid minor
set(gca,'fontsize',13,'XTick',datetime(2020,3:50,1))
% xlim([list.date(1) datetime('tomorrow')+14])
xtickformat('MMM')
x1 = datetime(2021,12,1);
xlim([x1 datetime('today')+14])
ylabel('Cases, patients  מאומתים, מאושפזים')
if logscale
    bias = [0,0,0,7,7,7];
    for iPoint = 8:size(exp_date,1)
        %     if iPoint == size(exp_date,1)
        %         bias(:) = 0;  % no 7 days forward for today
        %     end
        for pr = 1:4
            yDot = yy(find(ismember(list.date, exp_date(iPoint,:)+bias(pr))),pr);
            if length(yDot) == 2
                scatter(exp_date(iPoint,:)+bias(pr),yDot,30,hh(pr).Color,'fill')
                rat = (yDot(2)/yDot(1))^(1/days(diff(exp_date(iPoint,:))))^7;
                aln = 'right';
                %     pref = '+';
                txt = str(round(rat,1));
                if rat < 1
                    %         pref = '+';
                    aln = 'left';
                    txt = [str(round(1/rat,1)),'^{-1}'];
                end
                
                text(mean(exp_date(iPoint,:))+bias(pr),mean(yDot),txt,'HorizontalAlignment', aln,'Color',hh(pr).Color)
            end
        end
    end
    set(gca, 'YScale', 'log')
    ylim([1 100000])
    title('Cases and new hospitalizations   מאומתים ומאושפזים חדשים')
    legend('cases            מאומתים','cases   60+  מאומתים','hospitalized מאושפזים','severe                קשה',...
        'ventilated      מונשמים','deceased        נפטרים','location','northeast')
    text(x1,0.3,['המספרים על הגרף מייצגים קצב הכפלה שבועי עבור מאומתים וחולים חדשים',newline,'Weekly multiplication factor for new cases and patients'],'FontSize',13);
else
    ylim([0 250])
    title('New hospitalizations   מאושפזים חדשים')
    hh(1).LineStyle = 'None';
    hh(2).LineStyle = 'None';
    legend(hh(3:end),'hospitalized מאושפזים','severe                קשה',...
        'ventilated      מונשמים','deceased        נפטרים','location','north')
    ylabel('patients')
end
for ii = 1:size(yy,2)
    text(datetime('today')+ii, yy(end-3,ii),str(round(yy(end-3,ii),1)),'Color',hh(ii).Color);
end
end