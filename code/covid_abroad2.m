cd ~/covid-19-israel-matlab/data/Israel
% tests = readtable('tests.csv'); 
listD = readtable('dashboard_timeseries.csv');
abroad = readtable('infected_abroad.xlsx');
listD = listD(find(ismember(listD.date,abroad.date),1):end,:);
extra = height(listD)-height(abroad);
if extra > 0
    row = height(abroad)+1:height(abroad)+extra;
    abroad.date(end+1:end+extra) = listD.date(row);
end
abroad.tests = listD.tests;
abroad.positive = listD.tests_positive;
if sum(abroad{end,4:5}) == 0
    abroad(end,:) = [];
end
writetable(abroad,'infected_abroad.xlsx')
%%

%%
figure;
h1 = bar(abroad.date,abroad{:,4:5},'stacked');
h1(1).FaceColor = [0.847, 0.435, 0.227];
h1(2).FaceColor = [0.588, 0.247, 0.239];
xt = dateshift(datetime('today'),'start','week');
xt = fliplr(xt:-7:abroad.date(1));
title({'מאומתים לפי מקור הדבקה','cases by infection source'})
legend('local     מקומי','abroad   חו"ל')
set(gca,'XTick',xt)
grid on
xlim([abroad.date(1)-1,abroad.date(end)+1])
text(abroad.date-0.4,sum(abroad{:,4:5},2)+10,cellstr(str(abroad{:,5})),'Color','k')

%%
figure;
yy = abroad{:,5}./(abroad{:,4}+abroad{:,5})*100;
yys = nan(size(yy));
idx = ~isnan(yy);
yys(idx) = movmean(yy(idx),[3 3]);
plot(abroad.date,yy,'.b')
hold on
plot(abroad.date,yys,'b')
set(gca,'XTick',xt)
title('infected abroad (%) נדבקו בחו"ל')
set(gca,'XTick',xt)
grid on
box off
ylabel('%')
set(gcf,'Color','w')
xlim(abroad.date([1,end]))


%%
yy = abroad{:,5}./abroad{:,6}*100;
% yys = nan(size(yy));
% idx = ~isnan(yy);
yys = movmean(yy,[3 3],'omitnan');
yys(1:find(~isnan(yy),1)) = nan;
figure;
% plot(abroad.date,yy,'.','Color',[0.85, 0.247, 0.239])
hold on
hl(1) = plot(abroad.date,yys,'Color',[0.85, 0.247, 0.239],'linewidth',1);

yy = (abroad{:,3}-abroad{:,5})./(abroad{:,2}-abroad{:,6})*100;
% yys = nan(size(yy));
% idx = ~isnan(yy);
yys = movmean(yy,[3 3],'omitnan');
yys(1:find(~isnan(yy),1)) = nan;
% plot(abroad.date,yy,'.','Color',[0.847, 0.435, 0.227],'MarkerSize',10)
hold on
hl(2) = plot(abroad.date,yys,'Color',[0.847, 0.435, 0.227],'linewidth',2);
legend(hl(2:-1:1),'local     מקומי','abroad   חו"ל')
ylim([0 1])
grid on
title('positive tests (%) בדיקות חיוביות')
set(gca,'XTick',xt)
ylabel('%')
% ylabel('%')
set(gcf,'Color','w')
xlim([abroad.date(12),abroad.date(end)+1])
%%
figure;
yyaxis left
h3 = bar(abroad.date-0.1,abroad{:,6});
ylim([0 6000])
% h3.FaceColor = [0.847, 0.435, 0.227];
yyaxis right
h4 = bar(abroad.date+0.1,abroad{:,5});
ylim([0 60])

title({'בדיקות ותוצאות חיוביות לבאים מחו"ל','tests and cases for incoming passengers'})
legend('tests     בדיקות','positive   חיוביים','location','northwest')
set(gca,'XTick',xt)
grid on
xlim([abroad.date(1)-1,abroad.date(end)+1])
set(gcf,'Color','w')

RR = (sum(abroad.local(end-7:end-1))/sum(abroad.local(end-14:end-8)))^0.65;

