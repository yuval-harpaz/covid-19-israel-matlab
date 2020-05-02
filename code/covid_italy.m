function ita = covid_italy %#ok<STOUT>
cd ~/covid-19_data_analysis
system ('wget https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv')
region = readtable('dpc-covid19-ita-regioni.csv');
!rm 'dpc-covid19-ita-'*

dateReg = datetime(cellfun(@(x) x(1:10),region.data,'UniformOutput',false));
Date = unique(dateReg);
regName = strrep(strrep(unique(region.denominazione_regione),'P.A. ',''),' ','_');
regName = strrep(regName,'-','_');
regName = strrep(regName,'''','');
nameStr = join(regName,',');

popreg = readtable('data/Italy/Italy_population_by_region.csv'); %#ok<NASGU>

for iName = 1:length(regName)
     eval([regName{iName},' = region.deceduti(ismember(region.denominazione_regione,popreg.region{iName}));']);
end
eval(['ita = table(Date,',nameStr{1},');']);
writetable(ita,'data/Italy/deceased.csv','delimiter',',','WriteVariableNames',true);
% 
% 
% y = ita{:,2:end}./(popreg.population')*10^6;
% [~,order] = sort(y(end,:),'descend');
% figure;
% h = plot(ita.Date,y(:,order));
% for ii = 1:10
%     text(ita.Date(end-ii*3),y(end-ii*3,order(ii)),popreg.region{order(ii)},'color',h(ii).Color);
% end
% box off
% grid on
% set(gcf,'color','w')


%% old
% 
% system ('wget https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv');
% ita = readtable('dpc-covid19-ita-andamento-nazionale.csv');
% !rm 'dpc-covid19-ita-'*
% dateIta = datetime(cellfun(@(x) x(1:10),ita.data,'UniformOutput',false));
% 
% figure;
% h = plot(dateIta,ita.terapia_intensiva,'r');
% hold on
% plot(dateIta,ita.totale_ospedalizzati,'b')
% plot(dateIta,ita.deceduti,'k')
% plot(dateIta,ita.dimessi_guariti,'g')
% legend('intensive care','hospitalized','deaths','dismissed','location','northwest')
% ax = ancestor(h, 'axes');
% ax.YAxis.Exponent = 0;
% box off
% grid on
% 
% new_hosp = ita.totale_ospedalizzati(2:end) - (ita.totale_ospedalizzati(1:end-1)...
%     - ita.deceduti(1:end-1) - ita.dimessi_guariti(1:end-1));
% % intens2hosp = hosp_today - hosp_yest 
% % new_intensive = intens_today - intens_yesterday + deaths_yesterday + intens2hosp
% y = diff(ita.deceduti(2:end));
% y(:,2) = diff(ita.totale_ospedalizzati(2:end)) + diff(ita.deceduti(1:end-1)) + diff(ita.dimessi_guariti(1:end-1));
% figure;
% plot(dateIta(3:end),y(:,1),'k--')
% hold on
% plot(dateIta(3:end),y(:,2),'r--')
% h1 = plot(dateIta(3:end),movmean(y(:,1),7),'k','linewidth',2);
% h2 = plot(dateIta(3:end),movmean(y(:,2),7),'r','linewidth',2);
% legend([h1 h2],'daily deaths','daily admission to hospitals')
% grid on
% box off
% ylabel('patients')
% 
% 
% figure;
% plot(dateIta(9:end),y(7:end,1)./y(2:end-5,2),'b--')
% hold on
% plot(dateIta(9:end),movmean(y(7:end,1)./y(2:end-5,2),7),'b','linewidth',2)
% ylim([0 0.5])
% xlim(dateIta([9,end]))
% box off
% grid on
% median(y(7:end,1)./y(2:end-5,2)) % 25.5%
% 
% 
% rutIdan = urlread('https://raw.githubusercontent.com/idandrd/israel-covid19-data/master/IsraelCOVID19.csv');
% fid = fopen('tmp.csv','w');
% fwrite(fid,unicode2native(rutIdan));
% fclose(fid);
% ri = readtable('tmp.csv');
% !rm tmp.csv
% ri = ri(17:end,:);
% 
% figure;
% h = plot(ri.x_Date,ri.x___Severe,'r');
% hold on
% plot(ri.x_Date,ri.x___Severe+ri.x______Moderate,'b')
% plot(ri.x_Date,ri.x_____Deceased,'k')
% plot(ri.x_Date,ri.x______Recovered,'g')
% legend('intensive care','hospitalized','deaths','recovered','location','northwest')
% ax = ancestor(h, 'axes');
% ax.YAxis.Exponent = 0;
% box off
% grid on
% 
% 
% yi = diff(ri.x_____Deceased(2:end));
% yi(:,2) = diff(ri.x___Severe(2:end)+ri.x______Moderate(2:end)) + diff(ri.x_____Deceased(1:end-1)) + diff(ri.x______Recovered(1:end-1));
% 
% figure;
% plot(ri.x_Date(3:end),yi(:,1),'k--')
% hold on
% plot(ri.x_Date(3:end),yi(:,2),'r--')
% h1 = plot(ri.x_Date(3:end),movmean(yi(:,1),7),'k','linewidth',2);
% h2 = plot(ri.x_Date(3:end),movmean(yi(:,2),7),'r','linewidth',2);
% legend([h1 h2],'daily deaths','daily admission to hospitals')
% grid on
% box off
% ylabel('patients')
% 
% figure;
% plot(ri.x_Date(9:end),yi(7:end,1)./yi(2:end-5,2),'b--')
% hold on
% plot(ri.x_Date(9:end),movmean(yi(7:end,1)./yi(2:end-5,2),7),'b','linewidth',2)
% ylim([0 0.5])
% xlim(ri.x_Date([9,end]))
% box off
% grid on

% 
% isr = covid_Israel;
% 
% [dataMatrix] = readCoronaData('deaths');
% [dataTable,timeVector,mergedData] = processCoronaData(dataMatrix);


% plot(dateIta(2:end),new_hosp,'r--')
% 
% figure;
% plot(dateIta(2:end),diff(ita.terapia_intensiva),'r--')
% hold on
% plot(dateIta(2:end),diff(ita.terapia_intensiva))
% 
% plot(dateIta(2:end),diff(ita.deceduti),'k--')
% t = readtable('/media/innereye/1T/Docs/Sever17Apr.txt','ReadVariableNames',true,'Delimiter','tab','HeaderLines',0);
% t(cellfun(@isempty, t.TotalDeaths) | cellfun(@isempty, t.Serious),:) = [];
% t(end,:) = [];
% deaths = cellfun(@str2num,strrep(t.TotalDeaths,',',''));
% severe = cellfun(@str2num,strrep(t.Serious,',',''));
% bad = severe <= deaths;