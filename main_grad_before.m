%%
close all; clear; clc;
format compact

%% Load Images and find Background module
img_folder ='filinha';
[imgs, imgsd, bgdepth, bggray] = backgroundmodule( img_folder,0);
%%
% Bg subtraction for depth (try with gray too)
minimum_pixels = 2000;
se = strel('disk',6);
su = strel('disk',4);

%initialize objects struct array, which will be return at the end
objects.X=[];
objects.Y=[];
objects.Z=[];
objects.frames_tracked=[];


figure()

for frame_num=30:31%size(imgs,3)
    %%
    %dar set ao i em debug_on
    %i=60
    
    %Se puserem o debug a 1
    %O gajo vai cuspir 100-300 plots
    %Se s� quiserem ver o debug de uma foto, escolham a foto que querem ver pondo o
    % i=num_da_foto
    %E corram s� a section dentro do for depois do '%%'
    
    debugg_on=0;
    show_gif_or_images=1; %Gif =0, images=1
     
    if(debugg_on)
        figure()
        imagesc(imgsd(:,:,frame_num));
    end
    
    imdiff=abs(imgsd(:,:,frame_num)-bgdepth)>.3;
    
      if(debugg_on)
        figure()
        imagesc(imdiff);
      end
    
    %max(a,0) poe todos os numeros negativos a zero
    imdiff = max(imdiff-(imgsd(:,:,frame_num)==0),0);
    
    %imagem filtrada por profundidade logica (0/1)
    if(debugg_on)
        figure()
        imagesc(imdiff)
    end
    
    [Gmag, Gdir] = imgradient(imgsd(:,:,frame_num),'prewitt');
    
    logic_grad = Gmag > .5;
    
    if(debugg_on)
        figure()
        imagesc(logic_grad)
    end
    %imshowpair(logic_grad, Gdir, 'montage');
    
    filtered_img=max(imdiff - logic_grad,0);
    
    if(debugg_on)
        figure()
        imagesc(filtered_img)
    end
   
    
    %imdiff=abs(imgs(:,:,i)-bggray)>.20;
%     imgdiffiltered=imopen(Gmag,se); %%erosion and dilation
%     %         figure(1);
%     %         imagesc([imdiff imgdiffiltered]);
%     %         title('Difference image and morph filtered');
%     %         colormap(gray);
%     %         figure(2);
%     %         imagesc([imgsd(:,:,i) bgdepth]);
%     %         title('Depth image i and background image');
%     closed_image = imclose(imgdiffiltered, su);
%     [Gmag, Gdir] = imgradient(closed_image,'prewitt');
%         
%     %
% 
% %     figure()
% %     imshowpair(Gmag, Gdir, 'montage');
%     %         figure(3);
%     %         imagesc([imgdiffiltered closed_image]);
    connected = bwlabel(filtered_img); %8-connected
    %vamos experimentar aumentar o raio do disco sem "quebrar" o prof
    
    %filtro de ru�do por volume (n� de pixeis por classe)
    nclasses = max(connected(:));
       
        %Elimina os conjuntos menores que minimum_pixels     
     for k=1:nclasses
        [class_x, class_y] = find(connected==k);
        if( size(class_x,1) <= minimum_pixels)
            for x=1:length(class_x)
                connected(class_x(x), class_y(x)) = 0;
            end
        end
     end
    
        
    %re-ordenar classes
    connected2 = bwlabel(connected);
    nclasses = max(connected2(:));
    
    if(debugg_on | show_gif_or_images )
        figure()
        imagesc(connected2)
    end
    
    if(~debugg_on & ~show_gif_or_images)
        drawnow
        imagesc(connected2)
    end
    
    %8x3*numclasses
    boxes = calc_boxes(imgsd(:,:,frame_num),connected2,nclasses)
    
    %If objects struct is empty then initiliaze with objects
    if isempty(objects(1).X) && nclasses > 0
        prev_object_centers=[]
        for j=1:nclasses
            index=((j-1)*3);
            objects(j).X=boxes(1:8,index+1);
            objects(j).Y=boxes(1:8,index+2);
            objects(j).Z=boxes(1:8,index+3);
            objects(j).frames_tracked=[frame_num];
            
            %id of ovject plus center of cube coordinates
            prev_object_centers(j,:)=[j CenterCube(boxes(1:8,index+1:index+3))]
        end
    else
        hungarian_matrix = zeros(prev_nclasses,nclasses);
              %confusao do crl
        for j=1:prev_nclasses
            prev_center=prev_object_centers(j,2:4);         
            %hungarian_matrix(j,:)=
            Distance_to_prev_objects(prev_center,prev_object_centers(:,2:end))
        end
        hungarian_matrix
        
    end
    
    %Create hungaria matrix
    %%%dist_a
    %a
    %b
    %c
    
    
    
    prev_nclasses=nclasses;
    last_frame_connected = connected2;
    last_frame_boxes = boxes; 
   
    
    
    %%
end

%%
