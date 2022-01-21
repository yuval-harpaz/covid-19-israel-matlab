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




