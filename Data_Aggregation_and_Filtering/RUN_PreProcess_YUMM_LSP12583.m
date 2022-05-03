%RUN_PreProcess_CCR6
%% USER INPUTS
%STEP 1: PreProcess_Step1_Aggregation_v2
filename.analfolder = '\\research.files.med.harvard.edu\HITS\lsp-analysis\cycif-production\126-circadianregulatorsmelanoma\CCR-023-TumorMarkerValidation\ANALYSIS\'; 
filename.resufolder = 'RESULTS_LSP12583\'; 
filename.filedate = '20220321'; 
filename.folders = {'LSP12583'};
                
filename.tissues = {'LSP12583'};
filename.suffix = '_Results_20220321.mat';
% options.maxround = 28; 
options.date = '20220321'; 
options.Markers = {'DAPI1','SOX10 1074','CD31 MEC','CD31 D8V9E', ...
                   'DAPI2','ARG-1','CD163','iNOS', ...
                   'DAPI3','CK-Pan','SOX9','SOX10 SP267', ...
                   'DAPI4','CD103','CD11c','CD11b', ...
                   'DAPI5','PD-L1','F4-80','CD206', ...
                   'DAPI6','H3K27Me3','H3K4Me3','Glut1', ...
                   'DAPI7','Vimentin','HIF1a','Ki-67',...
                   'DAPI8','FOXP3','CD4','CD8a'}; 
options.magnification = 20; 
Aggr_Results_Name = [filename.analfolder filename.resufolder 'Results_Aggr_' filename.filedate '.mat'];
Morp_Results_Name = [filename.analfolder filename.resufolder 'Results_Morp_' filename.filedate '.mat'];
Norm_Results_Name = [filename.analfolder filename.resufolder 'Results_Norm_' filename.filedate '.mat'];
Filt_Results_Name = [filename.analfolder filename.resufolder 'Results_Filt_' filename.filedate '.mat'];
%STEP 2: PreProcess_Step2_Filter
options.maxround = 32; 
options.folder = '\\research.files.med.harvard.edu\HITS\lsp-analysis\cycif-production\126-circadianregulatorsmelanoma\CCR-023-TumorMarkerValidation\ANALYSIS\RESULTS_LSP12583\'; 
options.Index_Names = {'LSP12583'};
figOpt = 1; 
options.thresholds.foldDAPI_th = 0.5; %ratio of cytoplasmic to nuclear DAPI
options.thresholds.absDAPI_th = 9; %max DAPI signal (log2)
options.thresholds.solidity = 0.9; %nuclear integrity (0-1 scale)
options.thresholds.area_low = 50; %min nuclear area
options.thresholds.area_high = 750; %max nuclear area
options.thresholds.cytarea_low = 100; %min cytoplasmic area
options.thresholds.cytarea_high = 550; %max cytoplasmic area 
%% RUN STEP 1: PreProcess_Step1_Aggregation_v2
[AggrResults, MorpResults] = PreProcess_Step1_Aggregation_v2(filename, options, figOpt);
save(Aggr_Results_Name,'AggrResults'); 
save(Morp_Results_Name,'MorpResults'); 

Directory.Analysis = '\\research.files.med.harvard.edu\HITS\lsp-analysis\cycif-production\126-circadianregulatorsmelanoma\CCR-023-TumorMarkerValidation\ANALYSIS\'; 
Directory.Results = '\\research.files.med.harvard.edu\HITS\lsp-analysis\cycif-production\126-circadianregulatorsmelanoma\CCR-023-TumorMarkerValidation\ANALYSIS\RESULTS_LSP12583\'; 
options.date = '20220321'; 
options.Folders = {'LSP12583'};
%% RUN STEP 2: PreProcess_Step2_Filter
load(Aggr_Results_Name); 
[Filter, report] = PreProcess_Step2_Filter(AggrResults, options, figOpt);
save(Filt_Results_Name,'Filter');