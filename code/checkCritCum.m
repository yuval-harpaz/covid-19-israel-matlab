
[~,~] = system(['wget -O tmp.csv https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/7ef844f65863643d2df004e3dfa39dd5b1198ee8/data/Israel/dashboard_timeseries.csv'])
listC = readtable('tmp.csv');
