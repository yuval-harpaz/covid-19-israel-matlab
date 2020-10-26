list = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
vars = {'flights','schools','restaurants','Beach','shops','m_100','m_500','trains','Passover','Masks'}';
date = list.date(1);
strr = 't = table(date,';
for ii = 1:length(vars)
    eval([vars{ii},' = nan;']);
    strr = [strr,vars{ii},','];
end
eval([strr(1:end-1),');'])
t.date(1:height(list)) = list.date;
t{:,2:end} = nan;
t.flights(ismember(list.date,[datetime(2020,3,8):datetime(2020,6,29),datetime(2020,9,23):list.date(end)])) = 1;
t.schools(ismember(list.date,[datetime(2020,3,12):datetime(2020,5,17),...
    datetime(2020,7,1):datetime(2020,8,31),datetime(2020,9,18):list.date(end)])) = 1;
t.restaurants(ismember(list.date,[datetime(2020,3,14):datetime(2020,5,27),datetime(2020,7,17):list.date(end)])) = 1;

Start = datetime({'08-Mar-2020','12-Mar-2020','14-Mar-2020','19-Mar-2020','15-Mar-2020',...
    '25-Mar-2020','25-Mar-2020','25-Mar-2020','07-Apr-2020','12-Apr-2020'}');
End = repmat(datetime('today'),length(Start),1);

t = table(Measures,Start,End);
t.End(1) = datetime('today');
t.End(2) = datetime('17-May-2020');
t.End(3) = datetime('27-May-2020');
t.End(4) = datetime('20-May-2020');
t.End(5) = datetime('26-Apr-2020');
t.End(6) = datetime('1-May-2020');
t.End(7) = datetime('30-Apr-2020');
t.End(9) = datetime('11-Apr-2020');
t = t([1,2,3,5,4,8,6,9,10],:);
idx = ~isnan(list.hospitalized);
figure;
h = plot(list.date(idx),list.hospitalized(idx))
text(datetime('12-Mar-2020'),550,'Hospitalized','Color',h.Color)
hold on
for ii = 1:height(t)
    h = plot(t{ii,2:3},30*[ii,ii]);
    text(t{ii,2}-15,30*ii,t.Measures{ii},'Color',h.Color)
end

iXtick = fliplr(dateshift(list.date(end),'start','day'):-7:list.date(1)-10);
xlim([iXtick(1)-10,datetime('today')])
set(gca,'XTick',iXtick,'FontSize',12)
xtickangle(30)
box off
grid on
title('Israel actions vs N patients')
% plane = imread('https://p7.hiclipart.com/preview/190/547/594/airplane-computer-icons-symbol-cargo-plane-shipping-transportation-wings-icon.jpg');
% plane = plane(164:346,106:398,1) > 100;
% axes('pos',[.1 .6 .5 .3])
% imshow('coins.png')