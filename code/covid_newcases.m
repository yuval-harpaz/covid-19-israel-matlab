cd ~/covid-19-israel-matlab/data/Israel/
!wget -O tmp.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/cities_transliteration.csv
dict = readtable('tmp.csv','ReadVariableNames',false);
% 
% city = {'ירושלים';'תל אביב';'חיפה';'ראשון לציון';'פתח תקווה';'אשדוד';'נתניה';'באר שבע';'בני ברק';'חולון';'רמת גן';'אשקלון';'רחובות'};
% population = [919438;451523;283640;251719;244275;224628;217243;209002;198863;194273;159160;145967;141579];
% pop = table(city,population);
%  listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
for ii = 1:height(dict)
    [~,~] = system(['wget -O tmp.csv "https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/cities/',dict.Var2{ii},'.csv"']);
    data = readtable('tmp.csv','ReadVariableNames',true);
    data = data(end-20:end,:);
%     if mean(isnan(data.activeSick))
    if iscell(data.activeSick(1))
        data.activeSick = strrep(data.activeSick,'<15','0');
        data.activeSick(cellfun(@isempty,data.activeSick)) = {'0'};
        data.activeSick = cellfun(@str2num,data.activeSick);
    end
%     if ii == 1
    date = cellfun(@(x) datetime(x(1:10)),data.Date);
    
%     end
    act2 = data.activeSick(end);
    i1 = find(date < date(end),1,'last');
    act1 = data.activeSick(i1);
    act0 = data.activeSick(find(date < date(i1),1,'last'));
    y(ii,1) = max(0,act2-act0);
    IEprog(ii)
end
a=1;