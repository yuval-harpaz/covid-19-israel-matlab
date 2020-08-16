function [dataMatrix] = readCoronaData(type)
%% This function loads the corona data from a git repository.
%
% Input:
% none
%
% Output:
% dataMatrix: A raw array with chars in each field. It contains information
% on: Region, Country, Latitude, Longitude, corona cases per day. Find
% detailed information on https://github.com/CSSEGISandData/COVID-19
%
% 19th of March 2020: Axel Ahrens, Technical University of Denmark

%% get online resource and check for right data types/capitalization
if ~nargin
    type = 'confirmed'; %Deaths, Recovered
else
    if ~(strcmpi(type,'confirmed') || strcmpi(type,'deaths') || strcmpi(type,'recovered'))
        warning('This type does not exist. Please choose either confirmed, or deaths. Running code for confirmed cases.')
        type = 'Confirmed';
    end
    type = lower(type);
end
filename = ['https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_',type,'_global.csv'];

f = webread(filename);
f = strrep(f,'/','_');
fid = fopen('tmp.csv','w');
fwrite(fid,f);
fclose(fid);
warning off
t = readtable('tmp.csv');
warning on
dataMatrix = table2cell(t);
dataMatrix = [t.Properties.VariableNames;dataMatrix];
dataMatrix(1,:) = strrep(dataMatrix(1,:),'_','/');
dataMatrix(1,:) = strrep(dataMatrix(1,:),'x','');
!rm tmp.csv
%% find delimiter in file and set counting variables
% delimiterIdx = strfind(f,',');
% m = 1;
% n = 0;
% colNums = 0;
% 
% %% get data into matrix form
% for nIdx = 1:length(delimiterIdx)-1
%     n = n+1;
%     
%     if nIdx == 1
%         dataMatrix{m,n} =  f(1:delimiterIdx(nIdx)-1); %only do this for the first time
%     else
%         if n == 1
%             if contains(f(delimiterIdx(nIdx-1)-1),newline) %no state/province
%                 dataMatrix{m,n} = ''; %set state/province to empty
%                 
%                 if contains(f(delimiterIdx(nIdx-1)+1:delimiterIdx(nIdx)-1),'"') %there is a comma within country
%                     dataMatrix{m,n+1} =  f(delimiterIdx(nIdx-1)+2:delimiterIdx(nIdx+1)-2);
%                     delimiterIdx(nIdx) = NaN;
%                 else
%                     dataMatrix{m,n+1} =  f(delimiterIdx(nIdx-1)+1:delimiterIdx(nIdx)-1);
%                 end
%                 
%                 n = n+1;
%             else %includes state/province
%                 lineBreakData = f(delimiterIdx(nIdx-2):delimiterIdx(nIdx-1));
%                 lineBreakIdx = strfind(lineBreakData,newline);
%                 
%                 if contains(lineBreakData(lineBreakIdx+2:end-1),'"') %there is a comma within state/province
%                     lineBreakData = f(delimiterIdx(nIdx-2):delimiterIdx(nIdx)-1);
%                     lineBreakIdx = strfind(lineBreakData,newline);
%                     dataMatrix{m-1,end} = lineBreakData(2:lineBreakIdx-1);%fix last entry from previous row
%                     dataMatrix{m,n} = lineBreakData(lineBreakIdx+3:end-1);
%                     dataMatrix{m,n+1} =  f(delimiterIdx(nIdx)+1:delimiterIdx(nIdx+1)-1);
%                     delimiterIdx(nIdx) = NaN;
%                 else
%                     dataMatrix{m-1,end} = lineBreakData(2:lineBreakIdx-1);%fix last entry from previous row
%                     dataMatrix{m,n} = lineBreakData(lineBreakIdx+1:end-1);
%                     dataMatrix{m,n+1} = f(delimiterIdx(nIdx-1)+1:delimiterIdx(nIdx)-1);
%                 end
%                 
%                 n = n+1;
%             end
%         else
%             if isnan(delimiterIdx(nIdx-1))
%                 n = n-1;
%             else
%                 dataMatrix{m,n} = f(delimiterIdx(nIdx-1)+1:delimiterIdx(nIdx)-1);
%             end
%         end
%         
%     end
%     
%     if n == 60
%         a = 0;
%     end
%     
%     % find end of first row
%     if m == 1 && contains(dataMatrix{m,n},newline)
%         colNums = nIdx;
%         n = 0;
%         m = m+1;
%     end
%     % jump to next row
%     if n == colNums
%         m = m+1;
%         n = 0;
%     end
%     
%     if nIdx == length(delimiterIdx)-1 %% cover the last two entries
%         dataMatrix{m,n+1} = f(delimiterIdx(nIdx)+1:delimiterIdx(nIdx+1)-1);
%         dataMatrix{m,n+2} = f(delimiterIdx(nIdx+1)+1:end);
%     end
%     
% end%loop through delimiters
% 
% end%fcn
