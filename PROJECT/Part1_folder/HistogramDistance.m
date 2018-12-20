function [ emv_distance ] = HistogramDistance( histA, histB,lambda )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

hist_h_A = histA.hist_h';
hist_h_B = histB.hist_h';
w1 = 1;
w2 = 1;
[x fval] = emd(hist_h_A, hist_h_B, w1, w2, @gdf);
h_dist = fval;

% hist_s_A = histA.hist_s';
% hist_s_B = histB.hist_s';
% w1 = 1;
% w2 = 1;
% [x fval] = emd(hist_s_A, hist_s_B, w1, w2, @gdf);
% s_dist = fval;
% 
% hist_v_A = histA.hist_v';
% hist_v_B = histB.hist_v';
% w1 = 1;
% w2 = 1;
% [x fval] = emd(hist_v_A, hist_v_B, w1, w2, @gdf);
% v_dist = fval;

% emv_distance(1)=red_dist*rho;
% emv_distance(2)=green_dist*rho;
% emv_distance(3)=blue_dist*rho;

emv_distance=((h_dist)^2)*lambda;
end

