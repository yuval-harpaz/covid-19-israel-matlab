function [dash, dateW, ages] = get_dashboard_severe
txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/severe_ages_dists.csv');
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
sev = ag{:,12:end};
sev = sev(611:end,:);
date = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
date = date(611:end);
dd = dateshift(date,'start','day');
dU = unique(dd);
sunday = dU(6);
sunday = sunday:7:dU(end);
% end7 = unique([sunday';dU(end-1)]);
end7 = sunday';
dash = nan(size(end7,1),20);
for iWeek = 1:length(end7)
    start = find(dd == end7(iWeek)-7,1,'last');
    wend = find(dd == end7(iWeek),1,'last');
    if ~isempty(start) && ~isempty(wend)
        dash(iWeek,:) = sev(wend,:)-sev(start,:);
    end
end
% dash(59,:) = nan;
% end7(59) = [];
dash(dash < 0) = 0;
ages = strrep(ag.Properties.VariableNames(2:11),'x','')';
ages = strrep(ages,'_','-');
ages{end} = '90+';
dateW = end7-4;