function covid_local_dual(mult)
if ~exist('mult','var')
    mult = [1.1, 6.1];
end
ww =  [0.8,1.2,1,1,1,1,0.6];
ww = ww./mean(ww);
tot0 = 500+456;
% ratio = 500/tot0;
ratio = 0.6;
rr = round([ratio*tot0,(1-ratio)*tot0]);
% rr = [500,456];
day1 = datetime(2021,11,17+7*5);
dateR = day1:7:datetime('today')+20;
for idr = 2:length(dateR)
    rr(idr,1) = rr(idr-1,1)*mult(1);
    rr(idr,2) = rr(idr-1,2)*mult(2);
end
pred = [];
for idr = 1:length(rr)
    pred = [pred,rr(idr,:)'.*((mult.^(1/7))'.^(-3:3)).*ww];
end
pred = round(pred);
dateRd = dateR(1)-3;
dateRd = dateRd:dateRd+length(pred)-1;
cd ~/covid-19-israel-matlab/data/Israel
options = weboptions('Timeout', 30);
url = 'https://datadashboardapi.health.gov.il/api/queries/positiveArrivingAboardDaily';
paad = webread(url, options);
paad = struct2table(paad);
paad = paad(ismember(paad.visited_country,'כלל המדינות'),:);
abroad = sum(paad{:,3:4},2);
date = datetime(paad.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
% url = 'https://datadashboardapi.health.gov.il/api/queries/testResultsPerDate';
% tCases = webread(url, options);
% tCases = struct2table(tCases);
% dateCases = datetime(tCases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
% keep = ismember(dateCases,date);
% cases = tCases.positiveAmount(keep);
url = 'https://datadashboardapi.health.gov.il/api/queries/infectedPerDate';
tCases = webread(url, options);
tCases = struct2table(tCases);
dateCases = datetime(tCases.date, 'InputFormat', 'yyyy-MM-dd''T''hh:mm:ss.SSS''Z');
keep = ismember(dateCases,date);
cases = tCases.amount(keep);
local = cases-abroad;
local(local < 0) = 0;
%%
lin1 = find(date == dateR(1));
yy = local(lin1-1:end);
xx = 1:length(yy)+14;
%%
xl = {[dateR(1)-7*4*6 datetime('today')+10],[dateR(1)-7*4 datetime('today')+10]};
for jj = 1:2
    figure('units','normalized','position',[0 0 1 1])
    for ii = 1:2
        subplot(1,2,ii)
        h1 = bar(dateRd,sum(pred,1),1,'stacked','FaceColor',[1 1 1]);
        hold on
        h2 = bar(date,local,'FaceColor',[0.2 0.65 0.2],'EdgeColor','none','FaceAlpha',0.75);
        sm = movmean(local,[3 3]);
        h3 = plot(date(1:end-3),sm(1:end-3),'r','LineWidth',3);
        h4 = plot(dateR,sum(rr,2),'b','LineWidth',2);
        set(gca,'XTick',datetime(2021,11,17)-7*100:7:datetime('today')+20)
        xtickformat('dd/MM')
        grid on
        box off
        legend([h1(1),h2,h3,h4],'prediction','cases (local)','cases, 7 days average (-3 to +3)',...
            ['weekly growths ',str(mult(1)),'(Δ), and ',str(mult(2)),'(Ο)'],'location','northwest')
        title('Cases vs exponential growth')
        ylabel('Cases')
        set(gcf,'Color','w')
        ax = gca;
        ax.YRuler.Exponent = 0;
        ax.YAxis.TickLabelFormat = '%,.0g';
        xtickangle(90)
        xlim(xl{jj});
        if ii == 2
            set(gca, 'YScale', 'log');
            title('Cases vs exponential growth (log scale)')
            
        end
    end
end
disp(nthroot(mult(2),7).^(1:7))