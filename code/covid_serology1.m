dpm = [771;1764;1373;757;902;805];
antib = [10;19.90;11.30;7.10;17.50;9.90];
city = {'Wuhan';'NYC';'Madrid';'Barcelona';'London';'Boston'};
t = table(city,antib,dpm);
[~,order] = sort(dpm,'descend');
t = t(order,:);

%x = [ones(length(dpm),1) dpm];
b = dpm\antib;
y_pred = [35;t.dpm(1)]*b;

figure;
for ii = 1:height(t)
    scatter(t.antib(ii),t.dpm(ii),20,'fill')
    hold on
end
scatter(y_pred(1),35,20,'fill','k')
line([y_pred(1),y_pred(2)],[35,t.dpm(1)],'color','k')
legend([t.city;{'Israel';'trend line'}])
xlim([0 25])
ylim([0 2000])
grid minor
grid on
xlabel('Antibodies (%)')
ylabel('Deaths Per Million')
set(gca,'FontSize',13)
title('Predicting serology tests outcome in Israel')

% eng = [145000;122000;28000;51000]./55980000*100;
% eng(:,2) = flipud([25546;30908;34793;37368]./55.980000);
% scatter(eng(:,1),eng(:,2),20,'fill','g')
