function [ distance ] = Distance(A,B)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    rho=0.001;
    distance = rho * norm(A-B,2)^2;
end

