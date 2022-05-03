function runAll_O2_YUMM(Curr_Folder,marker_file)
%
% t-CycIF ASHLAR ANALYSIS PIPELINE 
% Step 0: Stitch and register the fields into an "ome.tif" by using Ashlar 
% Step 1:(RUN_Step1_new_fields_preilastik_crops.m) Cut the "ome.tif" into 
% fields of a size specified by the user and cut crops out of each field 
% for Ilastik training. Create full stacks of all cycles and channels. 
% Omits fields that have no cells.   
% Step 2: Create segmentation probabilities using Ilastik
% (RUN_ALL_segon.m)Runs segmentation and measurements scripts (Step 3 & 4) 
% Step 3:(RUN_Step3_segmentfromilastik.m) Segment based on segmentation
% probabilities produce by Ilastik
% Step 4: (RUN_Step4_CycIF_measurments_ilastik.m) Makes measurements of
% signal and foci segmentation 
% Step 5: (RUN_Step5_ROI.m) Finds pixel location of ROIs and indexes of
% centroids within the ROI 
% 
% In order to begin the analysis a set of parameters are needed to be
% defined by the user 
% 1) where the  files are located and how the names are formatted
% 2) parameters to choose the size of the field and number of crops per
% field 

%%% OUTPUTS FILES AND LOCATIONS 
% Step 1:
% FullStacks: AllTheRawData\OmeTifName\FullStacks\OmeTifName_Field_row_column.tif
% CroppedStacks: AllTheRawData\OmeTifName\CroppedData\OmeTifName_Field_row_column_#ofCrop.tif
% Coordinates: AllTheRawData\Coordinates_FullStacks\OmeTifName.mat 
% y= # of pixels in 1 column; x = # of pixels in 1 row ; t = size of field desired 
% Coordinates Matrix: Coordinates.Field(row,column) = [keep field (0= no, 1=yes), x1, x2, y1, y2]
% Montage: AllTheRawData\MontageforROI\OmeTifName_montage.tif 
% Step 3:
% Segmented Images: AllTheRawData\ANALYSIS\OmeTifName\Ilastik_Segmentation\OmeTifName_Field_row_column_Seg.tif
% Check Segmented Images: AllTheRawData\ANALYSIS\OmeTifName\Ilastik_Segmentation\OmeTifName_Field_row_column_checkseg.tif
% Step 4: 
% Nucleus & Cytoplasm SegmentedImages: AllTheRawData\ANALYSIS\OmeTifName\Ilastik_Segmentation\OmeTifName_Field_row_column_NucCytSeg.tif
% Foci Segmented Images: AllTheRawData\ANALYSIS\OmeTifName\Foci_Segmentation\OmeTifName_Field_row_column__HSF1_FociSeg.tif
% Foci Check Segmented Images: AllTheRawData\ANALYSIS\OmeTifName\Foci_Segmentation\OmeTifName_Field_row_column__HSF1_FociSeg_check.tif
% Measurments file: AllTheRawData\ANALYSIS\Analysis_Results\Results_data.mat 
% Step 5:
% ROI_pixels: AllTheRawData\ROIpixels\OmeTifName\ROI_pixels.mat: matrix of pixel locations (x,y) of ROIs, vector of row indexes of Centroids that are within the ROI  


%%% INPUT FILE LOCATION AND FORMATTING
%
% The code will run on the Ilastik Probabilities file and FullStacks file 
% The expected file structure is that a master folder will contain all of
% the "ome.tif" data and within that folder, a folder called "ANALYSIS\"
% will contain all the Ilastik Probabilities and FullStacks data 
%
%%% IMPORTANT: Ilastik Output Filename Format for Export Options
% {dataset_dir}/Ilastik_Probabilities/{nickname}_Probabilities.tif

% eg. AllTheRawData\ANALYSIS\OmeTifName\FullStacks\Ilastik_Probabilities\SlideName_Field_row_column_Probabilities.tif 
% eg. AllTheRawData\ANALYSIS\OmeTifName\FullStacks\SlideName_Field_row_column.tif 

% ROI:
% Must be drawn on ImageJ on the the montage created in RUN_Step1_new_fields_preilastik_crops
% Location: Montage: AllTheRawData\MontageforROI\OmeTifName_montage.tif 
% ROIs must be save in "AllTheRawData\MontageforROI\" and named with "OmeTifName" 

