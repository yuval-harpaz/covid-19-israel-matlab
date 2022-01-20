function R = covid_R31(vec, mu_sd, plt)
%% set default input arguments to empty
if ~exist('vec','var')
    vec = [];
end
if ~exist('mu_sd','var')
    mu_sd = [];
end
if nargin == 0
    plt = true;
elseif ~exist('plt','var')
    plt = false;
end
%% if no vector is given, fetch cases for Israel
if isempty(vec)
    options = weboptions('Timeout', 30);
    url = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate';
    cases = webread(url, options);
    cases = struct2table(cases);
    date = datetime(cases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
    vec = cases.amount;
    url = 'https://datadashboardapi.health.gov.il/api/queries/infectionFactor';
    R_dash = webread(url, options);
    R_dash = struct2table(R_dash);
    R_dash.R(cellfun(@isempty, R_dash.R)) = {NaN};
    R_dash.R = [R_dash.R{:}]';
    R_dash.date = datetime(R_dash.day_date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
    R_dash = R_dash(ismember(R_dash.date,date),:);
end
%% Generation interval distribution

if isempty(mu_sd) % if no mu and sd are provided, use MOH prob
    pdf = [0.0364000, 0.1430000, 0.1590000, 0.1440000, 0.1210000, 0.0968000,...
        0.0756000, 0.0579000, 0.0438000, 0.0328000, 0.0243000, 0.0179000, 0.0131000,...
        0.0095900, 0.0069700, 0.0050500, 0.0036500, 0.0026300, 0.0018900, 0.0013600,...
        0.0009710, 0.0006950, 0.0004960, 0.0003540, 0.0002520, 0.0001790, 0.0001270,...
        0.0000903, 0.0000641, 0.0000454, 0.0000322];
else
%     x = 0:30;
    x = [0.07,0.915,2:30];
    mu = mu_sd(1);
    sd = mu_sd(2);
    a = (mu/sd)^2;
    b = sd^2/mu;
    pdf = gampdf(x , a, b);
end
%% Compute R
effective_cases = conv(vec, pdf);
effective_cases = effective_cases(1:(end-31+1));

R_raw = vec./effective_cases;
R = smoothdata(R_raw, 'movmean', 7);

%% Compare to dashboard
if plt
    figure;
    if exist('R_dash','var')
        plot(R_dash.date, R_dash.R, 'LineWidth', 2, 'DisplayName', 'Dashboard');
        hold on
        plot(date(19:end-10), R(26:end-3),'--', 'LineWidth', 2, 'DisplayName', 'Computed');
        grid on
        ylabel('R');
    %     xlabel('Date');
        legend('Location', 'Best');
        title('Compare dashboard R to local R');
        axis tight
    else
        plot(R, 'LineWidth', 2, 'DisplayName', 'R');
    end
end
