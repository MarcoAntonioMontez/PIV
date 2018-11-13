function [imgs, imgsd, bgdepth, bggray] = backgroundmodule( img_folder)
%BACKGROUNDMODULE
%   After loading the rgb2gray and depth variables, this funciton is responsible
%   for calculating the background of all the images using the median (for depth
%   and rgb) and storing it in bgdepth and bggray, respectively.
%   imgs and imgsd are the rbg images and depths respectively
main_folder = pwd;
cd(img_folder);
d=dir('*.jpg');
dd=dir('*.mat');
cd(main_folder)
%load images rgb2gray and depth into workspace
[imgs, imgsd]=load_images(d, dd);

%calculate background
bgdepth=median(imgsd,3); %dim 3 = all the images
bggray=median(imgs,3);
figure;
imagesc(bgdepth);
figure;
colormap(gray);
imagesc(bggray);

end

