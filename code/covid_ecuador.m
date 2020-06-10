cd ~/covid-19_data_analysis/

ecu = urlread('https://raw.githubusercontent.com/andrab/ecuacovid/master/datos_crudos/muertes/por_fecha/provincias_por_dia.csv');
% strrep(nyc,'\n\n','\n')
% nyc = strrep(nyc,'/20,','/2020,');
fid = fopen('tmp.csv','w');
fwrite(fid,ecu);
fclose(fid);
ecu = readtable('tmp.csv');
!rm tmp.*

prov = ecu.Var1(2:end,1);
date = datetime(ecu{1,5:end})';
population = cellfun(@str2num, ecu{2:end,2});
pop = table(prov,population);

deceased = cellfun(@str2num, ecu{2:end,5:end})';

yy = deceased./population'*10^6;
[~,order] = sort(yy(end,:),'descend');
yy = yy(:,order);
dd = dd(:,order);
prov = pop.prov(order);
figure;
plot(yy)