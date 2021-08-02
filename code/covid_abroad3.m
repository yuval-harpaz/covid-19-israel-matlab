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

mxR = 6;
xt = -mxR/3:0.5:mxR;
xtl = cellstr(str((0:0.5:mxR)'));
xtl = [repmat({'     '},length(xt)-length(xtl),1);xtl];

figure('units','normalized','position',[0.3,0.3,0.5,0.5]);
yyaxis right
% plot(date,R,'LineWidth',2)
% hold on;
% plot(listD.date(1)-shift:listD.date(end)-days-shift,rr.^pow,':k','LineWidth',1.5)
h(1) = plot(abroad.date(1)-shift:abroad.date(end)-days-shift,Rl.^pow,'g-','LineWidth',1.5);
hold on
h(2) = plot(abroad.date(1)-shift:abroad.date(end)-days-shift,Ra.^pow,'r-','LineWidth',1.5);
h(3) = plot(abroad.date(1)-shift:abroad.date(end)-days-shift,Rb.^pow,'k-','LineWidth',1.5);
ylim([xt(1) xt(end)])

set(gca,'YTick',xt,'YTickLabel',xtl)

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

yyaxis left
bar(abroad.date,abroad.local,'FaceColor',[0.8 0.8 0.8],'FaceAlpha',0.5)
hold on
bar(abroad.date,-abroad.incoming,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.5)
idx = iD2+4:iD2+4+6;
h(4) = bar(abroad.date(idx),abroad.local(idx),'FaceColor',[0.2 0.65 0.2]);
h(5) = bar(abroad.date(idx),-abroad.incoming(idx),'FaceColor',[0.65 0.2 0.2]);
idx = iD2-3:iD2+3;
h(6) = bar(abroad.date(idx),abroad.local(idx),'FaceColor',[0.5 0.8 0.5]);
h(7) = bar(abroad.date(idx),-abroad.incoming(idx),'FaceColor',[0.8 0.5 0.5]);

yopt = 240:60:2400;
ie = yopt(find(yopt > max(abroad.local(end-32:end)),1));
ylim([-ie/3 ie])
ylabel('Cases')
% 
% text(x,repmat(5,length(x),1),str(listD.tests_positive(iD1:end-1)))

text([abroad.date(iD2),abroad.date(iD2)+7]-0.52,[30 30],{str(b),str(a)},'FontSize',15)
text([abroad.date(iD2),abroad.date(iD2)+7]-0.52,[-30 -30],{str(d),str(c)},'FontSize',15)
xtickformat('dd/MM')

set(gca,'XTick',abroad.date,'YTick',-120:20:ie,'YTickLabel',strrep(cellstr(str((-120:20:ie)')),'-',''))
xtickangle(90)
grid on
xlim(datetime('today')-[35,0])
legend(h, 'R local','R incoming','R all','local this week','incoming this week',...
    'local last week','incoming last week','location','northwest')
title('cases by source for the last 2 weeks   מאומתים לפי מקור הדבקה לשבועיים האחרונים')

%% 
dateR = datetime(2021,6,22):7:datetime('today')+20;
lin1 = 72;
yy = abroad.local(lin1-1:end);
xx = 1:length(yy)+14;
fac = yy(1:23)\xx(1:23)';
rr = 118;
mult = 1.425^(1/0.65);
for idr = 2:length(dateR)
    rr(idr,1) = rr(idr-1)*mult;
end

% ww = [1/3,0.6,1,1,1,1,1];
ww =  [0.6,0.8,1,1,1,1,1];
ww = ww./mean(ww);
pred = [];
for idr = 1:length(rr)
    pred = [pred,rr(idr)*((mult^(1/7)).^(-3:3)).*ww]
end
dateRd = dateR(1)-3;
dateRd = dateRd:dateRd+length(pred)-1;
figure;
bar(dateRd,pred,1,'FaceColor',[1 1 1])
hold on
bar(abroad.date,abroad.local,'FaceColor',[0.2 0.65 0.2],'EdgeColor','none','FaceAlpha',0.75)
% regressBasic(abroad.local(58:end))
sm = movmean(abroad.local,[3 3]);
plot(abroad.date(1:end-3),sm(1:end-3),'r','LineWidth',3)
% plot(abroad.date(lin1-1)+xx,xx/fac,'k')

% dateR = dateR(1:7:end);

plot(dateR,rr,'b','LineWidth',2)
set(gca,'XTick',datetime(2021,6,22)-7*100:7:datetime('today')+20)
xtickformat('dd/MM')
grid on
box off
legend('prediction','cases (local)','cases, 7 days average (-3 to +3)','weekly multiplication factor = 1.724','location','northwest')
title('Cases, forward projection by linear and exponential rates')
ylabel('Cases')
set(gcf,'Color','w')
xlim([datetime(2021,6,1) datetime('today')+20])