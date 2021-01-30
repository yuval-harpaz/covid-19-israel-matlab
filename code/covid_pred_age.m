cd ~/covid-19-israel-matlab/data/Israel

txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/ages_dists.csv');
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


%%
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = jsondecode(json);
death = json.result.records;
death = struct2table(death);
pos2death = cellfun(@str2num,strrep(death.Time_between_positive_and_death,'NULL','0'));
% bad = pos2death < 1 | ismember(death.gender,'לא ידוע');
% isMale = ismember(death.gender(~bad),'זכר');
% pos2death = pos2death(~bad);
old = ~ismember(death.age_group,'<65');
prob = movmean(hist(pos2death,1:1000),[3 3]);
iEnd = 73;
prob = prob(1:iEnd);
prob = prob/sum(prob);
probOld = movmean(hist(pos2death(old),1:1000),[3 3]);
 %find(probOld < 0.5,1);
probOld = probOld(1:iEnd);
probOld = probOld/sum(probOld);
probYoung = movmean(hist(pos2death(~old),1:1000),[3 3]);
probYoung = movmean(probYoung,[3 3]);
% iEnd = find(probYoung < 0.5,1);
probYoung = probYoung(1:iEnd);
probYoung = probYoung/sum(probYoung);

predOld = conv(yyy0(:,2),probOld);
predYoung = conv(yyy0(:,1),probYoung);

listD = readtable('dashboard_timeseries.csv');
pred = 
xPred = agDate(1):agDate(1)+length(predOld)-1;
figure;
plot(xPred,[predYoung,predOld])

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
col = [0.259 0.525 0.961;0.063 0.616 0.345;0.961 0.706 0.4;0.988 0.431 0.016;0.863 0.267 0.216];


clear yy;
for ii = 1:5
    idx = 1+(ii*2-1:ii*2);
    yy(1:length(agDate),ii) = sum(ag{:,idx},2);
    disp(idx)
end
yyy = movmean(diff(yy)./datenum(diff(agDate)),[11 11],'omitnan');
yyy = [cumsum(yyy,2);zeros(size(yyy))];
xxx = [agDate(2:end);flipud(agDate(2:end))];

figure;
subplot(2,1,1)
for ii = 1:5
    fill(xxx,yyy(:,6-ii),col(6-ii,:),'linestyle','none')
    hold on
end
% plot(agDate(2:end),yyy)
legend('80+','60-80','40-60','20-40','0-20','location','northwest');
set(gcf,'Color','w')
ax = gca;
ax.YRuler.Exponent = 0;
xtickformat('MMM')
xlim(agDate([2,end]))
grid on
title('מאומתים לפי גיל')
set(gca, 'layer', 'top');

yyy1 = yyy./yyy(:,5)*100;
yyy1(isnan(yyy1)) = 0;
subplot(2,1,2)
for ii = 1:5
    fill(xxx,yyy1(:,6-ii),col(6-ii,:),'linestyle','none')
    hold on
end
% legend('80+','60-80','40-60','20-40','0-20','location','northwest');
set(gcf,'Color','w')
ax = gca;
ax.YRuler.Exponent = 0;
xtickformat('MMM')
xlim(agDate([2,end]))
grid on
title('מאומתים לפי גיל (%)')
set(gca, 'layer', 'top');
