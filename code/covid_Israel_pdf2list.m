function covid_Israel_pdf2list
cd ~/covid-19_data_analysis/
list = readtable('data/Israel/Israel_ministry_of_health.csv');
%download = dir('~/snap/telegram-cli/current/.telegram-cli/downloads/*.pdf');
download = dir('/media/innereye/1T/Docs/MOH/*.pdf');
fName = {download(:).name}';
javaaddpath('/home/innereye/Documents/MATLAB/pdfRead/iText-4.2.0-com.itextpdf.jar')
for iFile = 1:length(fName)
    pdf_text = pdfRead(['/media/innereye/1T/Docs/MOH/',fName{iFile}]);
    iSlash = find(ismember(pdf_text{1},'/'),1);
    iDots = find(ismember(pdf_text{1},':'));
    date = datetime([pdf_text{1}(iSlash-2:iSlash+7),' ',pdf_text{1}(iDots-2:iDots+2),':00']);
    row = find(ismember(list.date,date));
    if isempty(row)
        disp([datestr(date),' not in list'])
        txt = strrep(pdf_text{2},',','');
        warning off
        list.date(end+1) = date;
        iMitz = strfind(txt,'רבטצמ');
        iNewline = strfind(txt,newline);
        nl2 = iNewline(find(iNewline > iMitz,2));
        numb = txt(nl2(1)+1:nl2(2)-1);
        numb = strrep(numb,'*','');
        numb = str2num(numb);
        list{end,[8,7,4,6,5,14]} = numb;
        item = strfind(txt,'םיתמואמ');
        list.confirmed(end) =  str2num(strrep(txt(item+10:...
            iNewline(find(iNewline > item,1))-1),',',''));
        item = strfind(txt,'זופשאב');
        %FIXME - a few columns left
        nl2 = iNewline(find(iNewline > item,2));
        list.hospitalized(end) =  str2num(txt(nl2(1)+1:nl2(2)-1));
        iNow = regexp(txt,'תעכ');
        jNow = 3;
        list.recovered(end) = str2num(txt(iNow(jNow)+6:iNewline(find(iNewline > iNow(jNow),1))-1));
        item = strfind(txt,'לופיט');
        nl2 = iNewline(find(iNewline < item,2,'last'));
        numb = regexp(txt(nl2(1)+1:nl2(2)-1),' ','split');
        list.home_care(end) = str2num(numb{1});
        list.hotel_isolation(end) = str2num(numb{2});
        list.tests(end) = nan;
        list.hospitalized_xlsx(row) = nan;
        nanwritetable(list)
    else
        if isnan(list{row,end})
            txt = strrep(pdf_text{2},',','');
            warning off
            list.date(end+1) = date;
            iMitz = strfind(txt,'רבטצמ');
            iNewline = strfind(txt,newline);
            nl2 = iNewline(find(iNewline > iMitz,2));
            numb = txt(nl2(1)+1:nl2(2)-1);
            numb = strrep(numb,'*','');
            numb = str2num(numb)
            list{row,end} = numb(end);
            nanwritetable(list)
        else
            % disp(list{row,end})
        end
    end
end
 


% iGT = ismember(txtStr,'>');
% iGT(strfind(txtStr,'>>>')) = false;
% iGT(strfind(txtStr,'>>>')+1) = false;
% iGT(strfind(txtStr,'>>>')+2) = false;
% iGT(strfind(txtStr,'>>')) = false;
% iGT(strfind(txtStr,'>>')+1) = false;
% iGT = find(iGT);
% jsonData = jsondecode(txtStr(iGT(1)+6:iGT(2)-2));
% for ii = 1:length(jsonData)
%     
%
% 
% [err,msg] = system('telegram-cli -W -N -e "history @MOHreport 10000" | grep "_חדש_"');
% % fid = fopen('tcoutput.txt');
% % txt = fread(fid);
% % fclose(fid);
% % txtStr = native2unicode(txt');
% % txtStr = strrep(txtStr,[27,91,75,62,32,13],'');
% iDoc = strfind(msg,'_חדש_');
% id = strfind(msg,';1m');
% iSpace = strfind(msg,' ');
% idLast = msg(id(end)+1:iSpace(find(iSpace > id(end),1))-2);
% system(['telegram-cli -W -N -e "load_document ',idLast,'"']);