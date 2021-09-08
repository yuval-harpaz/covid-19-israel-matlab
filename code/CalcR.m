%% Generation interval distribution
x = 0:30; % [d]

pdf = [0.0364000, 0.1430000, 0.1590000, 0.1440000, 0.1210000, 0.0968000,...
    0.0756000, 0.0579000, 0.0438000, 0.0328000, 0.0243000, 0.0179000, 0.0131000,...
    0.0095900, 0.0069700, 0.0050500, 0.0036500, 0.0026300, 0.0018900, 0.0013600,...
    0.0009710, 0.0006950, 0.0004960, 0.0003540, 0.0002520, 0.0001790, 0.0001270,...
    0.0000903, 0.0000641, 0.0000454, 0.0000322];

% pdf = gampdf(x, 1.5, 3);

%% Cases
options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate';
cases = webread(url, options);
cases = struct2table(cases);
cases.date = datetime(cases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

%% R from the dashboard
url = 'https://datadashboardapi.health.gov.il/api/queries/infectionFactor';
R_dash = webread(url, options);
R_dash = struct2table(R_dash);
R_dash.R(cellfun(@isempty, R_dash.R)) = {NaN};
R_dash.R = [R_dash.R{:}]';
R_dash.date = datetime(R_dash.day_date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');

%% Compute R
effective_cases = conv(cases.amount, pdf);
effective_cases = effective_cases(1:(end-length(x)+1));

R = cases.amount./effective_cases;
R_avg = smoothdata(R, 'movmean', 7);

%% Compare to dashboard
figure;
plot(R_dash.date, R_dash.R, 'LineWidth', 2, 'DisplayName', 'Dashboard');
hold on
plot(cases.date(19:end-11), R_avg(26:end-4), '--', 'LineWidth', 2, 'DisplayName', 'Local');
grid on
ylabel('R');
xlabel('Date');
legend('Location', 'Best');
title('Compare averaged R to dashboard');
axis tight

% saveas(gcf, 'RCompare2Dashboard.png');

%% Check lag
figure;
plot(cases.date, R, 'LineWidth', 2, 'DisplayName', 'Local daily');
hold on
plot(cases.date(4:end-3), R_avg(4:end-3), 'LineWidth', 2, 'DisplayName', 'Local mean');
plot(R_dash.date, R_dash.R, 'LineWidth', 2, 'DisplayName', 'Dashboard');
grid on
ylabel('R');
xlabel('Date');
legend('Location', 'Best');
title('Check lag');

axis tight
ylim([0 4]);

% saveas(gcf, 'RCheckLag.png');
