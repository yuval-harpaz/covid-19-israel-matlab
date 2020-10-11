
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = jsondecode(json);
death = json.result.records;
death = struct2table(death);
[~,msg] = system('wget -O tmp.csv https://raw.githubusercontent.com/erasta/CovidDataIsrael/3af0616918b216a7b29eacfc043c5750adb931c1/out/csv/moh_corona_deceased.csv');
%  death0 = readtable('/media/innereye/1T/Data/Untitled.csv');
death0 = readtable('tmp.csv');
row = nan(height(death0),1);
for ii = height(death0):-1:1
    ir = height(death);
    search = true;
    while search
        if isequal(death{ir,2:end},death0{ii,2:end})
            if ismember(row,ir)
                disp([str(ir),' already'])
            else
                row(ii,1) = ir;
                search = false;
            end
        end
        ir = ir-1;
        if ir == 0;
            search = false;
        end
    end
    disp(ii)
end


nans = find(isnan(row));
for in = 1:length(nans)
    if abs(row(nans(in)+1)-row(nans(in)-1)) == 3
        disp(in)
        disp(death0(nans(in),:))
        disp(death(row(nans(in)-1)+1,:))
    end
end
        

death1 = death;
death1(row(~isnan(row)),:) = [];
death0(isnan(row),:) = [];

ttd = death0.Time_between_positive_and_death;
ttd(ismember(ttd,'NULL')) = [];
ttd0 = hist(cellfun(@str2num, ttd),-2:140);
median(cellfun(@str2num, ttd))
ttd = death1.Time_between_positive_and_death;
ttd(ismember(ttd,'NULL')) = [];
median(cellfun(@str2num, ttd))
ttd1 = hist(cellfun(@str2num, ttd),-2:140);




tth = death0.Time_between_positive_and_hospitalization;
tth(ismember(tth,'NULL')) = [];
tth0 = hist(cellfun(@str2num, tth),-2:140);
median(cellfun(@str2num, tth))
tth = death1.Time_between_positive_and_hospitalization;
tth(ismember(tth,'NULL')) = [];
median(cellfun(@str2num, tth))
tth1 = hist(cellfun(@str2num, tth),-2:140);

figure;
bar((-2:140)-0.2,100*tth0/sum(ttd0),'EdgeColor','none')
hold on
bar((-2:140)+0.2,100*tth1/sum(ttd1),'EdgeColor','none')
xlim([-2 25])
legend('עד ספט 25','מ ספט 25')
set(gca,'FontSize',13)
ylabel('הסיכוי לתמותה (%)')
grid on
title('יום הפטירה ביחס ליום קבלת תוצאה חיובית')



figure;
bar((-2:140)-0.2,100*tth0/sum(ttd0),'EdgeColor','none')
hold on
bar((-2:140)+0.2,100*tth1/sum(ttd1),'EdgeColor','none')
xlim([-2 25])

vnt = death0.Ventilated;
vnt(ismember(vnt,'NULL')) = [];
vnt0 = mean(cellfun(@str2num,vnt));
vnt = death1.Ventilated;
vnt(ismember(vnt,'NULL')) = [];
vnt1 = mean(cellfun(@str2num,vnt));

age = unique(death0.age_group);
age = age([4,1,2,3]);
aa = {death0.age_group,death1.age_group};
for ii = 1:4
    for jj = 1:2
        hh(ii,jj) = sum(ismember(aa{jj},age{ii}));
    end
end
nn = hh(:,1)/sum(hh(:,1));
nn(:,2) = hh(:,2)/sum(hh(:,2));
figure;
bar(nn,'EdgeColor','none')
legend('עד ספט 25','מ ספט 25')
set(gca,'FontSize',13,'XTickLabel',age)
ylabel('שיעור השייכים לקבוצת הגיל')
grid on
title('גילאי הנפטרים לפני ואחרי 25 לספטמבר')
grid on


hos = death0.Length_of_hospitalization;
hos(ismember(hos,'NULL')) = [];
hos0 = median(cellfun(@str2num,hos));
nohos0 = mean(cellfun(@str2num,hos) <= 0);
hos = death1.Length_of_hospitalization;
hos(ismember(hos,'NULL')) = [];
hos1 = median(cellfun(@str2num,hos));
nohos1 = mean(cellfun(@str2num,hos) <= 0);

male0 = nan(height(death0),1);
male0(ismember(death0.gender,'זכר')) = 1;
male0(ismember(death0.gender,'נקבה')) = 0;
nanmean(male0)
male1 = nan(height(death1),1);
male1(ismember(death1.gender,'זכר')) = 1;
male1(ismember(death1.gender,'נקבה')) = 0;
nanmean(male1)