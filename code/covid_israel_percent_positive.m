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
if saveFigs
    saveas(fig,'docs/percent_positive.png');
    
    % update html
%     list.date(idx(end))
    pp = str(round(100*list.tests_positive(idx(end))./list.tests_result(idx(end)),1));
    % date = datestr(list.date(idx(end)));
    fName = 'docs/myCountry.html';
    fid = fopen(fName,'r');
    txt = fread(fid);
    fclose(fid);
    txt = native2unicode(txt');
    iSpace = strfind(txt,' ');
    iPos = strfind(txt,'% מהתוצאות');
    iSpace = iSpace(find(iSpace < iPos,1,'last'):find(iSpace > iPos,1));
    txt = [txt(1:iSpace(1)),pp,'%',txt(iSpace(2):end)];
    txt = unicode2native(txt);
    % txt(iDate-6:iDate+3) = yesterdate;
    fid = fopen(fName,'w');
    fwrite(fid,txt);
    fclose(fid);
end
% hold on
% scatter(datetime('18-Apr-2020'),2.7,'fill','k')
% legend('בדיקות','בדיקות חיוביות','18-Apr')
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
plot(list.date(idx),list.new_hospitalized(idx));
hold on
plot(list.date(idx),hospSmooth,'linewidth',2,'linestyle','-');
ylabel('new hospitalized')
ax = gca;
ax.YRuler.Exponent = 0;

yyaxis right
plot(list.date(idx),pos)
hold on
plot(list.date(idx),posSmooth,'linewidth',2,'linestyle','-');
ylabel('positive tests (%)')
set(gca,'ygrid', 'on','fontsize',13)
xlim([list.date(idx(1))-1 list.date(idx(end))+1]);
if saveFigs
    saveas(fig1,'docs/positiveVShosp.png');
end