function covid_abroad_ve1
options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/arrivingAboardDaily';
tt = webread(url, options);
tt = struct2table(tt);
tt = tt(ismember(tt.visited_country,'כלל המדינות'),:);
date = datetime(tt.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

% aad = struct2table(webread('https://datadashboardapi.health.gov.il/api/queries/arrivingAboardDaily',options));

start = find(weekday(date) == 1,1);
c = 0;
for sunday = start:7:length(date)
    if sunday+6 < length(date)
        c = c+1;
        pos(c,1:3) = sum(tt{sunday:sunday+6,[6,8,7]});
        tests(c,1:3) = sum(tt{sunday:sunday+6,[3,5,4]});
    end
end
wednesday = date(start:7:7*c)+3;
perc = pos(:,1:3)./tests(:,1:3);
figure;
hh = plot(wednesday, 100*perc,'linewidth',1.5);
hh(1).Color = [0.055,0.49,0.49];
hh(2).Color = [0.725,0.788,0.357];
hh(3).Color = [0.184,0.804,0.984];
title('Airport percent positive by vaccination status')
ve = 100*(1-(pos(:,1)./tests(:,1))./(pos(:,3)./tests(:,3)))
legend('vaccinated','outdated','unvaccinated')
grid on
figure;
hh1 = bar(wednesday, pos,'stacked');
hh1(1).FaceColor = [0.055,0.49,0.49];
hh1(2).FaceColor = [0.725,0.788,0.357];
hh1(3).FaceColor = [0.184,0.804,0.984];
title('Airport weekly positive tests')
grid on
legend('vaccinated','outdated','unvaccinated')
figure;
hh1 = bar(wednesday, tests,'stacked');
hh1(1).FaceColor = [0.055,0.49,0.49];
hh1(2).FaceColor = [0.725,0.788,0.357];
hh1(3).FaceColor = [0.184,0.804,0.984];
title('Airport weekly tests')
grid on
legend('vaccinated','outdated','unvaccinated')

%%

url = 'https://datadashboardapi.health.gov.il/api/queries/positiveArrivingAboardDaily';
ttp = webread(url, options);
ttp = struct2table(ttp);
ttp = ttp(ismember(ttp.visited_country,'כלל המדינות'),:);
datep = datetime(ttp.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

url = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate';
tCases = webread(url, options);
tCases = struct2table(tCases);
dateCases = datetime(tCases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

cases = tCases.amount(ismember(dateCases, datep));
abroad = sum(ttp{:,3:4},2);
abroad(abroad > cases) = cases(abroad > cases);
idx = 1:length(cases)-1;
R = covid_R31(cases(idx));
R(:,2) = covid_R31(cases(idx)-abroad(idx));
R(:,3) = covid_R31(abroad(idx));
xl = [datetime(2022,1,1) datetime('tomorrow')];

figure;
subplot(3,1,1)
plot(datep(idx),R)
legend('All','Local','Abroad')
title('R')
xlim(xl)
grid on
subplot(3,1,2)
plot(datep(idx),[cases(idx),cases(idx)-abroad(idx),abroad(idx)])
legend('All','Local','Abroad')
title('cases')
xlim(xl)
grid on
subplot(3,1,3)
plot(datep(idx),100*movmean(abroad(idx)./cases(idx),[3 3]))
title('% abroad')
xlim(xl)
grid on
% 