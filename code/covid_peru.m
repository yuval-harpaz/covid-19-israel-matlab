function covid_peru

!wget -O ~/Downloads/peru_tests.csv https://raw.githubusercontent.com/jmcastagnetto/covid-19-peru-data/main/datos/covid-19-peru-data.csv
t = readtable('~/Downloads/peru_tests.csv');

n = cellfun(@str2num,strrep(t.total_tests,'NA','0'));
n(n == 0) = nan;
c = cellfun(@str2num,strrep(t.confirmed,'NA','0'));
date = unique(t.date);
for ii = 1:length(date)
    N(ii,1) = nansum(n(ismember(t.date,date(ii))));
    C(ii,1) = nansum(c(ismember(t.date,date(ii))));
end
nd = diff(N);
nd(nd < 0) = nan;
nd(nd > 200000) = nan;
cd = diff(C);
cd(cd < 0) = nan;
cd(cd > 30000) = nan;


figure
yyaxis left
plot(date(2:end),nd)
ylabel('tests')
yyaxis right
plot(date(2:end),cd)
ylabel('positive')
title('Peru')
set(gca,'YTickLabel',{'0','5,000','10,000','15,000','20,000','25,000','30,000'})
ax = gca;
ax.YRuler(1).Exponent = 0;
ax.YAxis(1).TickLabelFormat = '%,.0f';

% ax.YRuler(2).Exponent = 0;
% ax.YAxis(2).TickLabelFormat = '%,.0f';

% 
% tSer = t(ismember(t.tipo_prueba,'serológicas'),:);
% tPCR = t(ismember(t.tipo_prueba,'moleculares'),:);
% t = {tPCR;tSer};
% for ii = 1:2
%     n = cellfun(@str2num,strrep(t{ii}.personas,'NA','0'));
%     n(n == 0) = nan;
%     date = t{ii}.fecha(ismember(t{ii}.resultado,'positivo'));
%     y = n(ismember(t{ii}.resultado,'negativo'));
%     y(:,2) = n(ismember(t{ii}.resultado,'positivo'));
%     yd = diff(y);
%     yd(yd > 20000) = nan;
%     yd(yd < 0) = nan;
%     figure;bar(date(2:end),yd,'stacked')
% end