%%
pow = 0.65;
shift = 3;
days = 7;
abroad = readtable('~/covid-19-israel-matlab/data/Israel/infected_abroad.xlsx');
if sum(abroad{end,4:6}) == 0
    abroad(end,:) = [];
end
% abroad(end,:) = [];
Rl = movmean(abroad.local,[6 0]);
Rl = Rl(days+1:end)./Rl(1:end-days);
Ra = movmean(abroad.incoming,[6 0]);
Ra = Ra(days+1:end)./Ra(1:end-days);
Rb = movmean(abroad.local+abroad.incoming,[6 0]);
Rb = Rb(days+1:end)./Rb(1:end-days);
iD2 = length(Rb)-3;
%%
figure('units','normalized','position',[0.3,0.3,0.5,0.5]);
yyaxis left
% plot(date,R,'LineWidth',2)
% hold on;
% plot(listD.date(1)-shift:listD.date(end)-days-shift,rr.^pow,':k','LineWidth',1.5)
h(1) = plot(abroad.date(1)-shift:abroad.date(end)-days-shift,Rl.^pow,'g-','LineWidth',1.5);
hold on
h(2) = plot(abroad.date(1)-shift:abroad.date(end)-days-shift,Ra.^pow,'r-','LineWidth',1.5);
h(3) = plot(abroad.date(1)-shift:abroad.date(end)-days-shift,Rb.^pow,'k-','LineWidth',1.5);
ylim([-2 4])
set(gca,'YTick',-3:0.5:3.5,'YTickLabel',[repmat({'     '},6,1);cellstr(str((0:0.5:3.5)'))])

a = sum(abroad.local(iD2+4:iD2+4+6));
b = sum(abroad.local(iD2-3:iD2+3));
c = sum(abroad.incoming(iD2+4:iD2+4+6));
d = sum(abroad.incoming(iD2-3:iD2+3));
ylabel R
y = round(Rl(end).^pow,2);
text(abroad.date(iD2)+0.5,y,[str(y),'=(',str(a),'/',str(b),')^0^.^6^5'],'Color',[0.2,0.7,0.2])
y = round(Ra(end).^pow,2);
text(abroad.date(iD2)+0.5,y,[str(y),'=(',str(c),'/',str(d),')^0^.^6^5'],'Color',[0.7,0.2,0.2])
y = round(Rb(end).^pow,2);
text(abroad.date(iD2)+0.5,y,[str(y),'=(',str(a+c),'/',str(b+d),')^0^.^6^5'])

yyaxis right
bar(abroad.date,abroad.local,'FaceColor',[0.8 0.8 0.8],'FaceAlpha',0.5)
hold on
bar(abroad.date,-abroad.incoming,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.5)
idx = iD2+4:iD2+4+6;
h(4) = bar(abroad.date(idx),abroad.local(idx),'FaceColor',[0.2 0.8 0.2]);
h(5) = bar(abroad.date(idx),-abroad.incoming(idx),'FaceColor',[0.8 0.2 0.2]);
idx = iD2-3:iD2+3;
h(6) = bar(abroad.date(idx),abroad.local(idx),'FaceColor',[0.5 0.8 0.5]);
h(7) = bar(abroad.date(idx),-abroad.incoming(idx),'FaceColor',[0.8 0.5 0.5]);

ylim([-80 160])
ylabel('Cases')
% 
% text(x,repmat(5,length(x),1),str(listD.tests_positive(iD1:end-1)))

text([abroad.date(iD2),abroad.date(iD2)+7]-0.52,[30 30],{str(b),str(a)},'FontSize',15)
text([abroad.date(iD2),abroad.date(iD2)+7]-0.52,[-30 -30],{str(d),str(c)},'FontSize',15)
xtickformat('dd/MM')
set(gca,'XTick',abroad.date,'YTick',-120:20:120,'YTickLabel',strrep(cellstr(str((-120:20:120)')),'-',''))
xtickangle(90)
grid on
xlim(datetime('today')-[35,0])
legend(h, 'R local','R incoming','R all','local this week','incoming this week',...
    'local last week','incoming last week','location','north')
