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

%filinha
for i=1:108 %108
    s1=strcat('filinha/images',num2str(i,'%08.f'),'.jpg');
    s2=strcat('filinha/images',num2str(i,'%08.f'),'.mat');
    imgseq(i).rgb=[s1];
    imgseq(i).depth=[s2];
end
load('cameraparametersAsus.mat');
track3D_part1(imgseq, cam_params)