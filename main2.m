%run('vlfeat-0.9.21/toolbox/vl_setup')
%vl_version verbose
close all; clear; clc;
format compact
%%
% im1=rgb2gray(imread('bonecos/rgb_image1_0005.png'));
% im2=rgb2gray(imread('bonecos/rgb_image2_0005.png'));

im1=rgb2gray(imread('fruta2/rgb_image1_0011.png'));
im2=rgb2gray(imread('fruta2/rgb_image2_0011.png'));

im1d = load('fruta2/depth1_0011.mat');
im2d = load('fruta2/depth2_0011.mat');


%Get Features
[f1, d1] = vl_sift(single(im1));
[f2, d2] = vl_sift(single(im2));
% f = [X;Y;S;TH], where X,Y is the (fractional) center of the frame, 
%                 S is the scale and TH is the orientation (in radians).
% d = 128-dimensional vector of class UINT8.

%Show Features
figure(1);
imshow(im1); hold on; plot(f1(1,:), f1(2,:), '*'); hold off;
figure(2);
imshow(im2); hold on; plot(f1(1,:), f1(2,:), '*'); hold off;

%Match Features
[match, sc] = vl_ubcmatch(d1, d2, 1.5); %increase third parameter to increase threshold
% match contains the indexes in d1,d2 of the paired points
% sc is the squared Euclidean distance between the matches (score), 
%    the lower, the better

%Show matching
figure(3); clf ;

imshow(cat(2, im1,im2));

xa = f1(1,match(1,:)) ;
xb = f2(1,match(2,:)) + size(im1,2) ;
ya = f1(2,match(1,:)) ;
yb = f2(2,match(2,:)) ;

hold on ;
h = line([xa ; xb], [ya ; yb]) ;
set(h,'linewidth', 1, 'color', 'b') ;

vl_plotframe(f1(:,match(1,:))) ;
f2(1,:) = f2(1,:) + size(im1,2) ;
vl_plotframe(f2(:,match(2,:))) ;
axis image off ;



%Ransac
%Choose randomly 3 pairs of points
random1 = floor(rand*length(match));
random2 = floor(rand*length(match));
random3 = floor(rand*length(match));

pair1 = match(:, random1);
pair2 = match(:, random2);
pair3 = match(:, random3);

%getting x,y points from matches --> from f1, f2

%1st random pair
f1temp = f1(:,pair1(1));
f2temp = f2(:,pair1(2));  %%This was giving out 1218 in X which is larger than the picture
xypair1 = [round(f1temp(1:2)/f1temp(3)), round(f2temp(1:2)/f2temp(3))];  %I divided X,Y by S which is the scale ---> f(X,Y,S,TH)
xyzpair1 = vertcat(xypair1, horzcat(im1d.depth_array(xypair1(1,1), xypair1(2,1)), im2d.depth_array(xypair1(1,2), xypair1(2,2))));

%2nd random pair
f1temp = f1(:,pair2(1));
f2temp = f2(:,pair2(2));
xypair2 = [round(f1temp(1:2)/f1temp(3)), round(f2temp(1:2)/f2temp(3))];
xyzpair2 = vertcat(xypair2, horzcat(im1d.depth_array(xypair2(1,1), xypair2(2,1)), im2d.depth_array(xypair2(1,2), xypair2(2,2))));

%3rd random pair
f1temp = f1(:,pair3(1));
f2temp = f2(:,pair3(2));
xypair3 = [round(f1temp(1:2)/f1temp(3)), round(f2temp(1:2)/f2temp(3))];
xyzpair3 = vertcat(xypair3, horzcat(im1d.depth_array(xypair3(1,1), xypair3(2,1)), im2d.depth_array(xypair3(1,2), xypair3(2,2))));


%Estimate transformation


%Check number of inliers for that transformation
epsilon = 1; %no idea about the scale of this error


%Save the transformation with the bigger number of inliers
