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

length_f1=size(f1,2);
length_f2=size(f2,2);

avf1x=sum(f1(1,:))/length_f1;
avf1y=sum(f1(2,:))/length_f1;
avf2x=sum(f2(1,:))/length_f2;
avf2y=sum(f2(2,:))/length_f2;


%Estou a assumir que o f1 guarda na forma [x1 x2 ... xn; y1 y2 ... yn; etc]
%caso o f1 guardasse [x1 y1 ...; x2 y2 ...; ...]
% fica diferente
acum1=zeros(1,length_f1);
for i = 1:length_f1
    x=f1(1,i);
    y=f1(2,i);
    
    acum1(i)=im1d.depth_array(y,x);
end
avf1z=sum(acum1)/length_f1;

acum2=zeros(1,length_f2);
for i = 1:length_f2
    x=f2(1,i);
    y=f2(2,i);
    
    acum2(i)=im2d.depth_array(y,x);
end
avf2z=sum(acum2)/length_f2;

% avf1z=sum(im1d.depth_array(fix(f1(2,:)), fix(f1(1,:))))/length(f1);
% avf2z=sum(im2d.depth_array(fix(f2(2,:)), fix(f2(1,:))))/length(f2);


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
f1plot=f1;
f2plot=f2;
vl_plotframe(f1plot(:,match(1,:)));
f2plot(1,:) = f2plot(1,:) + size(im1,2) ;
vl_plotframe(f2plot(:,match(2,:)));
axis image off ;


%Ransac
%Choose randomly 3 pairs of points

%getting x,y points from matches --> from f1, f2
%account for matlab switching stuff
%1st random pair
xyzpair1 = zeros(3,2);
while(ismember(0, xyzpair1))
    random1 = floor(rand*length(match));
    pair1 = match(:, random1);
    f1temp = f1(:,pair1(1));
    f2temp = f2(:,pair1(2));  %%This was giving out 1218 in X which is larger than the picture
    xypair1 = [fix(f1temp(1:2)), fix(f2temp(1:2))];  %I divided X,Y by S which is the scale ---> f(X,Y,S,TH)

    %deal with matlab shit
    xypair1temp=xypair1;
    xypair1(1,:)=xypair1(2,:);
    xypair1(2,:)=xypair1temp(1,:);

    xyzpair1 = vertcat(xypair1, horzcat(im1d.depth_array(xypair1(1,1), xypair1(2,1)), im2d.depth_array(xypair1(1,2), xypair1(2,2))));
end

xyzpair2 = zeros(3,2);
while(ismember(0, xyzpair2))
    random2 = floor(rand*length(match));
    pair2 = match(:, random2);
    %2nd random pair
    f1temp = f1(:,pair2(1));
    f2temp = f2(:,pair2(2));
    xypair2 = [fix(f1temp(1:2)), fix(f2temp(1:2))];

    %deal with matlab shit
    xypair2temp=xypair2;
    xypair2(1,:)=xypair2(2,:);
    xypair2(2,:)=xypair2temp(1,:);

    xyzpair2 = vertcat(xypair2, horzcat(im1d.depth_array(xypair2(1,1), xypair2(2,1)), im2d.depth_array(xypair2(1,2), xypair2(2,2))));
end

xyzpair3 = zeros(3,2);
while(ismember(0, xyzpair3))
    random3 = floor(rand*length(match));
    pair3 = match(:, random3);
    %3rd random pair
    f1temp = f1(:,pair3(1));
    f2temp = f2(:,pair3(2));
    xypair3 = [fix(f1temp(1:2)), fix(f2temp(1:2))];

    %deal with matlab shit
    xypair3temp=xypair3;
    xypair3(1,:)=xypair3(2,:);
    xypair3(2,:)=xypair3temp(1,:);

    xyzpair3 = vertcat(xypair3, horzcat(im1d.depth_array(xypair3(1,1), xypair3(2,1)), im2d.depth_array(xypair3(1,2), xypair3(2,2))));
end

xyzpair4 = zeros(3,2);
while(ismember(0, xyzpair4))
    random4 = floor(rand*length(match));
    pair4 = match(:, random4);
    %4th random pair
    f1temp = f1(:,pair4(1));
    f2temp = f2(:,pair4(2));
    xypair4 = [fix(f1temp(1:2)), fix(f2temp(1:2))];

    %deal with matlab shit
    xypair4temp=xypair4;
    xypair4(1,:)=xypair4(2,:);
    xypair4(2,:)=xypair4temp(1,:);

    xyzpair4 = vertcat(xypair4, horzcat(im1d.depth_array(xypair4(1,1), xypair4(2,1)), im2d.depth_array(xypair4(1,2), xypair4(2,2))));
end

%Estimate transformation
n=4;

Apoints = [xyzpair1(:,1), xyzpair2(:,1), xyzpair3(:,1), xyzpair4(:,1)];
Bpoints = [xyzpair1(:,2), xyzpair2(:,2), xyzpair3(:,2), xyzpair4(:,2)];



%solution for translation
T = [avf1x-avf2x; avf1y-avf2y; avf1z-avf2z];  %this gives out the Translation

%plug translation
A_linha = double(Apoints) - double([T, T, T, T]);
[d,Z,tr] = procrustes(double(A_linha'), double(Bpoints'), 'reflection', false);
Z=Z';
%Check number of inliers for that transformation
epsilon = 1; %no idea about the scale of this error



%Save the transformation with the bigger number of inliers
