%%
run('vlfeat-0.9.21/toolbox/vl_setup')
% vl_version
%%
close all; clear; clc;
format compact
%% Load Images and find Background module
% img_folder = 'test_2';
% [imgs, imgsd, bgdepth, bggray] = backgroundmodule( img_folder);
%%
im1=rgb2gray(imread('test_2/rgb_image1_0052.png'));
im2=rgb2gray(imread('test_2/rgb_image2_0052.png'));
% d1 = load('test_2/depth1_0052.mat');
% d2 = load('test_2/depth1_0052.mat');
%%
[f1, d1] = vl_sift(single(im1));
[f2, d2] = vl_sift(single(im2));
figure(1);
imagesc(im1); hold on; plot(f1(1,:), f1(2,:), '*'); hold off;
figure(2);
imagesc(im2); hold on; plot(f1(1,:), f1(2,:), '*'); hold off;
%%
[match, sc] = vl_ubcmatch(d1, d2);
figure(3);
imagesc([im1, im2]);
hold on;
% [minValue_x, maxValue_x, minValue_y, maxValue_y, minValue_z, maxValue_z] = boxplot( class_x, class_y, class_depth); 
line([minValue_y maxValue_y],[minValue_x minValue_x],'Color','red')
line([minValue_y maxValue_y],[maxValue_x maxValue_x],'Color','red')
line([minValue_y minValue_y],[minValue_x maxValue_x],'Color','red')
line([maxValue_y maxValue_y],[minValue_x maxValue_x],'Color','red')