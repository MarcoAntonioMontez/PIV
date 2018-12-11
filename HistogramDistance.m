function [ emv_distance ] = HistogramDistance( histA, histB )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
rho=50;


hist_red_A = histA.hist_red';
hist_red_B = histB.hist_red';
w1 = 1;
w2 = 1;
[x fval] = emd(hist_red_A, hist_red_B, w1, w2, @gdf);
red_dist = fval;

hist_green_A = histA.hist_green';
hist_green_B = histB.hist_green';
w1 = 1;
w2 = 1;
[x fval] = emd(hist_green_A, hist_green_B, w1, w2, @gdf);
green_dist = fval;

hist_blue_A = histA.hist_blue';
hist_blue_B = histB.hist_blue';
w1 = 1;
w2 = 1;
[x fval] = emd(hist_blue_A, hist_blue_B, w1, w2, @gdf);
blue_dist = fval;

% emv_distance(1)=red_dist*rho;
% emv_distance(2)=green_dist*rho;
% emv_distance(3)=blue_dist*rho;

emv_distance=(red_dist+green_dist+blue_dist)*rho;
end

