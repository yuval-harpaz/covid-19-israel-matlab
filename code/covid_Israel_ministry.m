function covid_Israel_ministry(getHistory)
if ~exist('getHistory','var')
    getHistory = false;
end
%% משרד הבריאות
cd ~/covid-19_data_analysis/
%txt = urlread('https://govextra.gov.il/ministry-of-health/corona/corona-virus/');
! google-chrome https://datadashboard.health.gov.il/COVID-19/?utm_source=go.gov.il&utm_medium=referral
pause(4)
! gnome-screenshot -w -f dashboard.png
img = imread('dashboard.png');
%% get history
if getHistory
    iLink = strfind(txt,'.xlsx');
    iHref = strfind(txt,'href');
    iHref = iHref(find(iHref < iLink,1,'last'));
    link = ['https://govextra.gov.il/',txt(iHref+7:iLink+4)];
    [~,~] = system(['wget ',link]);
    movefile(link(find(ismember(link,'/'),1,'last')+1:end),'data/Israel/covid19-data-israel.xlsx')
end
