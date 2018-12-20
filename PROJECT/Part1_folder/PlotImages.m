function [  ] = PlotImages( object,imgs,xyz_array,rgbd)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for k=1:length(object.frames_tracked)
    currentFrame=object.frames_tracked(k);
    X=object.X(:,k);
    Y=object.Y(:,k);
    Z=object.Z(:,k);
    center=CenterCube([X,Y,Z]);
    
    
    figure()
    hold all
%     image(imgs(:,:,:,currentFrame));
    image=rot90(imgs(:,:,:,currentFrame),2);
    imagesc(fliplr(image));
    set(gca,'YDir','normal')
%     plot(center(2),480-center(1),'*','MarkerSize',10);
    plot(object.Y(1,k),480-object.X(1,k),'*','MarkerSize',10);
    plot(object.Y(2,k),480-object.X(2,k),'*','MarkerSize',10);
    plot(object.Y(3,k),480-object.X(3,k),'*','MarkerSize',10);
    plot(object.Y(4,k),480-object.X(4,k),'*','MarkerSize',10);
    hold off
    
    figure()
    a1=[X Y Z];
    b1=[xyz_array(:,:,currentFrame)];
    c1=[b1; a1];
    a2=[repmat([255,0,0],8,1)];
    b2=reshape(rgbd(:,:,:,currentFrame),[480*640 3]);
    c2=[b2; a2];
    pc=pointCloud(c1,'Color',c2);
    showPointCloud(pc);
end

