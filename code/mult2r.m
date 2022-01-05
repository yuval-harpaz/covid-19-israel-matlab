c = 0;
for ii = 1:0.5:100
    x = [ones(62,1);((ii^(1/7)).^(1:62))'];
    r = covid_R31(x);
    c = c+1;
    r7(c,1) = r(end);
end
c = 0;
for ii = 0.5:0.1:10
    mult = nthroot(2,ii);
    x = ones(62,1);
    x = [x;(mult.^(1:62))'];
    r = covid_R31(x);
    c = c+1;
    r2(c,1) = r(end);
end
figure;
subplot(1,2,1)
plot(1:0.5:100,r7)
grid on
grid minor
set(gca,'YTick',0:1:6)
ylabel('R')
xlabel('How many times COVID multiplies in a week')
subplot(1,2,2)
plot(0.5:0.1:10,r2)
grid on
grid minor
ylabel('R')
xlabel('In how many days COVID multiplies')