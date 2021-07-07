function covid_VE_to_perc(vacc,pnt)
if nargin == 0
    vacc = 92; % percents of vaccinated. 92% is for 50+ y/o general sector
    pnt = 54; % observed
end
xx = [0,10:10:90,95,99,100];
for ii = 1:length(xx)  % VE
    sickNotVac = 100-vacc;
    healthyVac = vacc*(xx(ii)/100);
    sickVac(ii,1) = vacc-healthyVac;
    ratio(ii,1) = sickVac(ii,1)./(sickVac(ii,1)+sickNotVac);
end
ratMatch = 0;
for ii = 1:0.01:100  % VE
    healthyVac = vacc*(ii/100);
    sickV = vacc-healthyVac;
    rat = 100*sickV./(sickV+sickNotVac);
    if abs(rat-pnt) < abs(ratMatch-pnt)
        ratMatch = rat;
        xMatch = ii;
    end
end
figure;
plot(xx,100*ratio)
grid on
axis square
set(gca,'xtick',xx([1:end-3,end]))
hold on
plot(xMatch,ratMatch,'*k')
title({'מיעילות חיסון לשיעור המחוסנים החולים, לפי 92% התחסנות','from VE to ratio of vaccinated cases for 92% vaccination rate'})
set(gcf,'Color','w')
ylabel('ratio of vaccinated % שיעור המחוסנים')
xlabel('Vaccine effectiveness % יעילות החיסון')
legend('simulation','observed')