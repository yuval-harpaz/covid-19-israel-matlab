%% compare different Rs for cases

options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate';
cases = webread(url, options);
cases = struct2table(cases);
date = datetime(cases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
vec = cases.amount;

R = covid_R31(vec);
mu = 2.5:0.5:4.5;
for ii = 1:length(mu)
    R(:,7-ii) = covid_R31(vec,[mu(ii),3.5]);
end
figure;
hh = plot(date(19:end-10), R(26:end-3,:));
hh(1).Color = [0 0 0];
hh(2).LineStyle = '--';
hh(2).Color = [1 0.2 0.2];
legend('MoH','4.5','4','3.5','3','2.5')
grid on
title('R by \mu')

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




