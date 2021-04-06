function agf = covid_fix_age(ag)
if nargin == 0
    % cd ~/covid-19-israel-matlab/data/Israel
    % dbv = readtable('deaths by vaccination status.xlsx');
    txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/deaths_ages_dists.csv');
    txt = txt(find(ismember(txt,newline),1)+1:end);
    fid = fopen('tmp.csv','w');
    fwrite(fid,txt);
    fclose(fid);
    ag = readtable('tmp.csv');
end
agDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
dif = diff(ag{:,2:11});
agf = ag;
for col = 1:9
    idx = find(dif(:,col) < -9);
    if ~isempty(idx)
        for jdx = 1:length(idx)
            if dif(idx(jdx),col+1) > dif(idx(jdx),col)*(-1)
                agf{idx(jdx)+1:end,col+1} = agf{idx(jdx)+1:end,col+1}-dif(idx(jdx),col);
                agf{idx(jdx)+1:end,col+2} = agf{idx(jdx)+1:end,col+2}+dif(idx(jdx),col);
%             else
%                 disp('uncprrected minus deaths')
            end
        end
    end
end