% 1) THE MASTER OME.TIF DATA FOLDER
filename = [];
filename.folders.main = '/n/scratch3/users/c/ccr13/Chi_CyCIF/';

% 2) SLIDE SPECIFIC PARAMETERS:
filename.tissues = {Curr_Folder};
                %Name of Ashlared image without '.ome.tif' ending 
filename.folders.fols = {Curr_Folder}                

% 3) USER DESIRED PARAMETERS 
filename.sizefield = 5000; %Size of field desired for a square 
filename.ashlarqc.subfield = 10; %make sure filename.sizefield is divisible by this
filename.crops = 1; %# of cropped fields desired per field 
options.DAPIbkgd = 1000; % thresh for DAPI used to check if we keep the field
% options.crops.DAPIbkgd_crops = options.DAPIbkgd*2;
% options.crops.prctile = 90;

% 4) OPTIONS  
% Step 3: SEGMENTATION OPTIONS 
options.nuc = 1;    %Channel nucleus Ilastik probability is in
options.cyt = 2; %Channel cytoplasm Ilastik probability is in
options.backgr = 3; %Channel background Ilastik probability is in 
options.cellsize = 15;
options.bkgdprob_min = 0.2;
options.cytprob_min  = 0.8;
options.nucprob_min  = 0.33;
options.max_prob = 65535; %Maximum Ilastik probability, usually does not change
options.pausetime = 0;

% Step 4: MEASUREMENTS AND FOCI OPTIONS 
options.date = '20220310';

% Step 5 which slice to use for the montage for ROI
options.pyramidlevel = 3;


% 5) OUTPUT PARAMETERS: DO NOT EDIT 
filename.folders.ashlared = 'DATA/'; 
filename.ashlarsubfol = '/registration/';
filename.ashlarsuffix = '.ome.tif';
filename.folders.output = 'ANALYSIS/'; 
filename.folders.fullstacks = 'FullStacks/';
filename.folders.coordinates = 'Coordinates_FullStacks/';

filename.folders.ilastikstacks = 'IlastikStacks/';
filename.folders.cropfol = 'CroppedData/';
filename.folders.ilastikprob= 'IlastikProb/';
filename.folders.ilastikseg = 'Ilastik_Segmentation/';
filename.ilastiksuffix = '_Probabilities.tif';

% filename.folders.ometiff = 'DATA\ashlar\';
filename.folders.montagelowres = ['MontageforROI_Lv' num2str(options.pyramidlevel) '/'];

filename.folders.results = 'RESULTS/';
filename.folders.alignqc = 'QC_align/';
filename.folders.ROI = 'ROIs/'; 
filename.suffix = '.tif';
% filename.folders.montage = 'MontageforROI\'; 
filename.dim = ['%02d']; %Delimeter 
filename.overwrite_seg = 0;

%LOAD markers.csv file and save options.Markers setting
marker_table = readtable([filename.folders.main filename.folders.ashlared filename.tissues{1} filesep 'markers.csv']);
options.Markers = marker_table.marker_name'; 
options.Cycles = marker_table.cycle; 

filename.cycles = max(options.Cycles); % # of cycles to analyse
filename.maxround = length(options.Markers);

filename.ilastikround = 16; % these are the rounds to be used to segment in Ilastik
disp('DONE') 

%% MAKE SURE TO COMMENT OUT THE OTHER STEPS THAT YOU AREN'T AT YET!!
% % % Runs Step 1: (Creating FullStacks, CroppedStacks, Montages) 
% % 
Step1_fields_preilastik(filename,options) 
% % 
% % % after this step need to perform Ilastik step to create probability maps
% % 
% % %% clean up the crops to avoid useless ones - optional
% % % Step2b_filtercrops_v2(filename,options)
%% Runs Step 3: Segmentation
%%Step3_segmentfromilastik_v3_LabelNoDilate(filename, options) 
% Runs Step 4: Measurments
%%Step4_CycIF_measurements_ilastik(filename, options) 
% pause(10*60)

%% Extract montages for ROI
% Step5_montageforROI_v2(filename, options)

%% Run Step 5: (ROI Selection)

% Step6_AshlarAlignmentQC(filename, options)
end
