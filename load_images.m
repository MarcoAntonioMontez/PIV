function [imgs, imgsd] = load_images( d, dd )
%LOAD_IMAGES 
%   Load images rgb2gray and depth into workspace given the corresponding dir()
imgs=zeros(480,640,length(d)); % create an array of rgb
imgsd=zeros(480,640,length(d)); % create an array of depth

for i=1:length(d), %for every image
    imgs(:,:,i)=rgb2gray(imread(d(i).name)); 
    % creates a 3D-Matrix type of storage converting the rbg images to gray 
    % imgs(:,:,i) corresponds to image i
    % imgs(x,y,i) corresponds to pixel (x,y) of image i
    load(dd(i).name);
    imgsd(:,:,i)=double(depth_array)/1000; 
    % imgsd stores the depth measures of each image
    % /1000 to convert from millimeters to meters
    
    %colormap(gray);
end

end

