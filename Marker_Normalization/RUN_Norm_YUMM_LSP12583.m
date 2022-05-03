clear all
%%%
codedir = 'Z:data\IN_Cell_Analyzer_6000\Giorgio\CycIF Codes\Utility Functions';
addpath(codedir)
addpath('norm\')

%%%
filename.basefolder = '\\research.files.med.harvard.edu\HITS\lsp-analysis\cycif-production\126-circadianregulatorsmelanoma\CCR-023-TumorMarkerValidation\';
filename.suffix = '_Results_20220321.mat';
filename.analfolder = [filename.basefolder 'ANALYSIS\'];
filename.resufolder = 'RESULTS_LSP12583\'; 
filename.roifolder  = 'ROIs\';
filename.montfolder = 'MontageforROI_Lv3\';
filename.montsuffix = '_montage.tif';

filename.folders =  {'LSP12583'};
                
Folder_IDs = [1]; 
                                
filename.tissues = filename.folders;              

for i = 1:length(filename.folders)
    options.MouseNum(i) = str2num(filename.folders{i}(4:end)); %indices 5-end capture the Mouse ID number
%     options.MouseGroup(i) = ceil(double(options.MouseNum(i))/0531);%270 = last mouse in control group
end

options.Markers =  {'DAPI1','SOX10 1074','CD31 MEC','CD31 D8V9E', ...
                   'DAPI2','ARG-1','CD163','iNOS', ...
                   'DAPI3','CK-Pan','SOX9','SOX10 SP267', ...
                   'DAPI4','CD103','CD11c','CD11b', ...
                   'DAPI5','PD-L1','F4-80','CD206', ...
                   'DAPI6','H3K27Me3','H3K4Me3','Glut1', ...
                   'DAPI7','Vimentin','HIF1a','Ki-67',...
                   'DAPI8','FOXP3','CD4','CD8a'}; 
                  
options.maxround = length(options.Markers);
options.magnification = 20;
options.FigOpt = 0;
options.date = '20220321';

% STEP 3: additional parameters for normalization
Params.Reps = 3;
Params.FigSettings.FigFlag = 1; % to save
Params.FigSettings.Folder = [filename.analfolder filename.resufolder 'Step3_NormPrints\' ];
Params.FigSettings.Debug = 1; % to view
Params.Channels = 1:options.maxround; 
% default to zeros
Params.Priors = zeros(length(options.Markers),1);
% Params.Priors([10 18]) = [1 1]
Params.OverExpr = zeros(length(options.Markers),1);
Params.OverExpr([2 6 7 8 10 16 18 22 23 24 27 30 31 32]) = [0.4 0.2 0.07 0.1 0.3 0.4 0.05 0.4 0.4 0.3 0.15 0.01 0.15 0.15]; 
Params.CellNum = 100000;            
% 
% save([filename.analfolder filename.resufolder 'Results_Settings_' options.date '.mat'],'filename','options')
% disp('DONE')
%%
load([filename.analfolder filename.resufolder 'Results_Filt_' options.date '.mat'])
load([filename.analfolder filename.resufolder 'Results_Aggr_' options.date '.mat'])
load([filename.analfolder filename.resufolder 'Results_Morp_' options.date '.mat'])
load([filename.analfolder filename.resufolder 'Results_ROI_' options.date '.mat']) 

Full_Tissue_Mask = ROIResults.ControlIndex ~= 1; 
Tissue_Filter = repmat(Full_Tissue_Mask,1,length(options.Markers)); 

rng(11)
close all
options.FigOpt = 0;

close all

% set up normalization 
filter = Filter.all & Tissue_Filter;
data_nuc = log2(double(AggrResults.MedianNucSign)+1);
data_cyt = log2(double(AggrResults.MedianCytSign)+1);

% normalize
Params.IsNuc = 1;
[NormResults.MedianNucNorm, cutoffs_nuc, mults_nuc] = norm_main(data_nuc, filter, options.Markers, Params);

Params.IsNuc = 0;
[NormResults.MedianCytNorm, cutoffs_cyt, mults_cyt] = norm_main(data_cyt, filter, options.Markers, Params);


redmap = [linspace(0,255,128) zeros(1,128)+255 ]/255;
blumap = [zeros(1,128)+255 flip(linspace(0,255,128))]/255;
gremap = [linspace(128,255,128) flip(linspace(128,255,128))]/255;
NormResults.colorMap = [redmap' gremap' blumap'];
NormResults.CellID = uint16((1:size(NormResults.MedianNucNorm,1))');

NormResults.MedianNucNorm = int16(round(NormResults.MedianNucNorm*1000,0));
NormResults.MedianCytNorm = int16(round(NormResults.MedianCytNorm*1000,0));
NormResults.nuc_add_fact = int16(1000.*cutoffs_nuc); 
NormResults.nuc_mult_fact = int16(1000.*mults_nuc);
NormResults.cyt_add_fact = int16(1000.*cutoffs_cyt); 
NormResults.cyt_mult_fact = int16(1000.*mults_cyt);
%% HARD CODE NORMALIZATION FOR CERTAIN CHANNELS
load([filename.analfolder filename.resufolder 'Results_Norm_' options.date '.mat']);
hard_code_channels = [30]; 
all_nuc_cutoffs = [10];
all_cyt_cutoffs = [NaN];
all_mult_nucs = [1];
all_mult_cyts = [1];
 
for ind1 = 1:length(hard_code_channels)
    ch = hard_code_channels(ind1);
    
    curr_filt = filter(:,ch); 
    
    data_ch_nuc = log2(double(AggrResults.MedianNucSign(curr_filt,ch))+1); 
    data_ch_cyt = log2(double(AggrResults.MedianCytSign(curr_filt,ch))+1); 
    
    cutoff_nuc = all_nuc_cutoffs(ind1); 
    cutoff_cyt = all_nuc_cutoffs(ind1); 
    mult_nuc = all_mult_nucs(ind1); 
    mult_cyt = all_mult_cyts(ind1); 
    
    NormResults.MedianNucNorm(curr_filt,ch) = int16(round(1000*((data_ch_nuc-cutoff_nuc)/mult_nuc)));
    NormResults.MedianCytNorm(curr_filt,ch) = int16(round(1000*((data_ch_cyt-cutoff_cyt)/mult_cyt)));
    
    NormResults.nuc_add_fact(ch) = int16(1000*cutoff_nuc);
    NormResults.cyt_add_fact(ch) = int16(1000*cutoff_cyt);
    NormResults.nuc_mult_fact(ch) = int16(1000*mult_nuc);
    NormResults.cyt_mult_facr(ch) = int16(1000*mult_cyt);
end
save([filename.analfolder filename.resufolder 'Results_Norm_' options.date '.mat'],'NormResults','-v7.3'); 

%% PLOT Individual Cases on Top of Each Other
tissue_loss_thresh = 0.35; 
for c = 1:length(Params.Channels)
    figure(); 
    subplot(1,2,1); hold on; title([options.Markers{Params.Channels(c)} ' Nuclear Signal']); 
    subplot(1,2,2); hold on; title([options.Markers{Params.Channels(c)} ' Cytoplasmic Signal']); 
    curr_filter = filter(:,Params.Channels(c)); 
    legend_names = []; 
    for d = 1:length(Folder_IDs)
        Curr_ID = Folder_IDs(d); 
        Curr_Folder = filename.folders{Curr_ID}; 
        Folder_Mask = AggrResults.Indexes == Curr_ID; 
        subplot(1,2,1);
        if (sum(Folder_Mask & curr_filter)./sum(Folder_Mask))<tissue_loss_thresh 
            continue; 
        end
        [n,h]=ksdensity(NormResults.MedianNucNorm(curr_filter & Folder_Mask,Params.Channels(c)));
        plot(h,n)

        subplot(1,2,2); 
        [n,h]=ksdensity(NormResults.MedianNucNorm(curr_filter & Folder_Mask,Params.Channels(c)));
        plot(h,n)
        
        legend_names = [legend_names {Curr_Folder}];  
    end
    legend(legend_names); 
end

    

%% PLOT KSDensity PLOTS
load([filename.analfolder filename.resufolder 'Results_Norm_' options.date '.mat']); 
for c = 1:length(Params.Channels)
    figure
    subplot(1,2,1); hold on; title([options.Markers{Params.Channels(c)} ' Nuclear Signal']); 
    [n,h]=ksdensity(NormResults.MedianNucNorm(filter(:,Params.Channels(c))==1,Params.Channels(c)));
    plot(h,n)
    plot([0 0],[0 max(n)])
%     xlim([-2000 2000])
    subplot(1,2,2); hold on; title([options.Markers{Params.Channels(c)} ' Cytoplasmic Signal']); 
    [n,h]=ksdensity(NormResults.MedianCytNorm(filter(:,Params.Channels(c))==1,Params.Channels(c)));
    plot(h,n)
    plot([0 0],[0 max(n)])
%     xlim([-2000 2000])
end

%cell types
% load([filename.analfolder filename.resufolder 'Results_CellType_' options.date '.mat']); 
% cell_type_mask = CellType.Matrix(:,4) == 1113; 
% cell_type_name = CellType.names{CellType.codes == 1113}; 
% 
% for c = 1:length(Params.Channels)
%     figure
%     subplot(1,2,1); hold on; title([options.Markers{Params.Channels(c)} ' ' cell_type_name ' Nuclear Signal']); 
%     [n,h]=ksdensity(NormResults.MedianNucNorm(filter(:,Params.Channels(c))==1 & cell_type_mask,Params.Channels(c)));
%     plot(h,n)
%     plot([0 0],[0 max(n)])
% %     xlim([-2000 2000])
%     subplot(1,2,2); hold on; title([options.Markers{Params.Channels(c)} ' ' cell_type_name ' Cytoplasmic Signal']); 
%     [n,h]=ksdensity(NormResults.MedianCytNorm(filter(:,Params.Channels(c))==1 & cell_type_mask,Params.Channels(c)));
%     plot(h,n)
%     plot([0 0],[0 max(n)])
% %     xlim([-2000 2000])
% end
