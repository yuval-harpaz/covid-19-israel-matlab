cd ~/covid-19-israel-matlab/data/Israel
listName = {'','severe_','ventilated_','deaths_'};
tit = {'מאומתים','קשים','מונשמים','נפטרים'};
col = [0.259 0.525 0.961;0.063 0.616 0.345;0.961 0.706 0.4;0.988 0.431 0.016;0.863 0.267 0.216];
iList = 1;
txt = urlread(['https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/',listName{iList},'ages_dists.csv']);
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
agDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
casesYOday = [sum(ag{:,[2:7,12:17]},2),sum(ag{:,[8:11,18:21]},2)];
%%
yyy0 = movmean(diff(casesYOday)./datenum(diff(agDate)),[11 11],'omitnan');
yyy0 = movmean(yyy0,[11 11],'omitnan');
  
figure;
yyaxis left
plot(agDate(2:end),yyy0)
ylabel('מאומתים')
yyaxis right
plot(agDate(2:end),yyy0(:,2)./yyy0(:,1)*100)
ylabel('שיאור המאומתים המבוגרים')
ax = gca;
ax.YRuler.Exponent = 0;
ylim([4 20])
set(gca,'ytick',0:2:24)
hold on
last24i = find(agDate < agDate(end)-1,1,'last');
last24 = diff(casesYOday([last24i,end],:));
plot(agDate(end),last24(2)./last24(1)*100,'.')
legend('מתחת 60','מעל 60','שיעור המבוגרים','location','northwest')
title('מאומתים לפי גיל')
grid on
grid minor
xtickformat('MMM')
set(gcf,'Color','w')
        %%

perc = nan(size(yyy0));
for ii = 1:length(perc)
    weekBefore = find(agDate(ii+1)-agDate > 7,1,'last');
    if ~isempty(weekBefore)
        perc(ii,:) = yyy0(ii,:)./yyy0(weekBefore,:);
    end
end



cd ~/covid-19-israel-matlab/data/Israel
!wget -O tmp.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/isolated_staff.csv
staff = readtable('tmp.csv');
staffDate = datetime(cellfun(@(x) x(1:end-5),strrep(staff.Date,'T',' '),'UniformOutput',false));
yDash = staff{:,2:5};
nurse = yDash(:,1);
nurse(80:87) = nan;
doc = yDash(:,2);
doc(find(doc(2:end)-doc(1:end-1) > 75)+1) = nan;
percS = nan(size(doc,1),1);
for ii = 1:length(percS)
    weekBefore = find(staffDate(ii)-staffDate > 7,1,'last');
    if ~isempty(weekBefore)
        percS(ii,1) = doc(ii)./doc(weekBefore);
        percS(ii,2) = nurse(ii)./nurse(weekBefore);
    end
end
percS(percS == 0) = nan;

geri = readtable('geri.csv');
percG = geri{2:end,2:3}./geri{1:end-1,2:3};


figure;
fill(datetime(2020,12,[20,20+14,20+14,20,20]),[0.5,0.5,1.5,1.5,0.5],[0.9,0.9,0.9],'linestyle','none')
colorset
hold on
plot(agDate(2:end),perc)
plot(staffDate,percS)
plot(geri.date(2:end),percG)
line(agDate([1,end]),[1 1],'Color','k','LineStyle','--')
legend('first 2 weeks vacc','<60','60+','doc','nurse','geri- residents','geri- staff')
grid on
grid minor
xtickformat('MMM')
set(gcf,'Color','w')
xlim([datetime(2020,10,15) datetime('tomorrow')])
title('R (positive today / positive 7 days before) response to vaccination')
ylabel('R')

figure;
fill(datetime(2020,12,[20,20+14,20+14,20,20]),[0,0,2,2,0]/0.3,[0.9,0.9,0.9],'linestyle','none')
hold on
plot(staffDate(~badDoc),doc(~badDoc)/200/0.3)
hold on
plot(staffDate(~bad),nurse(~bad)/350/0.3)