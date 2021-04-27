json = urlread('https://raw.githubusercontent.com/datameet/covid19/master/data/mohfw.json');
json = jsondecode(json);

val = {json.rows(:).key}';
date = cellfun(@(x) datetime(x(1:10)),val);
% state = {json.rows(:).value.state};
for ii = 1:length(json.rows)
    state{ii,1} = json.rows(ii).value.state;
    cases(ii,1) = json.rows(ii).value.confirmed;
    deaths(ii,1) = json.rows(ii).value.death;
end

stateU = unique(state);
dateU = unique(date);
dateU = dateU(1):dateU(end);
dateU = dateU';
for ii = 1:length(stateU)
    eval([stateU{ii},' = zeros(size(dateU));']);
end
    
for iDate = 1:length(dateU)
    for iState = 1:length(stateU)
        row = find(ismember(state,stateU{iState}) & ismember(date,dateU(iDate)));
        if ~isempty(row)
            eval([stateU{iState},'(iDate,1) = max(cases(row));'])
        end
    end
end


% abb = {'Andhra Pradesh','AP';'Arunachal Pradesh','AR';'Assam','AS';'Bihar','BR';'Chhattisgarh','CT';'Goa','GA';'Gujarat','GJ';'Haryana','HR';'Himachal Pradesh','HP';'Jammu and Kashmir','JK';'Jharkhand','JH';'Karnataka','KA';'Kerala','KL';'Madhya Pradesh','MP';'Maharashtra','MH';'Manipur','MN';'Meghalaya','ML';'Mizoram','MZ';'Nagaland','NL';'Orissa','OR';'Punjab','PB';'Rajasthan','RJ';'Sikkim','SK';'Tamil Nadu','TN';'Tripura','TR';'Uttarakhand','UT';'Uttar Pradesh','UP';'West Bengal','WB';'Tamil Nadu','TN';'Tripura','TR';'Andaman and Nicobar Islands','AN';'Chandigarh','CH';'Dadra and Nagar Haveli','DN';'Daman and Diu','DD';'Delhi','DL';'Lakshadweep','LD';'Pondicherry','PY';'Telangana','TG'};
abb = {'Andhra Pradesh','AP',49577103,11;'Arunachal Pradesh','AR',1383727,26;'Assam','AS',31205576,17.7;'Bihar','BR',104099452,25.4;'Chhattisgarh','CT',25545198,22.6;'Goa','GA',1458545,8.2;'Gujarat','GJ',60439692,19.3;'Haryana','HR',25351462,19.9;'Himachal Pradesh','HP',6864602,12.9;'Jammu and Kashmir','JK',12267032,23.6;'Jharkhand','JH',32988134,22.4;'Karnataka','KA',61095297,15.6;'Kerala','KL',33406061,4.9;'Madhya Pradesh','MP',72626809,16.3;'Maharashtra','MH',112374333,20;'Manipur','MN',2570390,18.6;'Meghalaya','ML',2966889,27.9;'Mizoram','MZ',1097206,23.5;'Nagaland','NL',1978502,-0.60;'Orissa','OR',41974219,14;'Punjab','PB',27743338,13.8900000000000;'Rajasthan','RJ',68548437,21.3;'Sikkim','SK',610577,12.9;'Tamil Nadu','TN',72147030,15.6;'Tripura','TR',3673917,14.8;'Uttarakhand','UT',10086292,18.8;'Uttar Pradesh','UP',199812341,20.2;'West Bengal','WB',91276115,13.8;'Andaman and Nicobar Islands','AN',380581,6.9;'Chandigarh','CH',1055450,17.2;'Dadra and Nagar Haveli, Daman and Diu','DN_DD',585746,55.1;'Delhi','DL',16787941,17;'Lakshadweep','LD',64473,6.3;'Pondicherry','PY',1247953,28.1;'Telangana','TG',35003674,13.5800000000000}
t = table(dateU,an,ap,ar,as,br,ch,ct,dd,dl,dn,dn_dd,ga,gj,hp,hr,jh,jk,ka,kl,la,ld,mh,ml,mn,mp,mz,nl,or,pb,py,rj,sk,tg,tn,tr,up,ut,wb);
t.la = [];
t.dd = [];
t.dn = [];
t.ld = [];
[isx,idx] = ismember(lower(abb(:,2)),t.Properties.VariableNames(2:end));
sn = t.Properties.VariableNames(2:end);
sn(idx(isx)) = abb(isx,1);
pop = zeros(size(sn));
pop(idx(isx)) = round([abb{isx,4}].*[abb{isx,3}]/100+[abb{isx,3}]);

[~,order] = sort(t{end,2:end},'descend');
y = t{:,order+1};
figure;plot(t.dateU,y)
legend(strrep(sn(order),'_',' '),'location','west')
xlim([datetime(2020,6,1) datetime('tomorrow')])
xtickformat('MMM')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
title('cumulative cases in India by state')
grid on
box off

y = diff(t{:,2:end});
y(y<0) = 0;
[~,order] = sort(mean(y(end-6:end,:)),'descend');
y = y(:,order);
figure;plot(t.dateU(2:end),y)
legend(strrep(sn(order),'_',' '),'location','west')
xlim([datetime(2020,6,1) datetime('tomorrow')])
xtickformat('MMM')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
title('daily cases in India by state')
grid on
box off
%% daily per million
y = diff(t{:,2:end})./pop*10^6;
y(isnan(y)) = 0;
y(y<0) = 0;
y(y == 1609) = nan;
y = movmean(y,[3 3],'omitnan');
[~,order] = sort(mean(y(end-6:end,:)),'descend');
y = y(:,order);
figure;plot(t.dateU(2:end),y)
legend(strrep(sn(order),'_',' '),'location','west')
xlim([datetime(2020,6,1) datetime('tomorrow')])
xtickformat('MMM')
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
title('daily cases per million in India by state')
grid on
box off

figure;
bar(pop(order))
set(gca,'XTick',1:length(sn),'XTickLabel',strrep(sn(order),'_',' '),'ygrid','on')
xtickangle(90)
ax = gca;
ax.YRuler.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';
title('Estimated population of India by state')
set(gcf,'Color','w')