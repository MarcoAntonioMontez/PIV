function [ objects ] = track3D_part1( img_name_seq, cam_params)
addpath('P_all_folder','Part1_folder')
[imgs, imgsd] = load_images(img_name_seq);

[imgs, xyz_array, rgbd] = align_depth_to_rgb(imgsd,imgs,cam_params); 

imgsd(:,:,1:size(imgsd,3))=double(imgsd(:,:,1:size(imgsd,3)))/1000;

[bgdepth, bggray] = backgroundmodule(imgs, imgsd);

minimum_pixels = 1500;
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
histograms=[];

cost_treshold=200;
min_frames_object_appears=10;


figure()
close all

for frame_num=40:50 %size(imgs,4)
    
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
    
    imdiff=abs(imgsd(:,:,frame_num)-bgdepth)>0.3;
    
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
    
    logic_grad = Gmag > .4;
    
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
    
    histograms=CalcHistogram(connected2,nclasses,imgs(:,:,:,frame_num));
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
            new_objects(j).histogram=histograms(j);
            % new_objects(j).hist_red=CalcHistogram(connected2.nclasses,imgs(:,:,:,frame_num))
            
            new_objects(j).id=j;
            
            objects(j).X=new_objects(j).X;
            objects(j).Y=new_objects(j).Y;
            objects(j).Z=new_objects(j).Z;
            objects(j).frames_tracked=[frame_num];
            objects(j).id=j;           
        end
    elseif (isempty(old_objects)) && (nclasses > 0)
       
       for j=1:nclasses
            index=((j-1)*3);
            box = boxes(:,(index+1):(index+3));
            new_objects(j).X=box(:,1);
            new_objects(j).Y=box(:,2);
            new_objects(j).Z=box(:,3);
            new_objects(j).frames_tracked=[frame_num];
            new_objects(j).center=CenterCube(box);
            new_objects(j).histogram=histograms(j);
            %Add histogram calculation
            
            
            list_index=(length(objects)+1);
            new_objects(j).id=list_index;
            objects(list_index).id=list_index;
            
            objects = Concatenate(new_objects(j),objects);

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
                new_objects(j).histogram=histograms(j);

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
          %Does hungarian matching
         matching = assignmentoptimal(hungarian_matrix);
         
         %IF cost is bigger than cost_treshold than object is a new one
         for i=1:N
            if min(hungarian_matrix(i,:)) > cost_treshold
               matching(i)=0; 
            end
         end
                  
%          frame_num
%          hungarian_matrix
%          matching
         %To not run the next for
         if (nclasses==0) | (hungarian_matrix==0)
            matching=[];
         end
        

%          length(matching)
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
        old_objects=new_objects;
        new_objects=[];
        histograms=[];
        
        %%
end
end

