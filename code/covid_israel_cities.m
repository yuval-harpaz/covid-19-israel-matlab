city = {'ירושלים';'תל אביב';'חיפה';'ראשון לציון';'פתח תקווה';'אשדוד';'נתניה';'באר שבע';'בני ברק';'חולון';'רמת גן';'אשקלון';'רחובות'};
population = [919438;451523;283640;251719;244275;224628;217243;209002;198863;194273;159160;145967;141579];
pop = table(city,population);
 listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
for ii = 1:length(city)
    data = urlread(['https://data.gov.il/api/3/action/datastore_search?q=',pop.city{ii},'&resource_id=8a21d39d-91e3-40db-aca1-f73f7ab1df69&limit=10000000']);
    data = jsondecode(data);
    data = struct2table(data.result.records);
    dateRow = datetime(data.Date);
    [dateRow,order] = unique(dateRow);
    data = data(order,:);
    data.Cumulated_deaths = strrep(data.Cumulated_deaths,'<15','0');
    data.Cumulative_verified_cases = strrep(data.Cumulative_verified_cases,'<15','0');
    deathRow = cellfun(@str2num,data.Cumulated_deaths);
    caseRow = cellfun(@str2num,data.Cumulative_verified_cases);
    for month = 3:13
        death(month-2,ii) = deathRow(find(dateRow < datetime(2020,month+1,1),1,'last'));
        cases(month-2,ii) = caseRow(find(dateRow < datetime(2020,month+1,1),1,'last'));
    end
end
ddpm = diff(death)./pop.population'*10^6;
dpm = death(end,:)./pop.population'*10^6;
dcpm = diff(cases)./pop.population'*10^6;
cpm = cases(end,:)./pop.population'*10^6;
%%
col = colormap(jet(13));
col = flipud(col);
[~,order] = sort(ddpm(7,:),'descend');
% col = col(order,:);
figure;
subplot(1,2,1)
for ii = 1:13
    hb(ii) = bar(ii,dpm(ii),'linestyle','none','FaceColor',col(order == ii,:));
    hold on
end
set(gca,'XTick',1:13,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מתים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('תמותה למליון סך הכל')
subplot(1,2,2)
% yyaxis left
h = plot(datetime(2020,4:13,1),ddpm,'linewidth',1);
shape = repmat({'o','s','^'},1,5);
for ii = 1:13
    h(ii).Color = hb(ii).FaceColor;
    h(ii).Marker = shape{order == ii};
    h(ii).MarkerFaceColor = h(ii).Color;
end
legend(h(order),pop.city(order))
% hold on
% h2 = plot(datetime(2020,4:13,1),ddpm(:,9),'r','linewidth',2);
% legend([h1(1),h2],'ערים בישראל','בני ברק','location','northwest')
set(gcf,'Color','w')
xlim([datetime(2020,3,15) datetime(2020,3+size(ddpm,1),15)])
xlabel('חודש')
ylabel('מתים למליון')
set(gca,'xtick',datetime(2020,4:3+size(ddpm,1),1))
grid on
box off
title('תמותה למליון לחודש')
xtickformat('MMM')


figure;
subplot(1,2,1)
for ii = 1:13
    hb(ii) = bar(ii,cpm(ii),'linestyle','none','FaceColor',col(order == ii,:));
    hold on
end
% bar(cpm,'linestyle','none')
set(gca,'XTick',1:13,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מקרים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('מקרים למליון סך הכל')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
subplot(1,2,2)
h = plot(datetime(2020,4:13,1),dcpm,'linewidth',1);
for ii = 1:13
    h(ii).Color = hb(ii).FaceColor;
    h(ii).Marker = shape{order == ii};
    h(ii).MarkerFaceColor = h(ii).Color;
end
legend(h(order),pop.city(order))
set(gcf,'Color','w')
xlim([datetime(2020,3,15) datetime(2020,3+size(ddpm,1),15)])
xlabel('חודש')
ylabel('מקרים למליון')
set(gca,'xtick',datetime(2020,4:3+size(ddpm,1),1))
grid on
box off
title('מקרים למליון לחודש')
xtickformat('MMM')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';


%%
json1 = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=64edd0ee-3d5d-43ce-8562-c336c24dbc1f&limit=5000');;
json = jsondecode(json1);
js = struct2cell(json.result.records);
popA = reshape([js{10:end,:}],7,size(js,2))';
[~,orderA] = sort(popA(:,1),'descend');
popA = popA(orderA,:);

cn = {json.result.records(orderA(1:15)).x_______}';
cn(2) = city(2);
[isx,idx] = ismember(strrep(city,' ',''),strrep(cn,' ',''));
pop13 = popA(idx,:);

ddpm = diff(death)./pop13(:,end)'*10^6;
dpm = death(end,:)./pop13(:,end)'*10^6;
dcpm = diff(cases)./pop13(:,end)'*10^6;
cpm = cases(end,:)./pop13(:,end)'*10^6;

% col = colormap(jet(13));
% col = flipud(col);
% [~,order] = sort(ddpm(7,:),'descend');
% col = col(order,:);
figure;
subplot(1,2,1)
for ii = 1:13
    hb(ii) = bar(ii,dpm(ii),'linestyle','none','FaceColor',col(order == ii,:));
    hold on
end
set(gca,'XTick',1:13,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מתים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('תמותה למליון סך הכל')
subplot(1,2,2)
% yyaxis left
h = plot(datetime(2020,4:13,1),ddpm,'linewidth',1);
shape = repmat({'o','s','^'},1,5);
for ii = 1:13
    h(ii).Color = hb(ii).FaceColor;
    h(ii).Marker = shape{order == ii};
    h(ii).MarkerFaceColor = h(ii).Color;
end
legend(h(order),pop.city(order))
% hold on
% h2 = plot(datetime(2020,4:13,1),ddpm(:,9),'r','linewidth',2);
% legend([h1(1),h2],'ערים בישראל','בני ברק','location','northwest')
set(gcf,'Color','w')
xlim([datetime(2020,3,15) datetime(2020,3+size(ddpm,1),15)])
xlabel('חודש')
ylabel('מתים למליון')
set(gca,'xtick',datetime(2020,4:3+size(ddpm,1),1))
grid on
box off
title('תמותה למליון לחודש')
xtickformat('MMM')


figure;
subplot(1,2,1)
for ii = 1:13
    hb(ii) = bar(ii,cpm(ii),'linestyle','none','FaceColor',col(order == ii,:));
    hold on
end
% bar(cpm,'linestyle','none')
set(gca,'XTick',1:13,'XTickLabel',pop.city)
xtickangle(90)
ylabel('מקרים למליון')
set(gca,'ygrid','on')
box off
set(gcf,'Color','w')
title('מקרים למליון סך הכל')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
subplot(1,2,2)
h = plot(datetime(2020,4:13,1),dcpm,'linewidth',1);
for ii = 1:13
    h(ii).Color = hb(ii).FaceColor;
    h(ii).Marker = shape{order == ii};
    h(ii).MarkerFaceColor = h(ii).Color;
end
legend(h(order),pop.city(order))
set(gcf,'Color','w')
xlim([datetime(2020,3,15) datetime(2020,3+size(ddpm,1),15)])
xlabel('חודש')
ylabel('מקרים למליון')
set(gca,'xtick',datetime(2020,4:3+size(ddpm,1),1))
grid on
box off
title('מקרים למליון לחודש')
xtickformat('MMM')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';