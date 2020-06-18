function covid_daily_update(saveFigs)
if ~exist('saveFigs','var')
    saveFigs = true;
end
% prepare daily charts and push
cd ~/covid-19_data_analysis/
y = covid_news(saveFigs);
covid_regions;
covid_realigned(y,saveFigs)
covid_Israel_ministry;
covid_Israel(saveFigs);
if saveFigs
    covid_update_html;
end

