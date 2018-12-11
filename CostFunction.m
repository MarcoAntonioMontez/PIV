function [ total_distance ] = CostFunction( A, B)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    if isempty(A)
       distance = 0;
       return 
    end
     world_distance = Distance(A.center,B.center);
     rgb_distance = HistogramDistance(A.histogram,B.histogram);
     total_distance=world_distance+rgb_distance;
%     show_hist(A.histogram)
%     show_hist(B.histogram)
end

