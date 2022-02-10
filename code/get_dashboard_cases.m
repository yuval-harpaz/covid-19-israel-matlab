function [dash, dateW, ages] = get_dashboard_cases(gender)
if nargin == 0
    gender = 2;
else
    gender = [12, 22];
end
txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/ages_dists.csv');
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
if strcmp(ag.UpdateTime{1586},'2022-01-24T06:17:25.833Z')
    ag(1586,:) = [];
end
for ig = 1:length(gender)
    pos(1:height(ag),gender(ig)-1:gender(ig)+8) = ag{:,gender(ig):gender(ig)+9};
end
if size(pos,2) == 30
    pos = pos(:,11:end);
end
date = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
dd = dateshift(date,'start','day');
dU = unique(dd);
sunday = dU(10);
sunday = sunday:7:dU(end);
end7 = sunday';
dash = nan(size(end7,1),10*length(gender));
for iWeek = 1:length(end7)
    start = find(dd == end7(iWeek)-7,1,'last');
    if isempty(start)
        [~,start] = min(abs(dd - (end7(iWeek)-7)));
    end
    wend = find(dd == end7(iWeek),1,'last');
    if ~isempty(start) && ~isempty(wend)
        dash(iWeek,:) = pos(wend,:)-pos(start,:);
    end
end
if size(dash,2) == 10
    dash(83,:) = [79779	95390	62517	63324	56666	35725	23492	11890	4711	1298];
else
    dash(83,:) = [51620,54673,24484,24138,22520,14714,10013,5442,1962,416,28159,40717,38033,39186,34146,21011,13479,6448,2749,882];
%     dash(83,:) = [50382	53158	23757	23473	21853	14276	9766	5320	1918	406	27484	39589	36903	38106	33134	20385	13147	6304	2688	861];
end
dash([59,72],:) = nan;
dash(dash < 0) = 0;
ages = strrep(ag.Properties.VariableNames(2:11),'x','')';
ages = strrep(ages,'_','-');
ages{end} = '90+';
dateW = end7-4;