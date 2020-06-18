function covid_Israel_ministry
%% משרד הבריאות
cd ~/covid-19_data_analysis/
%% get history

txt = urlread('https://govextra.gov.il/ministry-of-health/corona/corona-virus/');
ext = '.csv';
iLink = strfind(txt,'.csv');
iHref = strfind(txt,'href');
iHref = iHref(find(iHref < iLink,1,'last'));
link = ['https://govextra.gov.il/',txt(iHref+7:iLink+(length(ext)-1))];
[~,~] = system(['wget ',link]);
movefile(link(find(ismember(link,'/'),1,'last')+1:end),['data/Israel/covid19-data-israel',ext])
if exist('data/Israel/tmp.csv','file')
    !rm data/Israel/tmp.csv
end
!awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' data/Israel/covid19-data-israel.csv >> data/Israel/tmp.csv
movefile('data/Israel/tmp.csv','data/Israel/covid19-data-israel.csv')

%%
% ! google-chrome https://datadashboard.health.gov.il/COVID-19/?utm_source=go.gov.il&utm_medium=referral
% pause(4)
% ! gnome-screenshot -w -f dashboard.png
% img = imread('dashboard.png');