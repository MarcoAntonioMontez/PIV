function [im_calib im_calib_xyz P_calib P] = depth_to_rgb(im,depth_array)
%DEPTH_TO_RGB
%   im = imread(image) 480x640x3 uint8
%   depth_array = 480x640 uint16
load CalibrationData.mat
Kd=Depth_cam.K;
Z=double(depth_array(:)')/1000; %millimeters to meters

% Compute correspondence between two imagens in 5 lines of code
[v u]=ind2sub([480 640],(1:480*640)); %compute u and v for every pixel
P=inv(Kd)*[Z.*u ;Z.*v;Z];%world to depth_cam
niu=RGB_cam.K*[R_d_to_rgb T_d_to_rgb]*[P;ones(1,640*480)]; %depth_cam to rgb_cam
u2=round(niu(1,:)./niu(3,:));
v2=round(niu(2,:)./niu(3,:));

im_calib_xyz=zeros(640*480,3);
indsclean=find((u2>=1)&(u2<=641)&(v2>=1)&(v2<=480));
indscolor=sub2ind([480 640],v2(indsclean),u2(indsclean));
im1aux=reshape(im,[640*480 3]);
im_calib_xyz(indsclean,:)=im1aux(indscolor,:); %calibrated im

im_calib = uint8(reshape(im_calib_xyz,[480,640,3]));
P_calib = uint16(reshape(P(3,:),[480,640])*1000);
end

% [im2 im2_xyz P P_xyz] = depth_to_rgb(imread('fruta2/rgb_image1_0011.png'),im1d.depth_array);
% pc=pointCloud(P_xyz', 'color',uint8(im2_xyz));
% figure(1);showPointCloud(pc);