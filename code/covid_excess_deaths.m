cd ~/covid-19-israel-matlab/data/Israel
[~,msg] = system('wget -O lmsWeek.xlsx https://www.cbs.gov.il/he/publications/DocLib/2020/%D7%9C%D7%95%D7%97%D7%95%D7%AA%20%D7%AA%D7%9C%D7%95%D7%A9%D7%99%D7%9D/%D7%A4%D7%98%D7%99%D7%A8%D7%95%D7%AA-2000-2020-%D7%9C%D7%A4%D7%99-%D7%A9%D7%91%D7%95%D7%A2.xlsx');
[~,msg] = system('wget -O lmsMonth.xlsx https://www.cbs.gov.il/he/publications/DocLib/2020/%D7%9C%D7%95%D7%97%D7%95%D7%AA%20%D7%AA%D7%9C%D7%95%D7%A9%D7%99%D7%9D/%D7%A4%D7%98%D7%99%D7%A8%D7%95%D7%AA-%D7%A9%D7%A0%D7%94-%D7%97%D7%95%D7%93%D7%A9.xlsx');

week = readtable('lmsWeek.xlsx','sheet','2020','Range','B14:L65','ReadVariableNames',false);
monthAll = readtable('lmsMonth.xlsx','Range','B10:V21','ReadVariableNames',false);
month70 = readtable('lmsMonth.xlsx','Range','B28:V39','ReadVariableNames',false);
%from https://www.cbs.gov.il/he/publications/DocLib/2020/yarhon0720/b1.xls'
pop = table((2009:2020)',...
    1000*[7485.6;7623.6;7765.8;7910.5;8059.5;8215.7;8380.1;8546.0;8713.3;8882.8;9054.0;9212.8]);

death{1} = monthAll{:,11:end};
death{2} = monthAll{:,11:end};
death{3} = month70{:,11:end};
death{4} = month70{:,11:end};
nrm = [ones(11,1),pop.Var2(2:end)/10^6];
nrm = [nrm,nrm];
yl = {'Deaths','Deaths per Million','Deaths','Deaths per Million'};
tit = {'All ages','All ages',' Over 70','Over 70'};
figure('units','normalized','position',[0,0,0.65,0.65]);
for ip = 1:4
    subplot(2,2,ip)
    h = plot(death{ip}./nrm(:,ip)');
    col = colormap(jet(11));
    for ii = 1:11
        h(ii).Color = col(ii,:);
        if ii == 11
            h(ii).LineWidth = 2;
        end
    end
    xlim([1 12])
    xlabel('month')
    ylabel(yl{ip})
    title(tit{ip})
    grid on
    box off
    if ip == 2
        legend(num2str((2010:2020)'));
    end
    set(gca,'XTick',1:12)
end
