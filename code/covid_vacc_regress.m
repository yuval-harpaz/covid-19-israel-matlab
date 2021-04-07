%% mobility
glob = covid_google2;
globDate = datetime(2020,2,15:15+length(glob)-1)';
%% tests
[posAge,posDate] = covid_age_perc_pos;
% ages = {'0-19';'20-24';'25-29';'30-34';'35-39';'40-44';'45-49';'50-54';'55-59';'60-64';'65-69';'70-74';'75-79';'80+';'NULL'};
% listD = readtable('~/covid-19-israel-matlab/data/Israel/dashboard_timeseries.csv');
% conf = movmean(listD.tests_positive,[3 3]);
ages = {'0-20';'20-40';'40-60';'60-70';'70-80';'80+'};
pos = [posAge(:,1),sum(posAge(:,2:5),2),sum(posAge(:,6:9),2),sum(posAge(:,10:11),2),sum(posAge(:,12:13),2),sum(posAge(:,14),2)];
%% vacc
!wget -O tmp.csv https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/vaccinated_by_age.csv
vacc = readtable('tmp.csv');
vaccDate = datetime(cellfun(@(x) x(1:end-4), strrep(strrep(vacc.Date,'T',' '),'Z',''),'UniformOutput',false));
pop60 = sum(vacc{end,17:3:end});
% pop60 = (749+531+308)*1000;
vaccDay = unique(dateshift(vaccDate,'start','day'));
vacCol = {4;[7,10];[13,16];19;22;[25,28]};
vaccAge = [];
for ii = 1:length(vaccDay)
    row = find(vaccDate < vaccDay(ii)+1,1,'last');
    for jj = 1:6
        vaccAge(ii,jj) = sum(vacc{row,vacCol{jj}})./sum(vacc{end,vacCol{jj}-2});
    end
end
%% B117
Bdate = [datetime(2020,12,24),datetime(2021,1,14),datetime(2021,1,7*(3:5)),datetime(2021,2,7)];
B117 = [2.5;36.1;60.0;79.5;90;91.2];
%%
figure;
for iAge = 1:6
    subplot(2,3,iAge)
    yyaxis left
    plot(Bdate,B117,'Color',[0.7 0.7 0.7],'linewidth',2)
    hold on
    plot(globDate,-glob(:,end),'-','Color',[0.6 0.8 0.6],'linewidth',2)
    plot(vaccDay,100*vaccAge(:,iAge),'-')
    ylabel('%')
    ylim([0 100])
    yyaxis right
    plot(posDate,pos(:,iAge))
    if iAge == 1
        legend('% B.1.1.7','mobility x -1','% vaccine II','positive')
    end
    title(ages{iAge})
    xlim([datetime(2020,11,15) datetime(2021,3,23)])
    xtickformat('MMM')
    grid on
    ax = gca;
%     ax.YAxis(2).TickLabelFormat = '%,.0f';
%     ax.YRuler.Exponent = 1;
    ylabel('positive tests')
    if iAge == 1
        set(gca,'YTickLabel',{'0','5000','10000','15000','20000','25000'})
    end
end
set(gcf,'Color','w')
% 
% figure;
% plot(listD.date,conf./max(conf))
% hold on
% plot(globDate,glob(:,end)./min(glob(:,end)))