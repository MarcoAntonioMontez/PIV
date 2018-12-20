function [ total_distance ] = CostFunction(A,B)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    rho=0.01;
    lambda=2000;
    
    if isempty(A)
       distance = 0;
       return 
    end
     world_distance = Distance(A,B,rho);
     hue_distance = HistogramDistance(A.histogram,B.histogram,lambda);
     
     
     total_distance=world_distance+hue_distance;
%     show_hist(A.histogram)
%     show_hist(B.histogram)
end

