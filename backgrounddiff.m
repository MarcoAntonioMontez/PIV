backgroundmodule;
%%
% Bg subtraction for depth (try with gray too)
%for i=length(d)/2,
minimum_pixels = 1000;
se = strel('disk',6);
su = strel('disk',4);

%while(1),
%     for i=1:length(d),
    for i=19:19,
        imdiff=abs(imgsd(:,:,i)-bgdepth)>.20;
        %imdiff=abs(imgs(:,:,i)-bggray)>.20;
        imgdiffiltered=imopen(imdiff,se); %%erosion and dilation
        figure(2);
        imagesc([imdiff imgdiffiltered]);
        title('Difference image and morph filtered');
        colormap(gray);
        figure(3);
        imagesc([imgsd(:,:,i) bgdepth]);
        title('Depth image i and background image');
        figure(4);
        closed_image = imclose(imgdiffiltered, su);
        connected = bwlabel(closed_image);% vamos experimentar aumentar o raio do disco sem "quebrar" o prof        
        %imagesc(bwlabel(imgdiffiltered));
        
        %filtro de ruído por volume (nº de pixeis por classe)
        nclasses = max(connected(:));
        for k=1:nclasses,
            [class_x, class_y] = find(connected==k);
            if( size(class_x) <= minimum_pixels),
                connected(class_x, class_y) = 0;
            end
            clear class_x;
            clear class_y;
        end
        
        %re-ordenar classes
        connected2 = bwlabel(connected);
        nclasses = max(connected(:));
        
        %encontrar os pontos do cubo
        %o que procuramos
        xmin=zeros(nclasses,1);
        xmax=zeros(nclasses,1);
        ymin=zeros(nclasses,1);
        ymax=zeros(nclasses,1);
        zmin=zeros(nclasses,1);
        zmax=zeros(nclasses,1);
               
        for k=1:nclasses,
            [class_x, class_y] = find(connected2 == k);
            class_zone = [class_x, class_y];
            xmin(k)=min(class_x);
            xmax(k)=max(class_x);
            ymin(k)=min(class_y);
            ymax(k)=max(class_y);
            class_depth=zeros(length(class_x),1);
            for L=1:length(class_x),
                class_depth_stub(L)=imgsd(class_zone(L,1), class_zone(L,2),i); 
                if class_depth_stub(L)<0.8,
                    i
                    x=class_zone(L,1)
                    y=class_zone(L,2)
                end
            end
            class_depth=class_depth_stub(class_depth_stub~=0);
            Zmin=min(class_depth);
            Zmax=max(class_depth);
        end
        imagesc(connected);
        title('Connected components');
        pause(0.1);
    end
%end

%%
oi=imgs(174,579,:); %returns 3D array [1 1 M]

hist(squeeze(imgs(174,579,:)),0:255) %that's why we squeeze, 0:255 is number of bars/possible value of pixels
