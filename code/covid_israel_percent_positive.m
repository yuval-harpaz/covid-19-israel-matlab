function covid_israel_percent_positive(saveFigs)
if nargin == 0
    saveFigs = false;
end
cd ~/covid-19-israel-matlab/
%% get hiSmallerory
list = readtable('data/Israel/dashboard_timeseries.csv');
lastValid = find(~isnan(list.new_hospitalized),1,'last');
idx = 27:lastValid;
fig = figure('position',[50,50,800,500]);
yyaxis left
plot(list.date(idx),list.tests_result(idx));
ylabel('tests')
ax = gca;
ax.YRuler.Exponent = 0;
yyaxis right
plot(list.date(idx),round(100*list.tests_positive(idx)./list.tests_result(idx),1))
ylabel('positive tests (%)')
set(gca,'ygrid', 'on','fontsize',13)
box off
xlim([list.date(idx(1))-1 list.date(idx(end))+1]);


hospSmooth = movmean(list.new_hospitalized(idx),[3 3]);
hospSmooth(end) = nan;
hospSmooth(end-1) = mean(list.new_hospitalized(idx(end-4:end-1)));
hospSmooth(end-2) = mean(list.new_hospitalized(idx(end-5:end-1)));
hospSmooth(end-3) = mean(list.new_hospitalized(idx(end-6:end-1)));
pos = round(100*list.tests_positive(idx)./list.tests_result(idx),1);
pos1 = pos;
pos1(80:85) = linspace(pos(80),pos(85),6);
posSmooth = movmean(pos1,[3 3]);
posSmooth(end) = nan;
posSmooth(end-1) = mean(pos(end-4:end-1));
posSmooth(end-2) = mean(pos(end-5:end-1));
posSmooth(end-3) = mean(pos(end-6:end-1));

fig1 = figure('position',[50,50,800,500]); %#ok<NASGU>
yyaxis left
plot(list.date(idx),list.new_hospitalized(idx),'.');
hold on
hh(1) = plot(list.date(idx),hospSmooth,'linewidth',2,'linestyle','-');
ylabel('מאושפזים חדשים')
ax = gca;
ax.YRuler.Exponent = 0;
yyaxis right
plot(list.date(idx),pos,'.')
hold on
hh(2) = plot(list.date(idx),posSmooth,'linewidth',2,'linestyle','-');
ylabel('בדיקות חיוביות (%)')
set(gca,'ygrid', 'on','fontsize',13)
xlim([list.date(idx(1))-1 list.date(idx(end))+1]);
set(gcf,'Color','w')
ylim([0 15])
grid minor
box off
title('אחוז הבדיקות החיוביות ומספר המאושפזים החדשים')
legend(hh,'מאושפזים','בדיקות חיוביות','location','north')

if saveFigs
    saveas(fig,'docs/percent_positive.png');
    saveas(fig1,'docs/positiveVShosp.png');
    % update html
    pp = str(round(100*list.tests_positive(idx(end))./list.tests_result(idx(end)),1));
    fName = 'docs/myCountry.html';
    fid = fopen(fName,'r');
    txt = fread(fid);
    fclose(fid);
    txt = native2unicode(txt');
    iSpace = strfind(txt,' ');
    iPos = strfind(txt,'% מהתוצאות');
    iSpace = iSpace(find(iSpace < iPos,1,'last'):find(iSpace > iPos,1));
    txt = [txt(1:iSpace(1)),pp,'%',txt(iSpace(2):end)];
    
    pp = str(round(mean(100*list.tests_positive(idx(end-6:end))./list.tests_result(idx(end-6:end))),1));
    iPos = strfind(txt,'ממוצע שבועי');
    iSpace = strfind(txt,' ');
    iSpace = iSpace(find(iSpace > iPos,3));
    txt = [txt(1:iSpace(2)),pp,'%',txt(iSpace(3):end)];
    
    txt = unicode2native(txt);
    fid = fopen(fName,'w');
    fwrite(fid,txt);
    fclose(fid);
end

deathSmooth = movmean(list.CountDeath,[3 3]);
deathSmooth(end) = nan;
deathSmooth(end-1) = mean(list.CountDeath(end-4:end-1));
deathSmooth(end-2) = mean(list.CountDeath(end-5:end-1));
deathSmooth(end-3) = mean(list.CountDeath(end-6:end-1));
lag = 12;
fig2 = figure('position',[50,50,800,500]);
plot(list.date,list.CountDeath,':k','linewidth',1)
hold on
plot(list.date,deathSmooth,'k','linewidth',2)
hh = plot(list.date(idx(1:end-lag-1))+lag,hospSmooth(1:end-lag-1)/10,'linewidth',2);
hp = plot(list.date(idx(1:end-lag-1))+lag,posSmooth(1:end-lag-1)*1.5,'linewidth',2);
plot(list.date(idx(end-lag:end))+lag,hospSmooth(end-lag:end)/10,':','linewidth',2,'Color',hh.Color)
plot(list.date(idx(end-lag:end))+lag,posSmooth(end-lag:end)*1.5,':','linewidth',2,'Color',hp.Color)
legend('Deaths','Deaths (7 day average)','Deaths predicted by new hospitalized / 10',...
    'Deaths predicted by %positive x 1.5','location','Northwest')
grid on
box off
ylabel('Deaths')
title('Predicting daily deaths in Israel 12 days ahead')
iTick = find(list.date(1:end-1) == dateshift(list.date(1:end-1),'start','month'));
set(gca,'fontsize',13,'XTick',unique([list.date(iTick);list.date(end-1);list.date(end)+11]))
xtickangle(90)
xlim([list.date(idx(1)) list.date(idx(end))+lag])
