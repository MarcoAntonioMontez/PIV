function [imgs, imgsd, bgdepth, bggray] = backgroundmodule( img_folder,n_images)
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
if n_images == 0
    n_images=size(imgsd,3);
end

bgdepth=median(imgsd(:,:,1:n_images),3); %dim 3 = all the images
bggray=median(imgs(:,:,1:n_images),3);
figure;
imagesc(bgdepth);
figure;
colormap(gray);
imagesc(bggray);

end

