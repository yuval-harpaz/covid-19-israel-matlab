function covid_loop
tic
while true
    cd ~/covid-19-israel-matlab/
    try
        listPre = readtable('data/Israel/Israel_ministry_of_health.csv');
        covid_Israel_ministry;
        listPost = readtable('data/Israel/Israel_ministry_of_health.csv');
        if ~isequal(listPre(end,1),listPost(end,1))
            covid_Israel(1);
            if saveFigs
                covid_update_html;
            end
        end
        wait = 60*60*3;
    catch
        disp('error!')
        wait = 60*30;
    end
    pause(wait)
    toc
end

