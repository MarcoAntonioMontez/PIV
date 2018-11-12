function [imgs, imgsd, bgdepth, bggray] = backgroundmodule( img_folder)
%BACKGROUNDMODULE Summary of this function goes here
%   Detailed explanation goes here
main_folder = pwd;
cd(img_folder);
d=dir('*.jpg');
dd=dir('*.mat');
cd(main_folder)
%load images rgb2gray and depth into workspace
[imgs, imgsd]=load_images(d, dd);

cd(main_folder);

%calculate background
bgdepth=median(imgsd,3); %dim 3 = 38 images
bggray=median(imgs,3);
figure;
imagesc(bgdepth);
figure;
colormap(gray);
imagesc(bggray);


end

