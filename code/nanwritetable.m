function nanwritetable(list,fName)
if ~exist(fName,'var')
    fName = 'data/Israel/Israel_ministry_of_health.csv';
end
writetable(list,fName,'WriteVariableNames',true,'Delimiter',',');
fid = fopen(fName,'r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt)'; %#ok<N2UNI>
txt = strrep(txt,'NaN','');
fid = fopen(fName,'w');
fwrite(fid,txt);
fclose(fid);
