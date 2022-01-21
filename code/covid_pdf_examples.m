%% compare different Rs for cases

options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate';
cases = webread(url, options);
cases = struct2table(cases);
date = datetime(cases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
vec = cases.amount;

[R, pdf] = covid_R31(vec);
mu = 2.5:0.5:4.5;
sd = mu/4.5*3.5;
for ii = 1:length(mu)
    [r, p] = covid_R31(vec,[mu(ii),sd(ii)]);
    R(:,7-ii) = r;
    pdf(7-ii,:) = p;
end

figure;
hhp = plot(0:30,pdf);
hhp(1).Color = [0 0 0];
hhp(2).LineStyle = '--';
hhp(2).Color = [1 0.2 0.2];
legend('MoH','4.5,  3.5','4,     3.111','3.5,  2.722','3,     2.333','2.5,  1.944')
title('pdf by (\mu, σ)')
grid on
figure;
hh = plot(date(19:end-10), R(26:end-3,:));
hh(1).Color = [0 0 0];
hh(2).LineStyle = '--';
hh(2).Color = [1 0.2 0.2];
legend('MoH','4.5,  3.5','4,     3.111','3.5,  2.722','3,     2.333','2.5,  1.944')
grid on
title('R by (\mu, σ)')

%% @MarkZlochin
a = (4.5/3.5)^2;
b = 3.5^2/4.5;
% x = 0.5:1:30.5;
x = 0:30;
mark = gampdf(x , a, b);
figure;
plot(x, pdf,'b','linewidth',2);
hold on;
plot(x, mark,'r:','linewidth',2)
legend('משרד הבריאות', 'gampdf(0:30 , 1.6531, 2.7222)')
grid on;
title('Current method for computing R')

%%
mu = 2.5;
sd = 3.5;
a = (mu/sd)^2;
b = sd^2/mu;
% x = 0.5:1:30.5;
x = 0:30;
mark = gampdf(x , a, b);
figure;
plot(x, pdf,'b','linewidth',2);
hold on;
plot(x, mark,'r:','linewidth',2)
legend('משרד הבריאות', 'gampdf(0:30 , 1.6531, 2.7222)')
grid on;
title('Current method for computing R')



%%
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
R = covid_R31(listD.tests_positive1);
% mu = 2.5:0.5:4.5;
% sd = mu/4.5*3.5;
for ii = [12,17]
    R(:,end+1) = covid_R31(listD{:,ii});
end
R2_5 = covid_R31(listD.tests_positive1,[2.5,2.5*3.5/4.5]);
% mu = 2.5:0.5:4.5;
% sd = mu/4.5*3.5;
for ii = [12,17]
    R2_5(:,end+1) = covid_R31(listD{:,ii},[2.5,2.5*3.5/4.5]);
end
ccc = [0,0.4470,0.7410;0.8500,0.3250,0.09800;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.07800,0.1840];
casesA = movmean(listD.tests_positive1,[3 3]);
casesA(isnan(casesA)) = 0;
casesA = casesA/max(casesA)*2+0.5;
%%
figure;
fill([listD.date;flipud(listD.date)],[casesA;0.5+zeros(size(casesA))],[0.8 0.8 0.8], 'linestyle','none')
hold on
hh3 = plot(listD.date(19:end-11), R(26:end-4,:), 'linewidth',1.5);
hh3(1).Color = [0.3 0.7 0.3];
hh3(2).Color = ccc(4,:);
hh3(3).Color = ccc(3,:);
legend(hh3, 'cases','new hospitalizations','new severe','location','northwest')
grid on
box off
title('R')
ylabel('R')
set(gca,'XTick',datetime(2020,1:300,1))
xtickangle(90)
xtickformat('MM/yy')
%%
figure;
hh3 = plot(listD.date(19:end-11), R2_5(26:end-4,:), 'linewidth',1.5);
hh3(1).Color = [0.3 0.7 0.3];
hh3(2).Color = ccc(4,:);
hh3(3).Color = ccc(3,:);
legend('cases','new hospitalizations','new severe')
grid on
box off
title('R')
ylabel('R')