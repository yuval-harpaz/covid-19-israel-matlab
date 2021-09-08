json = urlread('https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily');
json = jsondecode(json);
deaths = struct2table(json);
deaths.day_date = datetime(strrep(deaths.day_date,'T00:00:00.000Z',''));
deaths.Properties.VariableNames{1} = 'date';

json = urlread('https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily');
json = jsondecode(json);
cases = struct2table(json);
cases.day_date = datetime(strrep(cases.day_date,'T00:00:00.000Z',''));
cases.Properties.VariableNames{1} = 'date';

dOld = ismember(deaths.age_group,'מעל גיל 60');
cOld = ismember(cases.age_group,'מעל גיל 60');
dYoung = ismember(deaths.age_group,'מתחת לגיל 60');
cYoung = ismember(deaths.age_group,'מתחת לגיל 60');
ages = {dOld,cOld;dYoung,cYoung};
tit = {{'Cases vs deaths for 60+ by vaccination status','cases shifted by 14 days'};...
    {'Cases vs deaths for <60 by vaccination status','cases shifted by 14 days'}};
%% plot abs
for iAge = 1:2
    % figure;
    % yyaxis left
    % plot(deaths.date(ages{iAge,1}),movmean(deaths{dOld,3:5},[3 3]))
    % ylim([0 30])
    % yyaxis right
    % plot(cases.date(ages{iAge,2})+14,movmean(cases{cOld,3:5},[3 3]))
    % legend('deaths dose III','deaths dose II','deaths unvacc',...
    %     'cases dose III','cases dose II','cases unvacc','location','north')
    % % preprocess
    
    
    cd3 = cases{ages{iAge,2},6:8};
    cd3(1:195,1) = nan;
    if iAge == 2
        cd3(196:209,1) = nan;
    end
    cd3(1:end-1,:) = movmean(cd3(1:end-1,:),[3 3],'omitnan');
    cd3(end,:) = nan;
    cd3(cd3 == 0) = nan;
    if iAge == 1
        dd3 = movmean(deaths{ages{iAge,1},6:8},[3 3]);
    else
        dd3 = deaths{ages{iAge,1},6:8};
    end
    rat = dd3(15:end,:)./cd3(1:end-14,:);
    rat(100:150,:) = nan;
    dt = deaths.date(ages{iAge,1});
    dt = dt(15:end);
    % plot norm
    figure('units','normalized','position',[0.1 0.1 0.65 0.8]);
    subplot(2,1,1)
    yyaxis left
    
    h = plot(deaths.date(ages{iAge,1}),dd3,'linewidth',2);
    if iAge == 1
        ylim([0 9])
    else
        ylim([0 18])
    end
    %             else
    %                ylim([0 60])
    %                en
    ylabel('deaths per 100k')

    yyaxis right
    h(4:6,1) = plot(cases.date(ages{iAge,2})+14,cd3,'linewidth',2);
    if iAge == 1
    legend(flipud(h),fliplr({'deaths dose III','deaths dose II','deaths unvacc',...
        'cases dose III','cases dose II','cases unvacc'}),'location','north')
    ylim([0 90])
    else
        legend(flipud(h(4:6)),fliplr({'cases dose III','cases dose II','cases unvacc'}),'location','north')
    end
    grid on
    
    title(tit{iAge})
    box off
    xlim([datetime(2021,2,1) datetime('today')+14])
    ylabel('cases per 100k')
    subplot(2,1,2)
    
    yyaxis left
    h1 = plot(dt,100*rat,'linewidth',2);
    ylabel('deaths to cases ratio (%)')
     if iAge == 2
        ylim([0 5])
    end
    yyaxis right
    set(gca,'Ytick',[])
    legend(flipud(h1),fliplr({'dose III','dose II','unvacc'}),'location','north')
    title('deaths to cases ratio')
    grid on
    box off
    set(gcf,'Color','w')
    xlim([datetime(2021,2,1) datetime('today')+14])
   
end
% field = fields(json);
% tst = 'deaths = table(';
% for ii = 1:length(field)
%     if ischar(eval(['json(1).',field{ii}]))
%         eval([field{ii},' = {json(:).',field{ii},'}''',';'])
%     else
%         eval([field{ii},' = [json(:).',field{ii},']''',';'])
%     end
%     tst = [tst,field{ii},','];
% end
% tst(end:end+1) = ');';
% eval(strrep(tst,'day_date','date'));

% vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily")
% vacc.to_csv("SeriousVaccinationStatusDaily.csv")
%