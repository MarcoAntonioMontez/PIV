%%
close all; clear; clc;
format compact

%% Load Images and find Background module
img_folder = 'um';
[imgs, imgsd, bgdepth, bggray] = backgroundmodule( img_folder);
%%
% Bg subtraction for depth (try with gray too)
%for i=length(d)/2,
minimum_pixels = 1000;
se = strel('disk',6);
su = strel('disk',4);


for i=1:size(imgs,3),
    imdiff=abs(imgsd(:,:,i)-bgdepth)>.2;
    %20cm margin for kinnect error. But wait! Kinnect doesn't work in black
    %objects (might say something's moving when it's not), also for contours
    %and transitions
    
    %imdiff=abs(imgs(:,:,i)-bggray)>.20;
    imgdiffiltered=imopen(imdiff,se); %%erosion and dilation
    %         figure(1);
    %         imagesc([imdiff imgdiffiltered]);
    %         title('Difference image and morph filtered');
    %         colormap(gray);
    %         figure(2);
    %         imagesc([imgsd(:,:,i) bgdepth]);
    %         title('Depth image i and background image');
    closed_image = imclose(imgdiffiltered, su);
    [Gmag, Gdir] = imgradient(closed_image,'prewitt');
    
    %

    figure()
    imshowpair(Gmag, Gdir, 'montage');
    %         figure(3);
    %         imagesc([imgdiffiltered closed_image]);
    connected = bwlabel(closed_image); %8-connected
    %vamos experimentar aumentar o raio do disco sem "quebrar" o prof
    
    %filtro de ruído por volume (nº de pixeis por classe)
    nclasses = max(connected(:));
    
    
    
    for k=1:nclasses,
        [class_x, class_y] = find(connected==k);
        if( size(class_x,1) <= minimum_pixels),
            connected(class_x, class_y) = 0;
        end
        clear class_x;
        clear class_y;
    end
    
    %re-ordenar classes
    connected2 = bwlabel(connected);
    nclasses = max(connected2(:));
    
    %encontrar os pontos do cubo
    %o que procuramos
    xmin=zeros(nclasses,1);
    xmax=zeros(nclasses,1);
    ymin=zeros(nclasses,1);
    ymax=zeros(nclasses,1);
    zmin=zeros(nclasses,1);
    zmax=zeros(nclasses,1);
    
    figure()
    imagesc(connected2);
    hold on
    for k=1:nclasses,
        [class_x, class_y] = find(connected2 == k);
        class_zone = [class_x, class_y];
        xmin(k)=min(class_x);
        xmax(k)=max(class_x);
        ymin(k)=min(class_y);
        ymax(k)=max(class_y);
%         class_depth=zeros(length(class_x),1);
        for L=1:length(class_x)
            class_depth_stub(L)=imgsd(class_zone(L,1), class_zone(L,2),i);
            if class_depth_stub(L)<0.8
%                 i
                x_zone=class_zone(L,1);
                y_zone=class_zone(L,2);
            end
        end
        class_depth=class_depth_stub(class_depth_stub~=0);
        Zmin=min(class_depth);
        Zmax=max(class_depth);
        
%         [minValue_x, maxValue_x, minValue_y, maxValue_y, minValue_z, maxValue_z] = boxplot( class_x, class_y, class_depth); 
%         line([minValue_y maxValue_y],[minValue_x minValue_x],'Color','red')
%         line([minValue_y maxValue_y],[maxValue_x maxValue_x],'Color','red')
%         line([minValue_y minValue_y],[minValue_x maxValue_x],'Color','red')
%         line([maxValue_y maxValue_y],[minValue_x maxValue_x],'Color','red')
    end
    %         imagesc(connected);
    %         title('Connected components');
    
    pause(0.1);
end
%%
