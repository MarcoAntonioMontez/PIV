%%
close all; clear; clc;
format compact

%% Load Images and find Background module
img_folder ='filinha';
[imgs, imgsd, bgdepth, bggray] = backgroundmodule( img_folder,10);
%%
% Bg subtraction for depth (try with gray too)
minimum_pixels = 2000;
se = strel('disk',6);
su = strel('disk',4);

%initialize objects struct array, which will be return at the end
objects.X=[];
objects.Y=[];
objects.Z=[];
objects.id=[];
objects.frames_tracked=[];

old_objects=[];
new_objects=[];


figure()

for frame_num=30:50%size(imgs,3)
    %%
    %dar set ao i em debug_on
    %i=60
    
    %Se puserem o debug a 1
    %O gajo vai cuspir 100-300 plots
    %Se só quiserem ver o debug de uma foto, escolham a foto que querem ver pondo o
    % i=num_da_foto
    %E corram só a section dentro do for depois do '%%'
    
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
    
    %8x3*numclasses
    boxes = calc_boxes(imgsd(:,:,frame_num),connected2,nclasses);
    
    %If objects struct is empty then initiliaze with objects
    
    
    
    if isempty(objects(1).X) && nclasses > 0
        
        
        
        for j=1:nclasses
            index=((j-1)*3);
            box = boxes(:,(index+1):(index+3));
            new_objects(j).X=box(:,1);
            new_objects(j).Y=box(:,2);
            new_objects(j).Z=box(:,3);
            new_objects(j).frames_tracked=[frame_num];
            new_objects(j).center=CenterCube(box);
            new_objects(j).id=j;
            
            objects(j).X=new_objects(j).X;
            objects(j).Y=new_objects(j).Y;
            objects(j).Z=new_objects(j).Z;
            objects(j).frames_tracked=[frame_num];
            objects(j).id=j;
            
        end
            
    else 
        % Falta dar debug dos frames 1 ao 30
         for j=1:nclasses
                index=((j-1)*3);
                box = boxes(:,(index+1):(index+3));
                new_objects(j).X=box(:,1);
                new_objects(j).Y=box(:,2);
                new_objects(j).Z=box(:,3);
                new_objects(j).frames_tracked=[frame_num];
                new_objects(j).center=CenterCube(box);
         end
         
         %Creates hungarian matrix with CostFunction
         M=length(old_objects);
         N=length(new_objects);
         hungarian_matrix=zeros(N,M);
         for i=1:N
            for j=1:M
               hungarian_matrix(i,j) = CostFunction(new_objects(i), old_objects(j));
            end
         end
         hungarian_matrix;
          %Does hungarian matching
         matching = assignmentoptimal(hungarian_matrix);
         
         for i=1:length(matching)
            if matching(i)== 0
                %If new_object is not recognized 
                %(has the lowest hungarian matching and all others objects 
                %were matched), append object to objects
                index=(length(objects)+1);
                new_objects(i).id=index;
                objects(index).id=index;
            else
               new_objects(i).id=old_objects(matching(i)).id; 
            end  
            
             objects = Concatenate(new_objects(i),objects);
         end
         
%          objects =  Concatenate(new_objects(1),objects);
         
         
    end
    boxes
    
 
    old_objects=new_objects;

    
    
    %%
end
objects.frames_tracked

%%
