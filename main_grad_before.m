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


figure()

for i=1:size(imgs,3)
    %%
    %dar set ao i em debug_on
    %i=60
    
    %Se puserem o debug a 1
    %O gajo vai cuspir 100-300 plots
    %Se só quiserem ver o debug de uma foto, escolham a foto que querem ver pondo o
    % i=num_da_foto
    %E corram só a section dentro do for depois do '%%'
    
    debugg_on=0;
    show_gif_or_images=0; %Gif =0, images=1
     
    if(debugg_on)
        figure()
        imagesc(imgsd(:,:,i));
    end
    
    imdiff=abs(imgsd(:,:,i)-bgdepth)>.3;
    
      if(debugg_on)
        figure()
        imagesc(imdiff);
      end
    
    %max(a,0) poe todos os numeros negativos a zero
    imdiff = max(imdiff-(imgsd(:,:,i)==0),0);
    
    %imagem filtrada por profundidade logica (0/1)
    if(debugg_on)
        figure()
        imagesc(imdiff)
    end
    
    [Gmag, Gdir] = imgradient(imgsd(:,:,i),'prewitt');
    
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
    
    %filtro de ruído por volume (nº de pixeis por classe)
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
    
    boxes = calc_boxes(imgsd(:,:,i),connected2,nclasses)
    
    
    last_frame_connected = connected2;
    %last_frame_boxes = 
   
    
    
    %%
end

%%
