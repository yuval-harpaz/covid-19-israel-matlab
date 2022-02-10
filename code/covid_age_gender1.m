function covid_age_gender1
% source can be 'd' for dashboard (confirmed), 's' for severe (dashboard too), 't' for timna

position = [100,100,900,600];
% pop = [1735000;1565000;1320000;1209000;1112000;874000;747217;526929;238729;58687];
% [posDash, dateD] = get_dashboard;
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
listD(end,:) = [];
yl = movsum(listD.tests_positive1(1:end-1),[3 3]);

[pos, dateW, ages] = get_dashboard_cases(1);
tt = tocsv(dateW,pos,ages);
bad = [59,72];
for iBad = 1:length(bad)
    tt{bad(iBad),2:end} = round((tt{bad(iBad)-1,2:end}+tt{bad(iBad)+1,2:end})/2);
end
writetable(tt,'~/covid-19-israel-matlab/data/Israel/cases_by_age_gender.csv','Delimiter',',','WriteVariableNames',true)
co = flipud(hsv(11)); co = co + 0.1; co(co > 1) = 1;
co = co(2:end,:)*0.9;

ratio = pos./sum(pos,2)*100;
ratio(nansum(pos,2) < 2000,:) = 0;
dateW(bad) = [];
pos(bad,:) = [];

gender = {'male','female'};
idx = [1:10;11:20];
figure('position',position);
for sp = 1:2
    subplot(1,2,sp)
    hlp = plot(dateW-3,pos(:,idx(sp,:)));
    set(gca,'FontSize',13,'Xtick',datetime(2020,1:50,1))
    grid on
    ax = gca;
    ax.YRuler.Exponent = 0;
    xlim([dateW(1)-3,datetime('today')])
    xtickformat('MMM')
    
    title(['weekly cases by age, ',gender{sp}])
    set(gcf,'Color','w')
    for jj = 1:length(hlp)
        hlp(jj).Color = co(jj,:);
    end
    ylabel('cases')
    ylim([0 80000])
    xlim([datetime('16-May-2021') datetime('today')])
end
legend('0-10','10-20','20-30','30-40','40-50','50-60','60-70','70-80','80-90','90+',...
        'location','northwest')

function tt = tocsv(date,pos,ages)
ages = strrep(ages,'-','_');
ages = strrep(ages,'+','_');
for ii = 1:length(ages)
    ages{ii} = ['m',ages{ii}];
end
ages = [ages;strrep(ages,'m','f')];
% date = dateW;
tte = 'tt = table(date,';
for ii = 1:length(ages)
    tte = [tte,ages{ii},','];
    eval([ages{ii},'=pos(:,ii);']);
end
eval([tte(1:end-1),');'])
    