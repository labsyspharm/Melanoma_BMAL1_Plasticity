%%
clear all

% codedir = 'Y:\sorger\data\IN_Cell_Analyzer_6000\Giorgio\CycIF Codes\Utility Functions';
% addpath(codedir)
% yangcodedir = 'Y:\sorger\data\IN_Cell_Analyzer_6000\Yang\Time Inference exploration\functions';
% addpath(yangcodedir)

basefolder = '\\research.files.med.harvard.edu\HITS\lsp-analysis\cycif-production\126-circadianregulatorsmelanoma\CCR-023-TumorMarkerValidation\';
analfolder = [basefolder 'ANALYSIS\'];
resufolder = 'RESULTS_LSP12583\';
options.date = '20220321'; 

load([analfolder resufolder 'Results_Aggr_' options.date '.mat'])
load([analfolder resufolder 'Results_Morp_' options.date '.mat'])
load([analfolder resufolder 'Results_Norm_' options.date '.mat'])
load([analfolder resufolder 'Results_Filt_' options.date '.mat'])
load([analfolder resufolder 'Results_Settings_' options.date '.mat'])

filename.basefolder = '\\research.files.med.harvard.edu\HITS\lsp-analysis\cycif-production\126-circadianregulatorsmelanoma\CCR-023-TumorMarkerValidation\';
filename.analfolder = [basefolder 'ANALYSIS\'];
filename.resufolder = 'RESULTS_LSP12583\';

options.maxround = length(options.Markers); 
Cyt_Inds = []; %give indices for markers that are cytoplasmic
Nuc_Markers = true(1,options.maxround); Nuc_Markers(Cyt_Inds) = false; 

%% Define Marker Channels
options.Markers =  {'DAPI1','SOX10 1074','CD31 MEC','CD31 D8V9E', ...
                   'DAPI2','ARG-1','CD163','iNOS', ...
                   'DAPI3','CK-Pan','SOX9','SOX10 SP267', ...
                   'DAPI4','CD103','CD11c','CD11b', ...
                   'DAPI5','PD-L1','F4-80','CD206', ...
                   'DAPI6','H3K27Me3','H3K4Me3','Glut1', ...
                   'DAPI7','Vimentin','HIF1a','Ki-67',...
                   'DAPI8','FOXP3','CD4','CD8a'}; 
                  
inds = 1:length(options.Markers); 

arg1 = inds(strcmpi(options.Markers,'ARG-1')); 
cd103 = inds(strcmpi(options.Markers,'CD103'));
cd11b = inds(strcmpi(options.Markers,'CD11b'));
cd11c = inds(strcmpi(options.Markers,'CD11c'));
cd163 = inds(strcmpi(options.Markers,'CD163')); 
cd4 = inds(strcmpi(options.Markers,'CD4')); 
cd8 = inds(strcmpi(options.Markers,'CD8a')); 
foxp3 = inds(strcmpi(options.Markers,'FOXP3'));
f480 = inds(strcmpi(options.Markers,'F4-80'));
inos = inds(strcmpi(options.Markers,'iNOS'));
sox10_1074 = inds(strcmpi(options.Markers,'SOX10 1074')); 
sox10_sp267 = inds(strcmpi(options.Markers,'SOX10 SP267')); 
sox9 = inds(strcmpi(options.Markers,'SOX9')); 
cd31 = inds(strcmpi(options.Markers,'CD31 D8V9E')); 
%% Define your cell types!
CellType = [];
CellType.NameList ={{'Immune','Epithelial','Other'} ...
                   ,{'Lymphoid','Immune Other'} ...
                   ,{'T','B'} ...
                   ,{'T reg','T helper','T cytotox'} ...
                     };

% worth explaining what these columns mean?
CellType.Classes =  { ...
              {'Immune',               1, 1     ,{arg1,cd103,cd11b,cd11c,cd163,foxp3,cd4,cd8,f480,inos}} ...   
             ,{'Tumor',                1, 2     ,{sox10_sp267,sox9}}  ...
             ,{'Endothelial',          1, 3     ,{cd31}} ... 
             ,{'SOX10+ Tumor',         2, 21    ,{sox10_sp267}} ...
             ,{'SOX9+ Tumor',          2, 22    ,{sox9}} ...
             ,{'SOX9+ SOX10+ Tumor',   2, 23    ,{[sox10_sp267 sox9]}} ...  
             ,{'Myeloid',              2, 11    ,{arg1,cd103,cd11c,cd163,f480,inos}} ...
             ,{'Lymphoid',             2, 12    ,{cd4,cd8,foxp3}} ...
             ,{'DC',                   3, 111   ,{[cd11c cd103]}} ...
             ,{'MAC',                  3, 112   ,{arg1,cd163,f480,inos}} ...
             ,{'M1 MAC'                4, 1121  ,{[f480 inos]}} ...
             ,{'M2 MAC'                4, 1122  ,{[f480 arg1],[f480 cd163]}} ...
             };

% ABlist is an ordered list of all the channels (antibodies) used for cell typing
CellType.ABlist = cellfun(@(x) x{4},CellType.Classes,'un',0);
CellType.ABlist = unique(cell2mat(cellfun(@(x) abs([x{:}]),CellType.ABlist,'un',0)));
% use this list to specify which markers are Nuclear vs Cytoplasmic
    % 1 for nuclear (default), 0 for cytoplasmic
CellType.NvC = Nuc_Markers(CellType.ABlist); 
ab_nuc_ind = CellType.ABlist(CellType.NvC); 
ab_cyt_ind = CellType.ABlist(~CellType.NvC); 
CellType.ABlist = [ab_nuc_ind ab_cyt_ind]; %Claire added all of this because you have to change the index order
CellType.NvC = [true(1,length(ab_nuc_ind)) false(1,length(ab_cyt_ind))]; 

CellType.index = [];
CellType.codes  = [];
CellType.layer = [];
CellType.names  = {};
CellType.layerjump = 10;  % either 10 or 100 usually

for i = 1:length(CellType.Classes)
    CellType.index = [CellType.index; i];
    CellType.codes  = [CellType.codes;  CellType.Classes{i}{3}];
    CellType.layer = [CellType.layer; CellType.Classes{i}{2}];
    CellType.names  = [CellType.names;  CellType.Classes{i}{1}];
    
end

%%% Classify your cells!

totcells = length(NormResults.MedianNucNorm(:,1));

TypeData = zeros(size(NormResults.MedianNucNorm)); %int16 should not be used when using log2 data; 
TypeData(:,CellType.ABlist) = [NormResults.MedianNucNorm(:,CellType.ABlist(CellType.NvC)) NormResults.MedianCytNorm(:,CellType.ABlist(~CellType.NvC))]; 

for layer = 1:max(CellType.layer)
    layer
    % define how many types of cells this layer has
    types = CellType.index(CellType.layer==layer);
    Matrix{layer} = zeros(totcells,length(types));
    ProbType{layer} = zeros(totcells,length(types));
    
    for type = 1:length(types)
        % count the number of criteria used
        num_criteria = size(CellType.Classes{types(type)}{4},2);
        
        ind_mat = zeros(totcells,num_criteria);
        ind_prob= zeros(totcells,num_criteria);
        for i3 = 1:num_criteria
            crit = CellType.Classes{types(type)}{4}{i3};
           
            temp_ind = ones(totcells,1);
            temp_prob= zeros(totcells,1)+NaN;
            for i4 = 1:length(crit)
                crit_ind = sign(crit(i4)) * TypeData(:,abs(crit(i4))) > 0 ;%.* uint16(Filter.all(:,abs(crit(i4)))) 
                temp_ind = temp_ind & crit_ind;
                if sign(crit(i4)) > 0
                    test = crit_ind.*double(TypeData(:,crit(i4)));
                    test(test==0) = NaN;
                    temp_prob = min([temp_prob, test],[],2);
                end 
            end
            ind_mat(:,i3)  = temp_ind;
            ind_prob(:,i3) = temp_prob;
        end
        ind_vect = max(ind_mat,[],2);
        Matrix{layer}(ind_vect>0,type) = CellType.codes(types(type)); 
        ProbType{layer}(ind_vect>0,type) = max(ind_prob(ind_vect>0,:),[],2);
    end   
end
clear temp_ind

%%%% check and resolve conflicts

% - starting from the first layer we check for conflicts and resolve each
% layer into one column instead of one matrix
% - then we check in the next matrix and first take out all the calls that
% should not have been made in the first place, because the second layer
% does not match the next one
% loop through the two-way comparison for each layer
thresh = 100;
test = [];
CleanMatrix = Matrix;
CleanProbType = ProbType;
CellType.Matrix = [];

for i1 = 1:length(Matrix)
    i1
    % from the second layer onwards check that the subcalls were made from
    % the right branch of the layer above, if not set them to zero
    if i1 > 1
        for j = 1:size(CleanMatrix{i1},2)
            wrong_branch_index = CleanMatrix{i1}(:,j) > 0 & CellType.Matrix(:,i1-1) ~= floor(CleanMatrix{i1}(:,j)/CellType.layerjump);
            CleanMatrix{i1}(wrong_branch_index,j) = 0;
            CleanProbType{i1}(wrong_branch_index,j) = 0;
        end
    end
    for j1 = 1:size(CleanMatrix{i1},2)
        for j2 = j1+1:size(CleanMatrix{i1},2)
            mat  = [CleanMatrix{i1}(:,j1) CleanMatrix{i1}(:,j2)];
            prob = [CleanProbType{i1}(:,j1) CleanProbType{i1}(:,j2)];
            
            % find conflicts
            index_conflict = mat(:,1) > 0 & mat(:,2) > 0;
            mat_conflict = mat(index_conflict,:);
            prob_conflict = prob(index_conflict,:);
            
            for doubt = 1:size(mat_conflict,1)
                [~,ind_worse] = min(prob_conflict(doubt,:));
                mat_conflict(doubt,ind_worse) = 0;
            end

            % if the difference in probability is less than say 0.1 put
            % both the celltypecodes to 0
            diff_prob = abs(prob_conflict(:,1)-prob_conflict(:,2));
            mat_conflict(diff_prob < thresh,:) = 0;

            mat(index_conflict,:) = mat_conflict;

            CleanMatrix{i1}(:,j1) = mat(:,1);
            CleanMatrix{i1}(:,j2) = mat(:,2);
           
        end
    end
    CellType.Matrix(:,i1) = max(CleanMatrix{i1},[],2);
end

% save some space
CellType.Matrix = uint16(CellType.Matrix);

% check for clean up efficiency
for i = 1:length(Matrix)
    matcheck = CleanMatrix{i};
    for j1 = 1:size(matcheck,2)
        for j2 = j1+1:size(matcheck,2)
            disp([num2str(i) ' ' num2str(j1) ' ' num2str(j2) ' ' num2str(sum(matcheck(:,j1)>0 & matcheck(:,j2)>0))])
        end
    end
end


count = 0;
for i = 1:size(CellType.Matrix,2)
    types = unique(CellType.Matrix(:,i));
    for t = 1:length(types)
        count = count + 1;
        rep(count,1) = i;
        rep(count,2) = types(t);
        rep(count,3) = sum(CellType.Matrix(:,i)==types(t));
    end
end
CellType.Count = rep;


save([filename.analfolder filename.resufolder 'Results_CellType_' options.date '.mat'],'CellType')
disp('DONE!')
