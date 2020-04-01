function [dataTable,timeVector,mergedData] = processCoronaData(dataMatrix)
%% This function processes the corona data.
%
% Input:
% dataMatrix: Output from readCoronaData.m (raw data from csv file)
%
% Output:
% dataTable: As input but with correct data types and as table
% timeVector: Only time/date vector
% mergedData: Summed cases over states/provinces. Only one value per country.
%
% 19th of March 2020: Axel Ahrens, Technical University of Denmark

%% convert array "dataMatrix" to a nice table
varNames = dataMatrix(1,:);
if verLessThan('matlab','9.7') % fix variable names for table for < 2019b
    varNames = strrep(varNames,'/','_');
    for n = 5:length(varNames)
        varNames{n} = ['date_',varNames{n}];
    end
end
dataTable = cell2table(dataMatrix(2:end,:),'VariableNames',varNames);

%% change variable types
for m = 1:size(dataMatrix,1)
    for n = 1:size(dataMatrix,2)
        
        if m == 1 && n>=5
            dataMatrix{m,n} = datetime(dataMatrix{m,n},'InputFormat','MM/dd/yy');
        elseif m > 1 && n >=3
            dataMatrix{m,n} = str2double(dataMatrix{m,n});
        end
    end
end

%% get time vector
for n = 5:size(dataMatrix,2)
    timeVector(n-4) = dataMatrix{1,n};
end

%% sort by country
sortedData = sortrows(dataMatrix(2:end,:),2);

thisCountryStart = 1;
thisCountryEnd = 1;
currentCountry = sortedData{1,2};
z = 1;
for k = 1:size(sortedData,1)
    
    if strcmp(sortedData{k,2},currentCountry)
        thisCountryEnd = k;
    else
        thisCountrySum = sum(cell2mat(sortedData(thisCountryStart:thisCountryEnd,5:end)),1);
        mergedData{z,1} = currentCountry;
        mergedData{z,2} = thisCountrySum;
        
        %reset counters
        z = z+1;
        thisCountryStart = k;
        thisCountryEnd = k;
        currentCountry = sortedData{k,2};
    end
    
end

end%fcn