close all; clear; clc;
format compact

%filinha
for i=1:108 %108
    s1=strcat('filinha/images',num2str(i,'%08.f'),'.jpg');
    s2=strcat('filinha/images',num2str(i,'%08.f'),'.mat');
    imgseq1(i).rgb=[s1];
    imgseq1(i).depth=[s2];
end
load('cameraparametersAsus.mat');
[objects]=track3D_part1(imgseq1, cam_params);

%%
close all; clear; clc;
format compact

%lab1
for i=1:20 %20
    s1_1=strcat('lab1/rgb_image1_',num2str(i),'.png');
    s1_2=strcat('lab1/rgb_image2_',num2str(i),'.png');
    s2_1=strcat('lab1/depth1_',num2str(i),'.mat');
    s2_2=strcat('lab1/depth2_',num2str(i),'.mat');
    imgseq1(i).rgb=[s1_1];
    imgseq1(i).depth=[s2_1];
    imgseq2(i).rgb=[s1_2];
    imgseq2(i).depth=[s2_2];
end

% %data_rgb
% for i=1:25 %25
%     s1_1=strcat('data_rgb/rgb_image1_',num2str(i),'.png');
%     s1_2=strcat('data_rgb/rgb_image2_',num2str(i),'.png');
%     s2_1=strcat('data_rgb/depth1_',num2str(i),'.mat');
%     s2_2=strcat('data_rgb/depth2_',num2str(i),'.mat');
%     imgseq1(i).rgb=[s1_1];
%     imgseq1(i).depth=[s2_1];
%     imgseq2(i).rgb=[s1_2];
%     imgseq2(i).depth=[s2_2];
% end

load('cameraparametersAsus.mat');
[objects, cam2toW]=track3D_part2(imgseq1, imgseq2, cam_params);