function nanwritetable(list)
writetable(list,'data/Israel/Israel_ministry_of_health.csv','WriteVariableNames',true,'Delimiter',',');
fid = fopen('data/Israel/Israel_ministry_of_health.csv','r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt)';
txt = strrep(txt,'NaN','');
fid = fopen('data/Israel/Israel_ministry_of_health.csv','w');
fwrite(fid,txt);
fclose(fid);
