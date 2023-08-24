cd ~/covid-19-israel-matlab/data/Israel
[~,msg] = system('wget -O lmsMonth.xlsx https://www.cbs.gov.il/he/publications/LochutTlushim/2020/%D7%A4%D7%98%D7%99%D7%A8%D7%95%D7%AA-%D7%A9%D7%A0%D7%94-%D7%97%D7%95%D7%93%D7%A9.xlsx');
% monthAll = readtable('lmsMonth.xlsx','Range','B11:X22','ReadVariableNames',false);
monthAll = xlsread('lmsMonth.xlsx','B11:Y22');
% month70 = xlsread('lmsMonth.xlsx','B30:X41');
% https://docs.google.com/spreadsheets/d/1GHeY4KtT_7gw1L2-00Xj_2vbeA6uYozf2uX1BIf-o30/edit#gid=0
dashboard = 'https://datadashboard.health.gov.il/api/corona/hospitalization/hospitalizationStatusDaily'
listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
covid = [];
for yea = 2020:2023
    for mon = 1:12
        idx = dateshift(listD.date,'start','month') == datetime(yea,mon,1);
        covid(mon,yea-2019) = nansum(listD.CountDeath(idx)); %/pop.Var2(end)*10^6;
    end
end
covid(covid == 0) = nan;

% 
% pop = table((2009:2022)',...
%     1000*[7485.6;7623.6;7765.8;7910.5;8059.5;8215.7;8380.1;8546.0;8713.3;8882.8;9054.0;9212.8;9400;9600]);
% % correct for medical improvement
% nrm = [ones(12,1),ones(12,1),pop.Var2(2:end-1)/10^6,pop.Var2(2:end-1)/10^6];
% b = polyfit((2010:2019)',median(monthAll{:,11:end-2})'./nrm(1:end-2,3),1);
% pred = (2010:2021)'*b(1)+b(2);
% % figure;plot((2010:2020)',median(monthAll{:,11:end-2})'./nrm(:,3));
% % hold on;plot(2010:2020,pred(:,1))
% % 
% b = polyfit((2010:2019)',median(month70{:,11:end-2})'./nrm(1:end-2,3),1);
% pred(:,2) = (2010:2021)'*b(1)+b(2);
% % figure;plot((2010:2019)',median(month70{:,11:end-1})'./nrm(1:end-1,3));
% % hold on;plot(2010:2020,pred(:,2))
% clear death
% death{1} = monthAll{:,11:end};
% death{2} = month70{:,11:end};
% death{3} = monthAll{:,11:end};
% death{4} = month70{:,11:end};
% lims = [2000 6000;2000 6000;250 650;250 650];
% 
% yl = {'תמותה','תמותה','תמותה למליון','תמותה למליון'};
% tit = {'תמותה, כל הגילאים','תמותה, מעל 70','תמותה למליון, כל הגילאים','תמותה למליון, מעל 70','עודף תמותה למליון, כל הגילאים','עודף תמותה למליון, מעל 70'};
% 
% figure('units','normalized','position',[0,0,0.65,0.8]);
% for ip = 1:4
%     subplot(3,2,ip)
%     h = plot(death{ip}./nrm(:,ip)');
%     col = colormap(jet(13));
%     for ii = 1:12
%         h(ii).Color = col(ii,:);
%         if ii > 10
%             h(ii).LineWidth = ii-9;
%         end
%     end
%     if ip > 2
%         dpm = death{ip}./nrm(:,3)';
%         medmonth = median(dpm(:,1:end-1),2);
%         predmonth = pred(11,ip-2)-median(pred(1:10,ip-2))+medmonth;
%         %yy = death{ip}./nrm(:,3)'-pred(:,ip-2)';
%         hold on
% %         hb = plot(mean(pred(:,ip-2))+median(yy,2),'k--');
%         hb = plot(predmonth,'k--');
%     end
%     xlim([1 12])
%     ylim(lims(ip,:));
%     xlabel('חודש')
%     ylabel(yl{ip})
%     title(tit{ip})
%     grid on
%     box off
%     set(gca,'XTick',1:12)
% end
% 
% list = readtable('dashboard_timeseries.csv');
% for im = 3:24
%     idx = dateshift(list.date,'start','month') == datetime(2020,im,1);
%     covid(im,1) = nansum(list.CountDeath(idx))/pop.Var2(end)*10^6;
% end
% covid(covid == 0) = nan;
% %%
% % figure('units','normalized','position',[0,0,0.65,0.35]);
% for ip = 1:2
%     subplot(3,2,4+ip)
%     yy = death{ip}./nrm(:,3)'-pred(:,ip)';
%     yy = yy - median(yy(:,1:end-1),2);
%     h = plot(yy);
%     col = colormap(jet(13));
%     for ii = 1:12
%         h(ii).Color = col(ii,:);
%         if ii > 10
%             h(ii).LineWidth = ii-9;
%         end
%     end
%     xlim([1 12])
%     %ylim(lims(ip,:));
%     xlabel('חודש')
%     ylabel('תמותה למליון')
%     title(tit{ip+4})
%     grid on
%     box off
%     if ip == 2
%         legend(num2str((2010:2020)'),[900 415 0.1 0.2]);
%     end
%     set(gca,'XTick',1:12)
%     if ip == 1
%         hold on
%         hc = plot(covid(1:12),'k','linewidth',2);
%         plot(covid(13:end),'k','linewidth',3);
%         tot = nansum(yy);
%         tot(2,:) = sum(yy(~isnan(yy(:,end)),:));
%     end
%     ylim([-50 150])
%     set(gca,'YTick',-40:20:120)
% end
% %%
% legend([h;hb;hc],[cellstr(num2str((2010:2021)'));{'צפי';'קורונה'}],[900 415 0.1 0.2]);
% set(gcf,'Color','w')
% 
% listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
% mo1 = [1;find(day(listD.date) == 1)];
% deathM = [];
% for ii = 1:length(mo1)-1
%     deathM(ii,1) = nansum(listD.CountDeath(mo1(ii):mo1(ii+1)-1));
%     deathM(ii,2) = month(listD.date(mo1(ii)));
% end
% deathM(end+1,1) = sum(listD.CountDeath(mo1(end):end));
% deathM(end,2) = month(listD.date(end));
% niftarim = readtable('~/Downloads/corona_deceased_ver_0034.csv');
% figure;
% hb = bar(tot');
% figure;
% for ii = 1:11
%     hb11(ii) = bar(2009+ii,9.2*tot(2,ii),'facecolor',col(ii,:));
%     hold on
% end
% set(gca,'xtick',2010:2020)
% grid on
% xtickangle(30)
% set(gcf,'Color','w')
% title('תמותה עודפת שנתית')