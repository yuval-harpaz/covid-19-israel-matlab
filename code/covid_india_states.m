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


abb = {'Andhra Pradesh','AP';'Arunachal Pradesh','AR';'Assam','AS';'Bihar','BR';'Chhattisgarh','CT';'Goa','GA';'Gujarat','GJ';'Haryana','HR';'Himachal Pradesh','HP';'Jammu and Kashmir','JK';'Jharkhand','JH';'Karnataka','KA';'Kerala','KL';'Madhya Pradesh','MP';'Maharashtra','MH';'Manipur','MN';'Meghalaya','ML';'Mizoram','MZ';'Nagaland','NL';'Orissa','OR';'Punjab','PB';'Rajasthan','RJ';'Sikkim','SK';'Tamil Nadu','TN';'Tripura','TR';'Uttarakhand','UT';'Uttar Pradesh','UP';'West Bengal','WB';'Tamil Nadu','TN';'Tripura','TR';'Andaman and Nicobar Islands','AN';'Chandigarh','CH';'Dadra and Nagar Haveli','DN';'Daman and Diu','DD';'Delhi','DL';'Lakshadweep','LD';'Pondicherry','PY';'Telangana','TG'};

t = table(dateU,an,ap,ar,as,br,ch,ct,dd,dl,dn,dn_dd,ga,gj,hp,hr,jh,jk,ka,kl,la,ld,mh,ml,mn,mp,mz,nl,or,pb,py,rj,sk,tg,tn,tr,up,ut,wb);
[isx,idx] = ismember(lower(abb(:,2)),t.Properties.VariableNames(2:end));
sn = t.Properties.VariableNames(2:end);
sn(idx(isx)) = abb(isx,1);

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
