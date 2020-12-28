clear hh
subplot(1,2,2)
idx = ~isnan(list.hospitalized);
% plot(list.date(idx),list.hospitalized(idx),'color',[0.9 0.9 0.1],'linewidth',1);
y = list.hospitalized(idx)-list.critical(idx)-list.severe(idx);
y = y./prctile(y,95);
hh(1) = plot(list.date(idx),y,...
    'color',[0 1 0],'linewidth',1);
hold on
idx = ~isnan(list.severe);
y = list.severe(idx);
y = y./prctile(y,95);
hh(2) = plot(list.date(idx),y,'b','linewidth',1,'linestyle','-');
idx = ~isnan(list.critical);
y = list.critical(idx);
y = y./prctile(y,95);
hh(3) = plot(list.date(idx),y,'color',[0.7 0 0.7],'linewidth',1,'linestyle','-');
idx = ~isnan(list.on_ventilator);
y = list.on_ventilator(idx);
y = y./prctile(y,95);
hh(4) = plot(list.date(idx),y,'r','linewidth',1,'linestyle','-');
idx = ~isnan(list.deceased);
deceased = movmean(list.deceased(idx(1:end-1)),[3 3],'omitnan');
ylim([0 1.25])
ylabel('שיעור ביחס למקסימום')
y = deceased./prctile(deceased,95);
hh(5) = plot(list.date(idx(1:end-1)),y,'k','linewidth',1);
% ylim([0 100])
set(gca,'FontSize',13)
xlim([list.date(1)-1 list.date(end)+1])
% ax = gca;
% ax.YAxis(2).Color = 'r';
% ax.YAxis(1).Color = 'k';
% ylim([0 max(list.hospitalized)+20])
% xtickangle(45)
grid on
box off
% legHeb = {'מאושפזים','קל','בינוני','קשה','מונשמים','נפטרים'};
% iLast = find(idx,1,'last');
% legNum = {str(list.hospitalized(iLast)),...
%     str(list.hospitalized(iLast)-list.critical(iLast)-list.severe(iLast)),...
%     str(list.severe(iLast)),...
%     str(list.critical(iLast)),...
%     str(list.on_ventilator(iLast)),...
%     str(round(deceased(end)))};
% legend(hh,[legHeb{2},' (',legNum{2},')'],[legHeb{3},' (',legNum{3},')'],...
%     [legHeb{4},' (',legNum{4},')'],[legHeb{5},' (',legNum{5},')'],[legHeb{6},' (',legNum{6},')'],'location','north')
ylabel('נפטרים')
title('מדדים מנורמלים לפי אחוזון 95')
xtickangle(30)
