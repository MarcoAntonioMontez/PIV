function [im_rgb_calib, im_rgb_vector_calib, depth_calib, P_xyz] = depth_to_rgb(im,depth_array)
%DEPTH_TO_RGB
% argmuments
%   im = imread(image) 480x640x3 uint8
%   depth_array = 480x640 uint16
%
% output
%   im_calib = calibrated rbg image 
%              480x640x3 (x,y,rgb) image coordinates
%   im_calib_xyz = image vector of rgb to use in pointCloud reconstruction
%                  307200x3 double (r,g,b)
%   P_calib = calibrated depth.array (should be equal to depth_array)
%             480x640 uint16 (x,y)->depth image coordinates
%   P = image vector of depth to use in pointCloud reconstruction
%       3x307200 double (x,y,z) World coordinates

load cameraparametersAsus.mat
% cam_params.Kdepth  - the 3x3 matrix for the intrinsic parameters for depth
% cam_params.Krgb - the 3x3 matrix for the intrinsic parameters for rgb
% cam_params.R - the Rotation matrix from depth to RGB (extrinsic params)
% cam_params.T - The translation from depth to RGB 

Z=double(depth_array(:)')/1000; %millimeters to meters

% Compute correspondence between two imagens in 5 lines of code
[v, u]=ind2sub([480 640],(1:480*640)); %compute u and v for every pixel
P_xyz=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]; %depth_cam to world
niu=cam_params.Krgb*[cam_params.R cam_params.T]*[P_xyz;ones(1,640*480)]; %depth_cam to rgb_cam
u2=round(niu(1,:)./niu(3,:));
v2=round(niu(2,:)./niu(3,:));

im_rgb_vector_calib=zeros(640*480,3);
indsclean=find((u2>=1)&(u2<=641)&(v2>=1)&(v2<=480));
indscolor=sub2ind([480 640],v2(indsclean),u2(indsclean));
im1aux=reshape(im,[640*480 3]);
im_rgb_vector_calib(indsclean,:)=im1aux(indscolor,:); %calibrated im

im_rgb_calib = uint8(reshape(im_rgb_vector_calib,[480,640,3]));
depth_calib = uint16(reshape(P_xyz(3,:),[480,640])*1000);
end

% [im1_ im1_xyz P_1 P_xyz_1] = depth_to_rgb(imread('fruta2/rgb_image1_0011.png'),im1d.depth_array);
% pc=pointCloud(P_xyz_1', 'color',uint8(im1_xyz));
% figure(1);showPointCloud(pc);