function covid_R14
json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectionFactor');
json = jsondecode(json);
t = struct2table(json);
date = datetime(strrep(t.day_date,'T00:00:00.000Z',''));
ful = ~cellfun(@isempty ,t.R);
R = nan(length(date),1);
R(ful,1) = cellfun(@(x) x,t.R(ful));
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
mm = movmean(listD.tests_positive,[6 0]);
% mm = floor(movmean(listD.tests_positive,[6 0]));
days = 7;
rr = mm(days+1:end)./mm(1:end-days);

%%
pow = 0.65;
shift = 3;
%%
figure('units','normalized','position',[0.3,0.3,0.5,0.5]);
Rest = rr.^pow;
t = listD.date(1)-shift:listD.date(end)-days-shift;
date1 = dateshift(datetime('today'),'start','week')-22-7;
dateLast = date(find(~isnan(R),1,'last'));
title('R by cases  (red/pink)^0^.^6^5')
for iDay = 1:14
    date2 = dateLast-(14-iDay);
    
    yyaxis left
    % plot(date,R,'LineWidth',2)
    % hold on;
    
    % if strcmp(day,'last')
    %     date2 = dateLast;
    % else
    %     date2 = day;
    % end
    i1 = find(ismember(t,date1));
    i2 = find(ismember(t,date2));
    plot(t(i1-1:i2),Rest(i1-1:i2),'-b','LineWidth',2,'Marker','o','MarkerFaceColor',...
        'b','MarkerEdgeColor','none')
    iD1 = find(ismember(listD.date,date1));
    iD2 = find(ismember(listD.date,date2));
    ylim([-1 2])
    ylabel('R')
    a = sum(listD.tests_positive(iD2+4:iD2+4+6));
    b = sum(listD.tests_positive(iD2-3:iD2+3));
    y = round((a/b)^pow,2);
    x = listD.date(iD1:end-1)-0.25;
%     text(t(i2)+1,y,[str(y),'=(',str(a),'/',str(b),')^0^.^6^5'])
    set(gca,'YTick',0:0.2:2)
    yyaxis right
    bar(listD.date(iD1:end-1),listD.tests_positive(iD1:end-1),'FaceColor',[0.8 0.8 0.8])
    hold on
    bar(listD.date(iD2+4:iD2+4+6),listD.tests_positive(iD2+4:iD2+4+6),'FaceColor',[0.8 0.2 0.2])
    bar(listD.date(iD2-3:iD2+3),listD.tests_positive(iD2-3:iD2+3),'FaceColor',[0.8 0.5 0.5])
    ylim([0 120])
    ylabel('Cases')
    
    text(x,repmat(5,length(x),1),str(listD.tests_positive(iD1:end-1)))
%     text([date2,date2+7]-0.52,[40 40],{str(b),str(a)},'FontSize',15)
    xtickformat('dd/MM')
    set(gca,'XTick',x+0.25)
    xtickangle(90)
    grid on
    xlim([date1-0.75,dateLast+10.75])
    pause(1)
    fn = str(iDay);
    if length(fn) == 1
        fn = ['0',fn];
    end
    eval(['export_fig tmp',fn,'.jpg -nocrop -r 300'])
end
% !ffmpeg -r 1 -i tmp%02d.png -vcodec libx264 R.mp4
!ffmpeg -r 1 -i tmp%02d.jpg -vf fps=24 R.mp4
