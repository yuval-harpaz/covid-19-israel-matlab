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
plot(list.date(idx),list.tests(idx));
ylabel('tests')
ax = gca;
ax.YRuler.Exponent = 0;
yyaxis right
plot(list.date(idx),round(100*list.tests_positive(idx)./list.tests(idx),1))
ylabel('positive tests (%)')
set(gca,'ygrid', 'on','fontsize',13)
box off
if saveFigs
    saveas(fig,'docs/percent_positive.png');
    
    % update html
    list.date(idx(end))
    pp = str(round(100*list.tests_positive(idx(end))./list.tests(idx(end)),1));
    % date = datestr(list.date(idx(end)));
    fName = 'docs/myCountry.html';
    fid = fopen(fName,'r');
    txt = fread(fid);
    fclose(fid);
    txt = native2unicode(txt');
    iSpace = strfind(txt,' ');
    iPos = strfind(txt,'% מהתוצאות');
    iSpace = iSpace(find(iSpace < iPos,1,'last'):find(iSpace > iPos,1));
    txt = [txt(1:iSpace(1)),pp,txt(iSpace(2):end)];
    txt(iDate-6:iDate+3) = yesterdate;
    fid = fopen(fName,'w');
    fwrite(fid,txt);
    fclose(fid);
end
% hold on
% scatter(datetime('18-Apr-2020'),2.7,'fill','k')
% legend('בדיקות','בדיקות חיוביות','18-Apr')
fig1 = figure('position',[50,50,800,500]);
yyaxis left
plot(list.date(idx),list.new_hospitalized(idx));
ylabel('new hospitalized')
ax = gca;
ax.YRuler.Exponent = 0;

yyaxis right
plot(list.date(idx),round(100*list.tests_positive(idx)./list.tests(idx),1))
ylabel('positive tests (%)')
set(gca,'ygrid', 'on','fontsize',13)