function covid_loop
while true
    disp(datetime)
    cd ~/covid-19-israel-matlab/
    [~,~] = system('git pull');
    try
        listPre = readtable('data/Israel/Israel_ministry_of_health.csv');
        covid_Israel_ministry;
        listPost = readtable('data/Israel/Israel_ministry_of_health.csv');
        if ~isequal(listPre(end,1),listPost(end,1))
            covid_Israel(1,'data/Israel/dashboard_timeseries.csv');
            covid_update_html;
            close all
            disp('updated');
        end
        wait = 60*60*3;
    catch me
        disp(['ERROR ',me.message])
        wait = 60*30;
    end
    pause(wait)
end

    