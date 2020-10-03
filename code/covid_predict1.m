cd ~/covid-19-israel-matlab/data/Israel
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = jsondecode(json);
t = json.result.records;
t = struct2table(t);
pos2death = cellfun(@str2num,strrep(t.Time_between_positive_and_death,'NULL','0'));
% pos2death = cellfun(@str2num,strrep({t.Time_between_positive_and_death}','NULL','0'));
bad = pos2death < 1 | ismember(t.gender,'לא ידוע');
% gender = {t.gender}';
male = ismember(t.gender(~bad),'זכר');
pos2death = pos2death(~bad);

m = hist(pos2death(male),3.5:7:160);
f = hist(pos2death(~male),3.5:7:160);
figure;
bar(3.5:7:160,[m',f'],'stack')
set(gca,'XTick',7:7:160,'ygrid','on')
box off

prob = movmean(hist(pos2death,1:1000),[3 3]);
iEnd = find(prob < 0.5,1);
prob = prob(1:iEnd-1);
prob = prob/sum(prob);
% ewma = @(x,lambda) filtfilt(lambda, [1 lambda-1], x);
% probs = ewma(prob,0.6);
figure;plot(prob)
symp = readtable('symptoms.csv');
listD = readtable('dashboard_timeseries.csv');
listD.CountDeath(isnan(listD.CountDeath)) = 0;
% pred = zeros(height(symp)+length(prob)-1,1);
% for ii = 1:height(symp)
%     pred(ii:ii+length(prob)-1) = pred(ii:ii+length(prob)-1) + (prob*(symp.pos(ii)-symp.nosymptoms_pos(ii)))';
% end
pred = conv(symp.pos-symp.nosymptoms_pos,prob);
figure;
h(1) = plot(listD.date,listD.CountDeath,'b.');
hold on
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
h(3) = plot(symp.date+14,movmean((symp.pos-symp.nosymptoms_pos)/50,[3 3]),'k');
h(4) = plot(symp.date(2):symp.date(1)+length(pred),pred/45,'r');
legend(h(2:4),'deaths','positive with symptoms / 50, 14 days before','positive with symptoms / 45, conv')
grid on
box off

yy = symp.pos./(symp.pos+symp.neg);
pred = conv(yy,prob);
figure;
h(1) = plot(listD.date,listD.CountDeath,'b.');
hold on
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
h(3) = plot(symp.date+14,movmean(yy*120,[3 3]),'k');
h(4) = plot(symp.date(2):symp.date(1)+length(pred),pred*120,'r');
legend(h(2:4),'deaths','%positive x 1.2, 14 days before','%positive x 1.2, conv')


%% new critical
newc = readtable('new_critical.csv');
xn = 0:9;
yn = normpdf(xn,4,2);
yn = yn/sum(yn);
% figure;
% plot(xn,yn)

newconv = conv(movmean(newc.new_critical,[3 3]),yn);

figure;
h(1) = plot(listD.date,listD.CountDeath,'.b');
hold on;
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
h(3) = plot(newc.date+4,movmean(newc.new_critical*0.3,[3 3]),'r');
h(4) = plot(newc.date(1):newc.date(1)+length(newconv)-1,newconv*0.3,'k');
%h(4) = plot(listD.date,movmean(listD.CountHardStatus*0.035,[3 3]),'k');
grid on
box off
ylabel('daily deaths')
legend(h(2:4),'deaths','new critical x 0.3, 4 days before','new critical conv x 0.3')

%%   pos / symp
yy = symp.pos./((symp.pos+symp.neg) - symp.nosymptoms_neg - symp.nosymptoms_pos)    %(symp.pos+symp.neg);
pred = conv(yy,prob);
fac = 10;
figure;
h(1) = plot(listD.date,listD.CountDeath,'b.');
hold on
h(2) = plot(listD.date,movmean(listD.CountDeath,[3 3]),'b','linewidth',2);
h(3) = plot(symp.date+14,movmean(yy*fac,[3 3]),'k');
h(4) = plot(symp.date(2):symp.date(1)+length(pred),pred*fac,'r');
legend(h(2:4),'deaths','%positive x 1.2, 14 days before','%positive x 1.2, conv')
