function [ distance ] = CostFunction( A, B)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    if isempty(A)
       distance = 0;
       return 
    end

    distance = Distance(A.center,B.center);

end

