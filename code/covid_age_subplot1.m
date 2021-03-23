cd ~/covid-19-israel-matlab/data/Israel
listName = {'','severe_','ventilated_','deaths_'};
tit = {'מאומתים','קשים','מונשמים','נפטרים'};
tit(2,:) = {'cases','severe','ventilated','deceased'};
agetit = {'צעירים','מבוגרים';'young','old'};
col = [0.259 0.525 0.961;0.063 0.616 0.345;0.961 0.706 0.4;0.988 0.431 0.016;0.863 0.267 0.216];
idx = [2:6;7:11];
spo = 0;
figure;
for iList = 1:4
    txt = urlread(['https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/',listName{iList},'ages_dists.csv']);
    txt = txt(find(ismember(txt,newline),1)+1:end);
    fid = fopen('tmp.csv','w');
    fwrite(fid,txt);
    fclose(fid);
    ag = readtable('tmp.csv');
    agDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
    
    if iList == 1 || iList == 4
        ds = dateshift(agDate,'start','day');
        date = unique(ds);
        yy = nan(length(date),10);
        for iDate = 1:length(date)
            yy(iDate,1:10) = max(ag{ismember(ds,date(iDate)),2:11},[],1);
        end
        yy = diff(yy);
        yy(yy < 0) = 0;
        if iList == 1
            yy = movmean(yy,[3 3]);
        elseif iList == 4
            yy(:,6:end) = movmean(yy(:,6:end),[3 3]);
        end
        date = date(2:end);
    else
        date = agDate;
        yy = ag{:,2:11};
    end
    
    for ip = 1:2
        spo = spo+1;
        subplot(2,4,spo)
        
        plot(date,yy(:,idx(ip,:)-1));
        legend(strrep(strrep(ag.Properties.VariableNames(idx(ip,:)),'_',' '),'x',''),'Location','northwest');
        xtickformat('MMM');
        xlim([datetime(2020,10,1) datetime('tomorrow')]);
        grid on;
        box off
        %     subplot(1,2,2)
        %     idx = 7:11;
        %     plot(agDate,ag{:,idx});legend(strrep(strrep(ag.Properties.VariableNames(idx),'_',' '),'x',''));xtickformat('MMM');xlim([datetime(2020,10,1) datetime('tomorrow')]);grid on;box off
        title({[tit{1,iList},' ',agetit{1,ip}],[tit{2,iList},' - ',agetit{2,ip}]})
        if ip == 1 && iList == 4
            bar(date,yy(:,idx(ip,:)-1),3);
            ylim([0 20])
            legend(strrep(strrep(ag.Properties.VariableNames(idx(ip,:)),'_',' '),'x',''),'Location','northwest');
            xtickformat('MMM');
            xlim([datetime(2020,10,1) datetime('tomorrow')]);
            grid on;
            box off
            title({[tit{1,iList},' ',agetit{1,ip}],[tit{2,iList},' - ',agetit{2,ip}]})
        end
    end
    set(gcf,'Color','w')
end