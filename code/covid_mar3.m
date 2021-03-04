tt = covid_death_potential2;
t = readtable('deaths_by_vacc.csv');



cd ~/covid-19-israel-matlab/data/Israel
% urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/vaccinated_by_age.csv')
[~,~] = system('wget -O tmp.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/vaccinated_by_age.csv')
vba = readtable('tmp.csv');
% json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinated');
% json = strrep(json,'T00:00:00.000Z','');
% json = strrep(json,'-','.');
% json = jsondecode(json);
% vaccinated = struct2table(json);
% vaccinated.Day_Date = datetime(vaccinated.Day_Date,'InputFormat','yyyy.MM.dd');
% vaccinated.Properties.VariableNames{1} = 'date';
idx = 17:3:26;
pop60 = sum(vba{135,idx});
vacc2 = sum(vba{135,idx+2});
vacc1 = sum(vba{135,idx+1});
unvacc = pop60

