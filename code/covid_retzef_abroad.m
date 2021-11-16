

json = urlread('https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily');
json = jsondecode(json);
cases = struct2table(json);
cases.day_date = datetime(strrep(cases.day_date,'T00:00:00.000Z',''));
cases.Properties.VariableNames{1} = 'date';
cases = cases(589:864,:);
ages = {'מעל גיל 60','מתחת לגיל 60','כלל האוכלוסיה'};
figure;
for iAge = 1:3
    subplot(1,3,iAge)
    t = cases(ismember(cases.age_group,ages{iAge}),:);
    plot(t.date,[t{:,6},sum(t{:,7:8},2)])
    grid on
    title(ages{iAge})
end
legend('vaccinated','unvaccinated+expired')
mo = [1,31;32,61;62,92];
tit = {'60+','<60','all'};
figure;
for iAge = 1:3
    subplot(1,3,iAge)
    t = cases(ismember(cases.age_group,ages{iAge}),:);
    for iMo = 1:3
        iii = mo(iMo,1):mo(iMo,2);
        yy(iMo,1) = nan;
        yy(iMo,2) = mean(mean(t{iii,7:8}))/mean(t{iii,6});
        yy(iMo,3) = mean(t{iii,7})/mean(t{iii,6});
        yy(iMo,4) = mean(t{iii,8})/mean(t{iii,6});
    end
    if iAge == 3
        yy(:,1) = [0.41;3.45;2.66];
    end
    bar(8:10,yy)
    grid on
    box off
    ylim([0 12])
    title(tit{iAge})
    set(gca,'FontSize',13,'YTick',1:12)
    xlabel('Month')
end
legend('Airport vaccinated > expired+unvaccinated','vaccinated > expired+unvaccinated','vaccinated > expired','vaccinated > unvaccinated')

