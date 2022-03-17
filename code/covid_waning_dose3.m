cd ~/covid-19-israel-matlab/data/Israel
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b5b4ee-467a-48f1-8799-a42fccf91651&limit=5000');
json = jsondecode(json);
t = struct2table(json.result.records);

t60 = t(ismember(t.age_group,'60+'),:);
weekStartVacc = datetime(cellfun(@(x) x(1:10),t60.Third_dose_week,'UniformOutput',false));
[weekVacc,order] = sort(weekStartVacc);
t60 = t60(order,:);
% weekVacc = (min(weekStartVacc):7:max(weekStartVacc))';
weekInfec = datetime(cellfun(@(x) strrep(x(10:19),'_','-'),t60.Properties.VariableNames(5:end),'UniformOutput',false))';
% weekInfec = (min(weekStartInfec):7:max(weekStartInfec))';
cells = t60{:,5:end};
cells(cellfun(@isempty, cells)) = {'0'};
cells = strrep(cells,'1-5','2');
cells = strrep(cells,'6-10','7');
cells = strrep(cells,'10-14','12');
cases = cellfun(@str2num, cells);
cases(cases == -4) = 0;
cpm = round(cases./cellfun(@str2num, t60.group_size).*10^6,1);
cpm(25,25) = round((cpm(24,24)+cpm(26,26))/2); % noisy spike
m = month(weekInfec);
mn = cellstr(datestr(datetime(1,m,1),'mmm'));
[a,b,c] = unique(m);
xtick = sort(b);
% xtick(1) = [];
xtl = mn(xtick);
yy = cases;
yy(:,:,2) = cpm;
tit = {'Cases','Cases per million'};
%%
% figure;
% for sp = 1:2
%     subplot(2,1,sp)
%     imagesc(yy(:,:,sp))
%     xlabel('Infection week')
%     ylabel('Vaccination week')
%     set(gca,'Ydir','normal')
%     set(gca,'Xtick',xtick,'XtickLabel',xtl,'Ytick',[2;xtick(2:end)],'YtickLabel',xtl)
%     colormap('hot')
%     ylim([1.5 10.5])
%     title(tit{sp})
%     colorbar
% %     axis square
% end
% set(gcf,'Color','w')
%%
[yy1, xtl1, xtick1] = covid_waning_dose1(false);
yy1 = yy1(:,2:end,:);
xtick1 = xtick1-1;
yy(end+1:size(yy1,1),end+1:size(yy1,2),:) = nan;
%%
for clim = [3000, 30000];
    xEnd = length(weekInfec)+0.5;
    figure;
    subplot(2,1,1)
    imagesc(yy(:,:,2))
    set(gca,'Ydir','normal')
    set(gca,'Xtick',[xtick; xEnd],'XtickLabel',[xtl;datestr(weekInfec(end)+6,'dd/mm')],...
        'Ytick',[2;xtick(2:end)],'YtickLabel',xtl)
    colormap('hot')
    ylim([1.5 12.5])
    caxis([0 clim])

    % xlim([0.5 length(yy)+0.5])


    hold on
    hh(1) = fill([0,0,0,0],[0,0,0,0],[1 1 1]);
    hh(2) = line([xEnd,xEnd],[0,12.5],'Color','b');
    yl3 = yy(2,:,2)/clim*12.5+2;
    yl3(yl3 == 2) = nan;
    yl3(1) = nan;
    hh(3) = plot(yl3,'g');
    lg = legend(hh,[str(clim),' cases per M'],'last update','first group to vaccinate');
    set(lg, 'Color','none','TextColor','w','Box','off')
    title('Cases per million by Infection time and by dose III vaccination group')
    xlabel('Infection week')
    ylabel('Dose III vaccination week')
    subplot(2,1,2)
    imagesc(yy1(:,:,2))
    set(gca,'Ydir','normal')
    set(gca,'Xtick',xtick1,'XtickLabel',xtl1,'Ytick',xtick1,'YtickLabel',xtl1)
    colormap('hot')
    ylim([1.5 12.5])
    caxis([0 clim])
    set(gcf,'Color','w')
    hold on
    yl1 = yy1(2,:,2)/clim*12.5+2;
    yl1(1) = nan;
    plot(yl1,'g')
    title('Cases per million by Infection time and by dose I vaccination group')
    xlabel('Infection week')
    ylabel('Dose I vaccination week')
