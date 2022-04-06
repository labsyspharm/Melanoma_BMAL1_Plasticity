function scatterCellTypes(Matrix_CellTypes,Type_Codes,Type_Names,Centroids,varargin)
%SCATTERCELLTYPES.
%
%   SCATTERCELLTYPES(Matrix_CellTypes,Type_Codes,Centroids) 
%   graphs an XY scatter plot of different cell types based 
%   on their centroid coordinates
%   Allows for quick inspection of cell typing quality, an 
%   overview of the tumor microenvironment, etc. 
%   **Assumptions:
%   1. Cell typing is based on hierarchical clustering
%   2. y-coordinates must be transformed from cartesian coordinate
%   system to matrix indexing coordinates
%
%   User Inputs (Required)
%   Matrix_CellTypes: m x n array (double) with cell type decoding
%   m = total number of cells; n = number of clustering layers
%   
%   Type_Codes: m x 1 vector (double) with codes for desired cell 
%   types to plot; m = number of cell types
%
%   Type_Names: m x 1 cell array with names for each cell type to 
%   to plot; m = total number of cell types
%   
%   Centroids: m x 2 array (double) with XY coordinates for all cells 
%   in dataset
%   m = total number of cells
%
%   Optional Inputs
%   options: a struct containing various user-defined preferences
%
%   Possible Fields: colors, fig_title, samp_size, pixel_size
%   colors: m x 1 cell array containing color designations for 
%   each cell type to be plotted
%   cell entries can either be char values designating color preference 
%   or 1x3 vectors containing exact RGB values
%   fig_title: a string containing the title for the figure
%   samp_size: m x 1 vector (double) containing total number of cells 
%   to be plotted per cell type; pooled randomly from 
%   all cells of that cell type
%   pixel_size
%   Default: cell types will be colored sequentially based on MATLAB 
%   default
%   
%   Outputs
%   Scatter Plot of Different Cell Types

number_inputs = nargin; 
if number_inputs == 5
    options = varargin{1}; 
end
a = figure(); hold on; 

%Figure out if user defined optional preferences

try 
    title(options.fig_title)
catch
    title('Scatter Plot of Cell Types'); 
end

try 
    pixel_size = options.pixel_size; 
catch
    pixel_size = 1; 
end

%Iterate through each cell type and overlay the plots
for type_ind = 1:length(Type_Codes)
    Curr_Type_Code = Type_Codes(type_ind); 
    Curr_Layer = length(num2str(Curr_Type_Code)); 

    Type_Mask = Matrix_CellTypes(:,Curr_Layer) == Curr_Type_Code; %Generates logical vector where true indicates location of desired cell type

    CentroidsX = Centroids(Type_Mask,1); %Assumes [X Y] format
    CentroidsY = Centroids(Type_Mask,2); 
    
    try 
        samp_size = options.samp_size; 
        rand_inds = round(1+rand(1,samp_size)*(length(CentroidsX)-1)); 
        Plot_X = CentroidsX(rand_inds); 
        Plot_Y = CentroidsY(rand_inds); 
    catch
        Plot_X = CentroidsX; 
        Plot_Y = CentroidsY; 
    end
    
    try 
        curr_color = options.colors{type_ind}; 
    catch
        curr_color = ''; 
    end

    a; scatter(Plot_X,max(Centroids(:,2)) - Plot_Y,pixel_size,'filled',curr_color); 
    set(gca,'Color','k'); 
end
end
