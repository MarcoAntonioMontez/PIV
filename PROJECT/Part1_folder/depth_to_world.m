function [ P_xyz ] = depth_to_world( depth_array )
%DEPTH_TO_RGB
% argmuments
%   im = imread(image) 480x640x3 uint8
%   depth_array = 480x640 uint16
%
% output
%   im_rgb_calib = depth image calibrated in rgb image 
%              480x640x3 (x,y,rgb) image coordinates
%   im_rgb_vector_calib = image vector of rgb to use in pointCloud reconstruction
%                  307200x3 double (r,g,b)
%   P_xyz = calibrated depth image (vector) in world (to use in pointCloud
%   reconstruction)
%       3x307200 double (x,y,z) World coordinates
load cameraparametersAsus.mat
% cam_params.Kdepth  - the 3x3 matrix for the intrinsic parameters for depth
% cam_params.Krgb - the 3x3 matrix for the intrinsic parameters for rgb
% cam_params.R - the Rotation matrix from depth to RGB (extrinsic params)
% cam_params.T - The translation from depth to RGB 

Z=double(depth_array(:)');%/1000; %millimeters to meters

% Compute correspondence between two imagens in 5 lines of code
[v, u]=ind2sub([480 640],(1:480*640)); %compute u and v for every pixel
P_xyz=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]; %depth_cam to world
P_xyz=P_xyz';

end

