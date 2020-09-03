month = datetime(2019,1:12,1)';
month.Format = 'MMM';
only19 = zeros(12,1);
other19 = zeros(12,1);
only19cum = zeros(12,1);
other19cum = zeros(12,1);
only18cum = zeros(12,1);
other18cum = zeros(12,1);
for iw = 1:52
    d1 = xlsread(['IWER',str(iw),'_2019.xlsx'],'I13:I13');
    % d7 = xlsread(['IWER',str(iw),'_2019.xlsx'],'L13:L13');
    im = find(ismember(month,dateshift(datetime(datestr(d1+693960)),'start','month')),1);
    if isempty(im)
        im = 1;
    end
    pne = xlsread(['IWER',str(iw),'_2019.xlsx'],'Q134:S136');
    only19(im) = only19(im)+pne(1);
    other19(im) = other19(im)+pne(3,1);
%     if im == 1
    only19cum(im) = pne(1,2);
    other19cum(im) = pne(3,2);
    only18cum(im) = pne(1,3);
    other18cum(im) = pne(3,3);
%     else
%         only19cum(im) = pne(1,2)-only19cum(im-1);
%         other19cum(im) = pne(3,2)-other19cum(im-1);
%         only18cum(im) = pne(1,3)-only18cum(im-1);
%         other18cum(im) = pne(3,3)-other18cum(im-1);
%     end
    IEprog(iw);
end
only18 = diff([0;only18cum]);
other18 = diff([0;other18cum]);

only20 = zeros(12,1);
other20 = zeros(12,1);
only20cum = zeros(12,1);
other20cum = zeros(12,1);
for iw = 1:34
    m = str(iw);
    if length(m) == 1
        m = ['0',m];
    end
    d1 = xlsread(['IWER_',m,'_2020.xlsx'],'I13:I13');
    im = find(ismember(cellstr(datestr(month,'mmm')),datestr(datetime(datestr(d1+693960)),'mmm')),1);
    if im == 12
        im = 1;
    end
    pne = xlsread(['IWER_',m,'_2020.xlsx'],'Q134:S136');
    only20(im) = only20(im)+pne(1);
    other20(im) = other20(im)+pne(3,1);
    only20cum(im) = pne(1,2);
    other20cum(im) = pne(3,2);
    IEprog(iw);
end
only20(only20 == 0) = nan;
other20(other20 == 0) = nan;
t = table(month,only18,other18,only19,other19,only20,other20); 

figure;
plot(t.month,[t.only18+t.other18,t.only19+t.other19,t.only20+t.other20])
legend('2018','2019','2020')
box off
grid on