end
%%
co = flipud(jet(10));
co(end+1:100,3) = 2/3;

% co = gray(10);
% co(end+1:100,:) = 1;




%%
ty = t(ismember(t.age_group,'<60'),:);
weekStartVaccy = datetime(cellfun(@(x) x(1:10),ty.Third_dose_week,'UniformOutput',false));
[weekVaccy,ordery] = sort(weekStartVaccy);
ty = ty(ordery,:);
% weekInfecy = datetime(cellfun(@(x) strrep(x(10:19),'_','-'),ty.Properties.VariableNames(5:end),'UniformOutput',false))';

cellsy = ty{:,5:end};
cellsy(cellfun(@isempty, cellsy)) = {'0'};
cellsy = strrep(cellsy,'1-5','2');
cellsy = strrep(cellsy,'6-10','7');
cellsy = strrep(cellsy,'10-14','12');
casesy = cellfun(@str2num, cellsy);
cpmy = round(casesy./cellfun(@str2num, ty.group_size).*10^6,1);

%%
iEndy = find(nansum(cpmy) > 0,1,'last');
iEnd = find(nansum(yy(:,:,2)) > 0,1,'last');
fig24 = figure('units','normalized','position',[0.1 0 0.7 1]);
subplot(2,1,1)

co2 = flipud(jet(iEnd));
% co2(iEnd-9:iEnd-2,:) = 1/3;
for ii = 1:iEnd
    fill3([1:size(yy,2),size(yy,2):-1:1],ii*ones(size(yy,2)*2,1),[yy(ii,:,2),...
        zeros(1,size(yy,2))],co2(ii,:))
    hold on
end
grid on
view([-50,25])
xlim([0 iEnd])
xlabel('infection week')
ylabel('vaccination week')
zlabel('cases per million')
title('Infections by time from dose III, 60+')

% young
subplot(2,1,2)


for ii = 1:iEndy
    fill3([1:size(cpmy,2),size(cpmy,2):-1:1],ii*ones(size(cpmy,2)*2,1),...
        [cpmy(ii,:),zeros(1,size(cpmy,2))],co2(ii,:))
    hold on
end
grid on
% view([-7,38])
% view([190,45])
% view([-165,45])
% view([-158,20])
view([-50,25])
% zlim([0 3500]);
xlim([0 iEndy])
% ylim([0 13])
xlabel('infection week')
ylabel('vaccination week')
zlabel('cases per million')
title('Infections by time from dose III, <60')
%% 
% c = 0;
clear X Y Z
for ii = 1:size(cpm,1)
    for jj = 1:size(cpm,2)
%         c = c + 1;
        X(ii,jj) = jj;
        Y(ii,jj) = ii;
%         Z(c,1) = yy(ii,jj,1);
    end
end

% figure;
% contourf(X,Y,cpm, 50,'linestyle','none');
% hold on
% contour(X,Y,cpm, 10,'k');
% axis square

