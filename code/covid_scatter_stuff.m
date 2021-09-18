agex = [273.2;149.6;127;121;82.8];
agey = [16.7;11;9.1;5.9;2.2];
agel = {'0-12 (6.1%)','12-19 (7.4%)','19-30 (7.2%)','30-60 (4.9%)','60+ (2.6%)'};
sectorx = [178.8;107;96.9;154.7];
sectory = [8.6;14;8.6;9.2];
sectorl = {'general (4.8%)','Haredi (13.1%)','Arab (8.9%)','all (6.0%)'};
vaccx = [282;126;110;86.6;68.3;78];
vaccy = [20.7;9.6;4.4;0.7;1.9;0.4];
vaccl = {'unvacc (7.3%)','aged vacc (7.6%)','fresh vacc (4%)','dose III (0.8%)','recovered (2.8%)','vacc+recov (0.5%)'};

figure('position',[100,100,900,900]);
scatter(agex,agey,25,...
    [0.518,0,0.016;0.675,0,0.03;0.969,0,0.255;1,0.475,0.486;1,0.851,0.733],...
    'fill')
hold on
hl = line([0 300],[0 15],'Color',[0.7 0.7 0.7],'linestyle','--');
txty = agey;
txty(end) = txty(end)+0.5;
text(agex + 8,txty,agel)
text(250,14,'5%')
legend(hl,'5%','location','northwest')
xlim([0 300])
ylim([0 30])
grid on
title('ages')
ylabel('cases per 10k people')
xlabel('tests per 10k people')
axis square
set(gcf,'Color','w')
%%
figure('position',[100,100,900,900]);
scatter(sectorx,sectory,25,...
    [0.553,0.275,0.667;0,0,0;0.243,0.467,0.643;0.5 0.5 0.5],...
    'fill')
xlim([0 300])
ylim([0 30])
hold on
hl = line([0 300],[0 15],'Color',[0.7 0.7 0.7],'linestyle','--');

text(sectorx + 8,sectory,sectorl)
text(250,14,'5%')
legend(hl,'5%','location','northwest')

grid on
title('sectors')
ylabel('cases per 10k people')
xlabel('tests per 10k people')
axis square
set(gcf,'Color','w')
%% 
figure('position',[100,100,900,900]);
scatter(vaccx,vaccy,25,...
    [0.859,0.933,0.996;0,0.224,0.631;0,0.224,0.631;0.553,0.275,0.667;...
    0.271,0.518,0.294;0.2,0.353,0.212],'fill');
hold on;
scatter(vaccx(2),vaccy(2),15,[1 1 1],'fill');
xlim([0 300])
ylim([0 30])
hold on
hl = line([0 300],[0 15],'Color',[0.7 0.7 0.7],'linestyle','--');
text(vaccx + 8,vaccy,vaccl)
text(250,14,'5%')
legend(hl,'5%','location','northwest')
grid on
title('vaccinaton / recovary')
ylabel('cases per 10k people')
xlabel('tests per 10k people')
axis square
set(gcf,'Color','w')

