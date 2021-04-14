function ps = covid_israel_percent_positive(saveFigs)
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
h2(1) = plot(list.date(idx),list.tests_result(idx));
ylabel('tests')
ax = gca;
ax.YRuler.Exponent = 0;
yyaxis right
plot(list.date(idx),round(100*list.tests_positive(idx)./list.tests_result(idx),1),':')
ylabel('positive tests (%)')
set(gca,'ygrid', 'on','fontsize',13)
box off
xlim([list.date(idx(1))-1 list.date(idx(end))+1]);

hospSmooth = smot(list.new_hospitalized(idx))

pos = round(100*list.tests_positive(idx)./list.tests_result(idx),1);
pos1 = pos;
pos1(80:85) = linspace(pos(80),pos(85),6);
posSmooth = smot(pos1);
% posMagen = round(100*list.tests_positive(idx)./(list.tests_result(idx)-list.tests_survey(idx)),1);
% posMagenSmooth = smot(posMagen);
hold on
dateSmooth = list.date(idx);
ps = table(dateSmooth,posSmooth);
h2(2) = plot(dateSmooth,posSmooth,'-','linewidth',2);
% h2(3) = plot(dateSmooth,posMagenSmooth,'-','linewidth',1,'Color','r');
xtickformat('MMM')
legend(h2,'tests                      בדיקות','positive (%) בדיקות חיוביות','location','northwest')
title('Tests and positive tests (%) בדיקות ובדיקות חיוביות ')
set(gca,'xtick',datetime(2020,3:30,1))

fig1 = figure('position',[50,50,800,500]); %#ok<NASGU>
yyaxis left
plot(list.date(idx),list.new_hospitalized(idx),'.');
hold on
hh(1) = plot(list.date(idx),hospSmooth,'linewidth',2,'linestyle','-');
ylabel(['new hospitalized     ','מאושפזים חדשים'])
ax = gca;
ax.YRuler.Exponent = 0;
yyaxis right
plot(list.date(idx),pos,'.')
hold on
hh(2) = plot(list.date(idx),posSmooth,'linewidth',2,'linestyle','-');
ylabel(['positive ','(%)',' בדיקות חיוביות '])
set(gca,'ygrid', 'on','fontsize',13)
xlim([list.date(idx(1))-1 list.date(idx(end))+1]);
set(gcf,'Color','w')
ylim([0 15])
grid minor
box off
title({'אחוז הבדיקות החיוביות ומספר המאושפזים החדשים','% positive tests vs new hospitalized'})
legend(hh,'hospitalized מאושפזים','positive בדיקות חיוביות','location','northwest')
xtickformat('MMM')
set(gca,'xtick',datetime(2020,3:30,1))

if saveFigs == 1
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

function sm = smot(vec)
sm = movmean(vec,[3 3]);
sm(end) = nan;
sm(end-1) = mean(vec(end-4:end-1));
sm(end-2) = mean(vec(end-5:end-1));
sm(end-3) = mean(vec(end-6:end-1));