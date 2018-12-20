%%
close all; clear; clc;
format compact

%filinha
for i=1:108 %108
    s1=strcat('filinha/images',num2str(i,'%08.f'),'.jpg');
    s2=strcat('filinha/images',num2str(i,'%08.f'),'.mat');
    imgseq(i).rgb=[s1];
    imgseq(i).depth=[s2];
end
load('cameraparametersAsus.mat');
track3D_part1(imgseq, cam_params);


%%
close all; clear; clc;
format compact

%
for i=1 %20
    s1_1=strcat('lab1/rgb_image1_',num2str(11),'.png');
    s1_2=strcat('lab1/rgb_image2_',num2str(11),'.png');
    s2_1=strcat('lab1/depth1_',num2str(11),'.mat');
    s2_2=strcat('lab1/depth2_',num2str(11),'.mat');
    imgseq1(i).rgb=[s1_1];
    imgseq1(i).depth=[s2_1];
    imgseq2(i).rgb=[s1_2];
    imgseq2(i).depth=[s2_2];
    
end
load('cameraparametersAsus.mat');
track3D_part2(imgseq1, imgseq2, cam_params)