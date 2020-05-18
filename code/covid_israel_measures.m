list = readtable('~/covid-19_data_analysis/data/Israel/Israel_ministry_of_health.csv');
idx = ~isnan(list.hospitalized);

Start = datetime({'08-Mar-2020','12-Mar-2020','14-Mar-2020','19-Mar-2020','15-Mar-2020',...
    '25-Mar-2020','25-Mar-2020','25-Mar-2020','07-Apr-2020','12-Apr-2020'}');
End = repmat(datetime('today'),length(Start),1);
Measures = {'flights','schools','restaurants','Beach','shops','100m','500m','trains','Passover','Masks'}';
t = table(Measures,Start,End);
t.End(2) = datetime('1-May-2020');
t.End(5) = datetime('26-Apr-2020');
t.End(6) = datetime('1-May-2020');
t.End(7) = datetime('30-Apr-2020');
t.End(9) = datetime('11-Apr-2020');
t = t([1,2,3,5,4,8,6,9,10],:);

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