figure;
mesh(X,Y,cpm,'FaceColor','interp','EdgeColor','interp');
% contour3(X,Y,cpm, 10);
hold on
contour3(X,Y,cpm, 5000:5000:40000,'k');
% surf(X,Y,cpm,'linestyle','none');
% contour3(X,Y,cpm, 50,'linestyle','none');
xlabel('infection week')
ylabel('vaccination week')
zlabel('cases per million')
title('Infections by time from dose III, 60+')
grid on
views = [-15;-15;-15;(-15:-15:-175)';-175;-175;-175]+3;
views(:,2) = 43;
view(views(17,:))
zlim([0 40000])
set(gca,'ZTick',0:10000:40000)
% axis square
set(gcf,'Color','w')
%%

fig25 = figure('units','normalized','position',[0.1 0 0.7 1]);
for vv = 1:length(views)
    subplot(2,1,1)
    co2 = flipud(jet(iEnd));
    for ii = 1:iEnd
        fill3([1:size(yy,2),size(yy,2):-1:1],ii*ones(size(yy,2)*2,1),[yy(ii,:,2),...
            zeros(1,size(yy,2))],co2(ii,:))
        hold on
    end
    grid on
    view(views(vv,:))
    xlim([0 iEnd])
    xlabel('infection week')
    ylabel('vaccination week')
    zlabel('cases per million')
    title('Infections by time from dose III, 60+')
    subplot(2,1,2)
    for ii = 1:iEndy
        fill3([1:size(cpmy,2),size(cpmy,2):-1:1],ii*ones(size(cpmy,2)*2,1),...
            [cpmy(ii,:),zeros(1,size(cpmy,2))],co2(ii,:))
        hold on
    end
    grid on
    view(views(vv,:))
    xlim([0 iEndy])
    xlabel('infection week')
    ylabel('vaccination week')
    zlabel('cases per million')
    title('Infections by time from dose III, <60')
    num = str(vv);
    if length(num) == 1
        num = ['0',num];
    end
    fnv = ['~/Documents/vax/vax_groups',num,'.jpg'];
%     saveas(fig25,fnv)
    pause(0.1)
%     img(1502,2100,1:3,vv) = imread(fnv);
    frame = getframe(fig25);
%     im1 = frame2im(frame);
%     im(1:961,1:1344,1:3,vv) = imresize(frame2im(frame),[961,1344]);
    imwrite(imresize(frame2im(frame),[961,1344]),fnv);
%     [imind,cm] = rgb2ind(im,256);
%     if vv == 1
%         imwrite(imind,cm,'~/Documents/vax/vax_groups.gif','gif', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,'~/Documents/vax_groups.gif','gif','WriteMode','append');
%     end
end
% imwrite(im,'~/Documents/vax_groups.gif','gif');


% figure('units','normalized','position',[0.1 0.1 0.7 0.7])
% subplot(2,1,1)
% for ii = 1:12
%     fill3([1:size(yy,2),size(yy,2):-1:1],ii*ones(size(yy,2)*2,1),[yy(ii,:,2),zeros(1,size(yy,2))],co(ii,:))
%     hold on
% end
% grid on
% view([-7,38])
% zlim([0 3500]);
% xlim([0 45])
% ylim([0 13])
% xlabel('infection week')
% ylabel('vaccination week')
% zlabel('cases per million')
% title('Infections by time from dose III')
% subplot(2,1,2)
% for ii = 1:12
%     fill3([1:size(yy1,2),size(yy1,2):-1:1],ii*ones(size(yy1,2)*2,1),[yy1(ii,:,2),zeros(1,size(yy1,2))],co(ii,:))
%     hold on
% end
% grid on
% view([-7,38])
% xlim([0 45])
% ylim([0 13])
% zlim([0 3500]);
% xlabel('infection week')
% ylabel('vaccination week')
% zlabel('cases per million')
% title('Infections by time from dose I')
% % fill3(

%%
% figure('units','normalized','position',[0.1 0.1 0.7 0.7])
% subplot(2,1,1)
% for ii = 1:12
%     fill3([1:size(yy,2),size(yy,2):-1:1],ii*ones(size(yy,2)*2,1),...
%         [yy(ii,:,1),zeros(1,size(yy,2))],co(ii,:),'FaceAlpha',0.8)
%     hold on
% end
% grid on
% view([-7,38])
% zlim([0 1100]);
% xlim([0 45])
% ylim([0 13])
% xlabel('infection week')
% ylabel('vaccination week')
% zlabel('cases')
% title('Infections by time from dose III')
% subplot(2,1,2)
% for ii = 1:12
%     fill3([1:size(yy1,2),size(yy1,2):-1:1],ii*ones(size(yy1,2)*2,1),...
%         [yy1(ii,:,1),zeros(1,size(yy1,2))],co(ii,:),'FaceAlpha',0.8)
%     hold on
% end
% grid on
% view([-7,38])
% xlim([0 45])
% ylim([0 13])
% zlim([0 1100]);
% xlabel('infection week')
% ylabel('vaccination week')
% zlabel('cases')
% title('Infections by time from dose I')