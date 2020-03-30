function [] = plotCoronaData(timeVector,mergedData,chosenCountries,type)
%% This function plots a subset of countries.
%
% Input (from processCoronaData.m):
% timeVector: Time/date vector
% mergedData: Cases per country
% chosenCountries (optional): Countries in a cell array
%
% Output:
% none
%
% Example: plotCoronaData(timeVector,mergedData,{'Italy','Germany','Denmark'})
%
% 19th of March 2020: Axel Ahrens, Technical University of Denmark


%% check for input parameters
if nargin < 4
    type = 'Confirmed';
elseif nargin < 3
    chosenCountries = {'Germany','Denmark','Italy','China','US'};
    type = 'Confirmed';
end

%% check for right data types/capitalization
if ~(strcmpi(type,'confirmed') || strcmpi(type,'deaths') || strcmpi(type,'recovered'))
    warning('This type does not exist. Please choose either Confirmed, Deaths, or Recovered.')
end
type = lower(type);

%% choose countries
if sum(strcmp(chosenCountries,'all')) || sum(strcmp(chosenCountries{1},'all'))
    rowNums = 1:size(mergedData,1);
else
    for n = 1:length(chosenCountries)
        rowNums(n) = find(contains(mergedData(:,1),chosenCountries{n}));
    end
end

%% plotting abs number
figure,
ax = gca;

plot(timeVector,cell2mat(mergedData(rowNums,2)))

if strcmpi(type,'confirmed')
    ylabel('#confirmed cases')
elseif strcmpi(type,'deaths')
    ylabel('#deaths')
elseif strcmpi(type,'recovered')
    ylabel('#recovered')
else
    warning('Unknown type. Cannot annotate plot.')
end

legend(mergedData(rowNums,1),'Location','northwest')
ax.FontSize = 16;

%% plotting change
figure,
ax = gca;

plot(timeVector(2:end),diff(cell2mat(mergedData(rowNums,2)),1,2))

if strcmpi(type,'confirmed')
    ylabel('increase #confirmed cases per day')
elseif strcmpi(type,'deaths')
    ylabel('increase #deaths per day')
elseif strcmpi(type,'recovered')
    ylabel('increase #recovered per day')
else
    warning('Unknown type. Cannot annotate plot.')
end

legend(mergedData(rowNums,1),'Location','northwest')
ax.FontSize = 16;

