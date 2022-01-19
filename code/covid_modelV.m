listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
fid = fopen('~/Downloads/Epidemic Calculator.html')
txt = fread(fid);
fclose(fid)
txt = native2unicode(txt');
bars = regexp(txt,'width="5.75"','split');
pnt = [];
for ii = 2:length(bars)
    if ~strcmp(bars{ii}(2:4),'hei')
        disp(bars{ii}(1:10))
    end
    iq = strfind(bars{ii}(9:end),'"');
    pnt(ii-1,1) = eval(bars{ii}(iq(1)+9:iq(2)+7));
end

data = reshape(pnt,5,length(pnt)/5)';
figure;
bar(data(:,3:end)/400*9500000,'stacked')
legend('recovered','infectious','exposed');
exp_dif = diff(sum(data,2))/400*9500000;

cases2d = movmean(listD.tests_positive1(650:end),[3 3]);
cases2d = cases2d(1:end-1)+cases2d(2:end);
%%
figure;
plot(cases2d)
hold on
plot(exp_dif)
