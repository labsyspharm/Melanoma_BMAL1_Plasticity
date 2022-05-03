function [p_vals,background_vals] = permutationDistTest(Centroids,TypeA,TypeB,varargin)
%PERMUTATIONDISTTEST.
%
%   PERMUTATIONDISTTEST(Centroids,TypeA,TypeB) calculates the background 
%   distance distribution for Cell Type A to Cell Type B based on nearest 
%   neighbor
%
%   Normalizes for prevalence of Cell Type B through shuffling IDs
%   and allows for comparisons to other cell types within individual samples
%
%   Required Inputs: 
%
%   Centroids: nx2 double vector of centroid coordinates [X,Y] for each 
%   segmented cell; n = total number of cells within sample
%
%   TypeA: nx1 logical vector where true indicates the index of Cell Type A
%
%   TypeB: nx1 logical vector where true indicates the index of Cell Type B
%
%   Optional Inputs (Come back)
%
%   optional parameters: iterations, n 
%   iterations = number of times to permutate Cell IDs
%   and calculate 
%   n = nearest neighbor to calculate the distance to
%
%   Default Parameters
%   iterations = 1000; n = 1

number_inputs = nargin; 

switch number_inputs
    case 3
    tic
    TypeA_Cent = Centroids(TypeA,:); 
    TypeB_Cent = Centroids(TypeB,:); 
    
    num_TypeB = sum(TypeB); 
    maxID = length(TypeB); 
    num_TypeA = sum(TypeA); 
    
    [~,dist] = knnsearch(TypeB_Cent,TypeA_Cent,'k',1); 
    log2_dist = log2(dist+1); 
    p_vals = zeros(1000,1); 
    background_vals = zeros(1000,num_TypeA); 
    for curr_iter = 1:1000
        curr_iter
        rand_ids = round(1+rand(1,num_TypeB)*(maxID-1)); %generates new random IDs each iteration
        Rand_Cent = Centroids(rand_ids,:); 
        
        [~,rand_dist] = knnsearch(Rand_Cent,TypeA_Cent,'k',1); 
        log2_rand_dist = log2(rand_dist+1); 
        [~,curr_p_val] = kstest2(log2_dist,log2_rand_dist,'tail','unequal'); 
        p_vals(curr_iter) = curr_p_val; 
        
        background_vals(curr_iter,:) = log2_rand_dist; 
    end
end
toc
end