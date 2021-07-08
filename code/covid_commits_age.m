cd ~/Repos/israel_moh_covid_dashboard_data
fid = fopen('commit_history.json','r');
commits = fread(fid);
fclose(fid);
commits = native2unicode(commits');
commits = jsondecode(commits);
commits = commits(906:end);
cum = [];
for ii = 1:length(commits)
    date(ii,1) = datetime(strrep(commits{ii}{1}(1:19),'T',' '));
    commit = commits{ii}{2};
    json = urlread(['https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/',commit,'/moh_dashboard_api_data.json']);
    json = jsondecode(json);
    if isfield(json,'infectedByPeriodAndAgeAndGender')
        data = json.infectedByPeriodAndAgeAndGender;
        clear period
        if isstruct(data)
            period = {data(:).period}';
        else
            for jj = 1:length(data)
                period{jj,1} = data{jj}.period;
            end
        end
        data = data(contains(period,'מתחילת'));
        if length(data) > 0
            try
                cum(ii,1:10) = cellfun(@(x) x.amount,{data(:).male}') + ...
                    cellfun(@(x) x.amount,{data(:).female}');
            catch
                cum(ii,1:10) = nan;
            end
        else
            cum(ii,1:10) = nan;
        end
    else
        cum(ii,1:10) = nan;
    end
    IEprog(ii);
end
