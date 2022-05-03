%% RUN_Distance_CellTypes
%% USER INPUTS
filename.analfolder = '\\research.files.med.harvard.edu\hits\lsp-analysis\cycif-production\126-circadianregulatorsmelanoma\CCR-023-TumorMarkerValidation\ANALYSIS\'; 
Curr_Folder = 'LSP12583'; 
filename.resufolder = ['RESULTS_' Curr_Folder '\'];

options.date = '20220321'; 

cell_codes = [21 22]; 
cell_colors = {[0 0.4 0],[0 0 1]}; 
compare_code = [3]; 
display_group_ids = [3]; 
display_group_names = {'Control','EV','WT-BMAL1','dHLH BMAL1'}; 

pixel_conversion = 0.325; 
%% LOAD DATA
load([filename.analfolder filename.resufolder 'Results_CellType_' options.date '.mat']); 
load([filename.analfolder filename.resufolder Curr_Folder '_Results_' options.date '.mat']); 
load([filename.analfolder filename.resufolder 'Results_Morp_' options.date '.mat']); 

compare_mask = CellType.Matrix(:,length(num2str(compare_code))) == compare_code; 
compare_name_mask = CellType.codes == compare_code; 
compare_name = CellType.names{compare_name_mask}; 
%% Visualize Log2 Distance of all Cell Type Comparisons in Different Cell Lines (All on One Plot for Easy Comparison)
% Doesn't normalize for cell prevalence

fig1 = figure(); title(['Distance from Endothelial Cells to Their Nearest Tumor Cell']); hold on; 
legend_names = cell(1,length(cell_codes)*length(display_group_ids)); 
count = 1; 
for ind1 = 1:length(cell_codes)
    curr_code = cell_codes(ind1); 
    name_mask = CellType.codes == curr_code; 
    type_name = CellType.names{name_mask}; 
    layer = length(num2str(curr_code)); 
    curr_color = cell_colors{ind1}; 
    
    type_mask = CellType.Matrix(:,layer) == curr_code; 
    
    for ind2 = 1:length(display_group_ids)
        curr_group_id = display_group_ids(ind2); 
        curr_group_name = display_group_names{curr_group_id}; 
        
        curr_group_mask = MorpResults.Group_IDs == curr_group_id; 
        
        Curr_X = Results.CentroidX(curr_group_mask & type_mask); Curr_Y = Results.CentroidY(curr_group_mask & type_mask); 
        Comp_X = Results.CentroidX(curr_group_mask & compare_mask); Comp_Y = Results.CentroidY(curr_group_mask & compare_mask); 
        
%         [~,dist_celltype] = knnsearch([Comp_X Comp_Y],[Curr_X Curr_Y],'k',1);  
        [~,dist_celltype] = knnsearch([Curr_X Curr_Y],[Comp_X Comp_Y],'k',1); 
        log2_dist_celltype = log2((dist_celltype+1)*pixel_conversion); 
        [p_vals,background_vals] = permutationDistTest([Results.CentroidX Results.CentroidY],curr_group_mask & type_mask,curr_group_mask & compare_mask); 
        
        [r,c] = size(background_vals); 
        
        fig1; ksdensity(log2_dist_celltype); hold on; ksdensity(reshape(background_vals,1,r*c)); 
        legend_names{count} = [compare_name ' to ' type_name ' in ' curr_group_name]; 
        count = count + 1; 
    end
end

fig1; legend(legend_names); 
xlabel('Log2 Distance in Microns'); 
%% Calculute Distance to Cell Types Normalized By Prevalence (Permutation Test)
%Calculates on Group Level not Core Level
num_iter = 50; 
group_ids = [2 3 4]; 
cell_codes = [21 22]; 

compare_code = 3; 
%% Calculate Spatial Correlation Between Markers Within Certain Cell Types (Cell Level not Pixel Level)
markers = {'H3K27Me3','H3K4Me3','Glut1','HIF1a'}; 

cell_codes = [21 22]; 






