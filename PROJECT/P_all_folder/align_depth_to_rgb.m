function [rgb_imgs, xyz_depth, rgbd] = align_depth_to_rgb(depth_imgs,rgb_imgs,cam_params)
% cam_params.Kdepth  - the 3x3 matrix for the intrinsic parameters for depth
% cam_params.Krgb - the 3x3 matrix for the intrinsic parameters for rgb
% cam_params.R - the Rotation matrix from depth to RGB (extrinsic params)
% cam_params.T - The translation from depth to RGB 

    for i = 1:size(depth_imgs,3)
        Z=depth_imgs(:,:,i);
        x_len=size(rgb_imgs(:,:,:,i),1);
        y_len=size(rgb_imgs(:,:,:,i),2);
        xyz_depth(:,:,i) = get_xyzasus(Z(:), size(rgb_imgs(:,:,:,i)), 1:(x_len*y_len), cam_params.Kdepth, 1, 0);
        rgbd(:,:,:,i) = get_rgbd(xyz_depth(:,:,i), rgb_imgs(:,:,:,i), cam_params.R, cam_params.T, cam_params.Krgb);
         
%         [im_rgb_calib, ~, ~, ~] = depth_to_rgb(rgb_imgs(:,:,:,i),Z);
%         rgb_imgs(:,:,:,i)=im_rgb_calib;

%         xyz_depth_in_rgb = cam_params.Krgb*[cam_params.R cam_params.T]*[xyz_depth;ones(1,640*480)];
%         depth_align_imgs(:,:,i) = zeros(x_len,y_len);
%         for n = 1:size(xyz_depth_in_rgb,2)
%             u = round( Kx * ( xyz_depth_in_rgb(1,n)/xyz_depth_in_rgb(3,n) ) + Cx);
%             v = round( Ky * ( xyz_depth_in_rgb(2,n)/xyz_depth_in_rgb(3,n) ) + Cy);
%             if(u>1 && (u<y_len) && v>1 && (v<x_len) )
%                 depth_align_imgs(v,u,i) = xyz_depth_in_rgb(3,n);
%             end
%         end
%         xyz_imgs(:,:,:,i) = get_xyz(depth_align_imgs{i}(:), im_size, 1:(im_size(1,1)*im_size(1,2)), K_rgb, 1, 0);
    end
end