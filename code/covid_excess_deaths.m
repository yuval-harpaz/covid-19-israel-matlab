t70 = readtable('~/Documents/over70.csv');
t = readtable('~/Documents/allAges.csv');
pop = readtable('~/Downloads/IsraelPopulation2009.csv');


figure
subplot(2,1,1)
h = plot(t{:,12:21}./pop.Var2(3:end)'*10^6);
col = colormap(jet(10));
for ii = 12:21
    h(ii-11).Color = col(ii-11,:);
    if ii == 21
        h(10).LineWidth = 2;
    end
end
xlim([1 12])
xlabel('month')
ylabel('deaths per million')
title('All ages')
grid on
box off
legend(num2str((2011:2020)'))
subplot(2,1,2)
h = plot(t70{:,12:21}./pop.Var2(3:end)'*10^6);
col = colormap(jet(10));
for ii = 12:21
    h(ii-11).Color = col(ii-11,:);
    if ii == 21
        h(10).LineWidth = 2;
    end
end
xlim([1 12])
xlabel('month')
ylabel('deaths per million')
title('All ages')
grid on
box off
legend(num2str((2011:2020)'))
title('Over 70')