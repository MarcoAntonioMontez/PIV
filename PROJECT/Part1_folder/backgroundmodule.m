function [bgdepth, bgrgb] = backgroundmodule(rgb_imgs, depth_imgs)
%BACKGROUNDMODULE
%   calculates the background of all the images using the median (for depth
%   and rgb) and storing it in bgdepth and bggray, respectively.
%   imgs and imgsd are the rbg images and depths respectively

%calculate background
bgdepth=median(depth_imgs,3); %dim 3 = all the images
bgrgb=median(rgb_imgs(:,:,1:size(rgb_imgs,4)),3);
figure;
imagesc(bgdepth);
figure;
colormap(gray);
imagesc(bgrgb);

end

