function [im2 P] = depth_to_rgb(im,depth_array)
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

im2=zeros(640*480,3);
indsclean=find((u2>=1)&(u2<=641)&(v2>=1)&(v2<=480));
indscolor=sub2ind([480 640],v2(indsclean),u2(indsclean));
im1aux=reshape(im,[640*480 3]);
im2(indsclean,:)=im1aux(indscolor,:); %calibrated im

im2 = uint8(reshape(im2,[480,640,3]));
P = uint16(reshape(P(3,:),[480,640]));
end