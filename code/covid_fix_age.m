function [agf, agDate] = covid_fix_age(ag)
 % ag can be a table or char. options: '', 'deaths_','severe_'
if nargin == 0
    ag = 'deaths_';
end
if ischar(ag)    
    % cd ~/covid-19-israel-matlab/data/Israel
    % dbv = readtable('deaths by vaccination status.xlsx');
    txt = urlread(['https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/',ag,'ages_dists.csv']);
    txt = txt(find(ismember(txt,newline),1)+1:end);
    fid = fopen('tmp.csv','w');
    fwrite(fid,txt);
    fclose(fid);
    ag = readtable('tmp.csv');
end
agDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
dif = diff(ag{:,2:11});
agf = ag;
switch ag{100,10}
    case 74 % severe
        agf = agf(1:610,:);
    case 859 %deaths
        for col = 2:11
            agf{1:563,col} = ag{1:563,col} - linspace(ag{1,col},ag{563,col},563)' + linspace(ag{1,col},ag{567,col},563)';
            agf{564:566,col} = agf{567,col};
            agf{1:599,col} = agf{1:599,col} - linspace(agf{1,col},agf{599,col},599)' + linspace(agf{1,col},agf{600,col},599)';
            agf{1:599,col} = round(agf{1:599,col});
        end
    case 1122 % cases
        for col = 2:11
            agf{863:900,col} = linspace(ag{863,col},ag{900,col},900-863+1)';
        end
    case 26 % ventilated
        agf = agf(1:610,:);
end


