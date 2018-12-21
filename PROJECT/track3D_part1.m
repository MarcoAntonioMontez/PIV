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

cost_treshold=2; %30 for distance, 20 for hue
min_frames_object_appears=1;

for frame_num=1:size(imgs,4)
    %%
    %ebug a 1 para ver os plots
    
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
    
    %     if(debugg_on | show_gif_or_images )
    %         figure()
    %         imagesc(connected2)
    %     end
    %
    %     if(~debugg_on & ~show_gif_or_images)
    %         drawnow
    %         imagesc(connected2)
    %     end
    
    %calculates box in world coordinates
    boxes = calc_boxes(imgsd(:,:,frame_num),connected2,nclasses);
    
    %calculates box in cam coordinates
    cam_boxes =calc_cam_boxes(imgsd(:,:,frame_num),connected2,nclasses);
    %Calcular xyz points...
    
    %Calculates Histograms
    histograms=CalcHistogram(connected2,nclasses,imgs(:,:,:,frame_num));
    
    
    %If objects struct is empty then initiliaze with objects
    if isempty(objects(1).X) && nclasses > 0
        for j=1:nclasses
            index=((j-1)*3);
            %world boxes
            box = boxes(:,(index+1):(index+3));
            new_objects(j).X=box(:,1);
            new_objects(j).Y=box(:,2);
            new_objects(j).Z=box(:,3);
            
            %cam boxes
            cam_box = cam_boxes(:,(index+1):(index+3));
            new_objects(j).X_cam=cam_box(:,1);
            new_objects(j).Y_cam=cam_box(:,2);
            new_objects(j).Z_cam=cam_box(:,3);
            
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
            objects(j).histogram=histograms(j);
            
            
            %Save cam boxes
            objects(j).X_cam=new_objects(j).X_cam;
            objects(j).Y_cam=new_objects(j).Y_cam;
            objects(j).Z_cam=new_objects(j).Z_cam;
            
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
            
            %cam boxes
            cam_box = cam_boxes(:,(index+1):(index+3));
            new_objects(j).X_cam=cam_box(:,1);
            new_objects(j).Y_cam=cam_box(:,2);
            new_objects(j).Z_cam=cam_box(:,3);
            
            
            list_index=(length(objects)+1);
            new_objects(j).id=list_index;
            objects(list_index).id=list_index;
            
            objects = Concatenate(new_objects(j),objects);
            
        end
        
    else
        for j=1:nclasses
            index=((j-1)*3);
            box = boxes(:,(index+1):(index+3));
            new_objects(j).X=box(:,1);
            new_objects(j).Y=box(:,2);
            new_objects(j).Z=box(:,3);
            new_objects(j).frames_tracked=[frame_num];
            new_objects(j).center=CenterCube(box);
            new_objects(j).histogram=histograms(j);
            
            %cam boxes
            cam_box = cam_boxes(:,(index+1):(index+3));
            new_objects(j).X_cam=cam_box(:,1);
            new_objects(j).Y_cam=cam_box(:,2);
            new_objects(j).Z_cam=cam_box(:,3);
            
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
    
end

% Reject objects that only appear in less than min_frames_object_appears
for i=length(objects):-1:1
    if length(objects(i).frames_tracked)<min_frames_object_appears
        objects(i)=[];
    end
end

% figure()
% b1=[xyz_array(:,:,1)];
% b2=reshape(rgbd(:,:,:,1),[480*640 3]);
% pc=pointCloud(b1,'Color',b2);
% showPointCloud(pc);
% PlotImages(objects(2),imgs,xyz_array,rgbd,'r');
% objects.frames_tracked;

for i=1:length(objects)
    objects(i).X=objects(i).X';
    objects(i).Y=objects(i).Y';
    objects(i).Z=objects(i).Z';
end
end
