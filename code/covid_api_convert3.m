
% !2to3 -w -n -o ~/covid-19-israel-matlab/code/ ~/Repos/israel_moh_covid_dashboard_data/mohdashboardapi.py

fid = fopen('~/covid-19-israel-matlab/code/mohdashboardapi.py','r');
txt = fread(fid);
fclose(fid);
txt = native2unicode(txt');




txt = strrep(txt,'assert os.','#  assert os.');
txt = strrep(txt,'GIT_DIR = ','#  GIT_DIR = ');
txt = strrep(txt,'os.chdir(GIT_DIR)','#  os.chdir(GIT_DIR)');

new = ['def add_line_to_file(fname, new_line):',newline,'    opr =  open(fname,''',...
    'r''',')',newline,'    prev_file = opr.read()',newline,'    new_file = prev_file + new_line + ''',...
    '\n''',newline,'    opf = open(fname,''','w''',')',newline,'    opf.write(new_file)'];
% clc
iStart = strfind(txt,'def add_line_to_file');
iEnd = strfind(txt,'.write(new_file)')+15;
% disp(txt(iStart:iEnd))
txt = strrep(txt,txt(iStart:iEnd),new);


rep = {['file(HOSP_FNAME, ''','w''',').write(csv_data+''','\n''',')'],['opf = open(HOSP_FNAME,''','w''',')',newline,'    opf.write(csv_data+''','\n''',')'];...
    ['file(VAC_FNAME, ''','w''',').write(csv_data+''','\n''',')'],['opf = open(VAC_FNAME,''','w''',')',newline,'    opf.write(csv_data+''','\n''',')'];...
    ['file(VAC_CASES_DAILY, ''','w''',').write(res)'],['opf = open(VAC_CASES_DAILY,''','w''',')',newline,'    opf.write(res)'];...
    'import time',['import time',newline,'import pandas as pd',newline,newline,...
    'GIT_DIR = "/home/innereye/Repos/israel_moh_covid_dashboard_data"',newline,...
    'if os.path.isdir(r''','C:\Users\User\Documents\Corona''','):',newline,...
    '    GIT_DIR = r''','C:\Users\User\Documents\Corona''',newline,'os.chdir(GIT_DIR)',newline]};
for ii = 1:size(rep,1)
    txt = strrep(txt,rep{ii,1},rep{ii,2});
end

% iFile = strfind(txt,'.read');
% for ii = 1:length(iFile)
%     disp(txt(iFile(ii)-1:iFile(ii)+100));
% end

add = {'data = get_api_data()','create_patients_csv(data)','create_vaccinated_csv(data)',...
'create_cases_by_vaccinations_daily(data)','update_age_vaccinations_csv(data)',...
'# vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedDaily")',...
'# vacc.to_csv("vaccinatedVerifiedDaily.csv")','research = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/researchGraph")',...
'research.to_csv("researchGraph.csv")','# vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/vaccinatedVerifiedDaily")',...
'# vacc.to_csv("vaccinatedVerifiedDaily.csv")','vacc = pd.read_json("https://datadashboardapi.health.gov.il/api/queries/vaccinationsPerAge")',...
'vacc.to_csv("vaccinationsPerAge.csv")'};
for ii = 1:length(add)
    txt = [txt,newline,add{ii}];
end

fid = fopen('~/covid-19-israel-matlab/code/mohdashboardapi_test.py','w');
fwrite(fid,txt);
fclose(fid);

