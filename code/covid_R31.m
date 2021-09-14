function R = covid_R31(vec)
if nargin == 0
    options = weboptions('Timeout', 30);
    url = 'https://datadashboardapi.health.gov.il/api/queries/positiveArrivingAboardDaily';
    cases = webread(url, options);
    cases = struct2table(cases);
    
    cases = cases(ismember(cases.visited_country,'כלל המדינות'),:);
    dateA = datetime(cases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
    ie = cellfun(@isempty,cases.sum_positive);
    cases.sum_positive(ie) = {0};
    abroad = cellfun(@(x) x,cases.sum_positive);
    url = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate';
    cases = webread(url, options);
    cases = struct2table(cases);
    dateL = datetime(cases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
    idx = ismember(dateL,dateA);
    vec = cases.amount(idx)-abroad;
    date = dateL(idx);
    url = 'https://datadashboardapi.health.gov.il/api/queries/infectionFactor';
    R_dash = webread(url, options);
    R_dash = struct2table(R_dash);
    R_dash.R(cellfun(@isempty, R_dash.R)) = {NaN};
    R_dash.R = [R_dash.R{:}]';
    R_dash.date = datetime(R_dash.day_date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
    R_dash = R_dash(ismember(R_dash.date,date),:);
end
%% Generation interval distribution
x = 0:30; % [d]

pdf = [0.0364000, 0.1430000, 0.1590000, 0.1440000, 0.1210000, 0.0968000,...
    0.0756000, 0.0579000, 0.0438000, 0.0328000, 0.0243000, 0.0179000, 0.0131000,...
    0.0095900, 0.0069700, 0.0050500, 0.0036500, 0.0026300, 0.0018900, 0.0013600,...
    0.0009710, 0.0006950, 0.0004960, 0.0003540, 0.0002520, 0.0001790, 0.0001270,...
    0.0000903, 0.0000641, 0.0000454, 0.0000322];

% pdf = gampdf(x, 1.5, 3);

%% Cases


%% R from the dashboard


%% Compute R
effective_cases = conv(vec, pdf);
effective_cases = effective_cases(1:(end-length(x)+1));

R_raw = vec./effective_cases;
R = smoothdata(R_raw, 'movmean', 7);

%% Compare to dashboard
if nargin == 0
    figure;
    plot(R_dash.date, R_dash.R, 'LineWidth', 2, 'DisplayName', 'Dashboard');
    hold on
    plot(date(19:end-10), R(26:end-3), 'LineWidth', 2, 'DisplayName', 'Local');
    grid on
    ylabel('R');
%     xlabel('Date');
    legend('Location', 'Best');
    title('Compare dashboard R to local R');
    axis tight
end
