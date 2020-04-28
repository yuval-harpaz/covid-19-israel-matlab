function covid_daily_update(saveFigs)
if ~exist('saveFigs','var')
    saveFigs = true;
end
% prepare daily charts and push
cd ~/covid-19_data_analysis/
y = covid_news(saveFigs);
covid_realigned(y,saveFigs)
isr = covid_Israel(saveFigs);
covid_Israel_ministry;
if saveFigs
    covid_update_html(isr);
end

