function [ objects, cam2toW ] = track3D_part2( img_name_seq1, img_name_seq2, cam_params)
addpath('P_all_folder','Part2_folder')
[imgs1, imgsd1] = load_images(img_name_seq1);
[imgs2, imgsd2] = load_images(img_name_seq2);
[imgs1, depth_align_imgs1, xyz_imgs1] = align_depth_to_rgb(imgsd1,imgs1,cam_params);
[imgs2, depth_align_imgs2, xyz_imgs2] = align_depth_to_rgb(imgsd2,imgs2,cam_params); 

