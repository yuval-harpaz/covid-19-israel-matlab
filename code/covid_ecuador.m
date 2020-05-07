cd ~/covid-19_data_analysis/
error('wrong table')
ecu = urlread('https://raw.githubusercontent.com/andrab/ecuacovid/master/datos_crudos/defunciones/provincias.csv');
% strrep(nyc,'\n\n','\n')
% nyc = strrep(nyc,'/20,','/2020,');
fid = fopen('tmp.csv','w');
fwrite(fid,ecu);
fclose(fid);
ecu = readtable('tmp.csv');
!rm tmp.

prov = unique(ecu.provincia);
date = unique(ecu.created_at);
for jj = 1:length(prov)
    pop(jj,1) = ecu.poblacion(find(ismember(ecu.provincia,prov{jj}),1));
end
for ii = 1:length(prov)
    dd(1:length(date),ii) = ecu.total(ismember(ecu.provincia,prov{ii}));
end
dd = cumsum(dd);
yy = dd./pop'*10^6;
[~,order] = sort(y(end,:),'descend');
yy = yy(:,order);
dd = dd(:,order);
prov = prov(order);
figure;
plot(dd)