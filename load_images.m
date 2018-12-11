function [imgs, imgsd] = load_images( d, dd )
%LOAD_IMAGES 
%   Load images rgb2gray and depth into workspace given the corresponding dir()
imgs=zeros(480,640,3,length(d),'uint8'); % create an array of rgb
imgsd=zeros(480,640,length(d)); % create an array of depth

for i=1:length(d), %for every image
    imgs(:,:,:,i)=(imread(d(i).name)); 
    %imgs(:,:,i)=rgb2gray(imread(d(i).name)); 
    % creates a 3D-Matrix type of storage converting the rbg images to gray 
    % imgs(:,:,i) corresponds to image i
    % imgs(x,y,i) corresponds to pixel (x,y) of image i
    load(dd(i).name);
    imgsd(:,:,i)=double(depth_array)/1000; 
    [im_rgb_calib, im_rgb_vector_calib, P_xyz, M_transf] = depth_to_rgb(imgs(:,:,:,i),double(depth_array));
    imgs(:,:,:,i)=im_rgb_calib;
    
    % imgsd stores the depth measures of each image
    % /1000 to convert from millimeters to meters
    
    %colormap(gray);
end

end

