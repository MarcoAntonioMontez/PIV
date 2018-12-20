function [  ] = PlotImages( object,imgs,xyz_array,rgbd)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for k=1:length(object.frames_tracked)
%     for l=1:length(objects)
        currentFrame=object.frames_tracked(k);
        X=object.X(:,k);
        Y=object.Y(:,k);
        Z=object.Z(:,k);
        center=CenterCube([X,Y,Z]);


    %     figure()
    %     hold all
    % %     image(imgs(:,:,:,currentFrame));
    %     image=rot90(imgs(:,:,:,currentFrame),2);
    %     imagesc(fliplr(image));
    %     set(gca,'YDir','normal')
    % %     plot(center(2),480-center(1),'*','MarkerSize',10);
    %     plot(object.Y(1,k),480-object.X(1,k),'*','MarkerSize',10);
    %     plot(object.Y(2,k),480-object.X(2,k),'*','MarkerSize',10);
    %     plot(object.Y(3,k),480-object.X(3,k),'*','MarkerSize',10);
    %     plot(object.Y(4,k),480-object.X(4,k),'*','MarkerSize',10);
    %     hold off

%         figure()
%         b1=[xyz_array(:,:,currentFrame)];
%         b2=reshape(rgbd(:,:,:,currentFrame),[480*640 3]);
%         pc=pointCloud(b1,'Color',b2);
%         showPointCloud(pc);
        
        hold on;
        a1=[X Y Z];
        a2=uint8([repmat([255,0,0],8,1)]);
        pc1=pointCloud(a1,'Color',a2);
        showPointCloud(pc1,'MarkerSize',50);
        
        plot3([X(1) X(2)],[Y(1) Y(2)],[Z(1) Z(2)],'LineWidth',1,'Color','r')
        plot3([X(1) X(3)],[Y(1) Y(3)],[Z(1) Z(3)],'LineWidth',1,'Color','r')
        plot3([X(2) X(4)],[Y(2) Y(4)],[Z(2) Z(4)],'LineWidth',1,'Color','r')
        plot3([X(3) X(4)],[Y(3) Y(4)],[Z(3) Z(4)],'LineWidth',1,'Color','r')
        
        plot3([X(5) X(6)],[Y(5) Y(6)],[Z(5) Z(6)],'LineWidth',1,'Color','r')
        plot3([X(5) X(7)],[Y(5) Y(7)],[Z(5) Z(7)],'LineWidth',1,'Color','r')
        plot3([X(6) X(8)],[Y(6) Y(8)],[Z(6) Z(8)],'LineWidth',1,'Color','r')
        plot3([X(7) X(8)],[Y(7) Y(8)],[Z(7) Z(8)],'LineWidth',1,'Color','r')
        
        plot3([X(1) X(5)],[Y(1) Y(5)],[Z(1) Z(5)],'LineWidth',1,'Color','r')
        plot3([X(2) X(6)],[Y(2) Y(6)],[Z(2) Z(6)],'LineWidth',1,'Color','r')
        plot3([X(3) X(7)],[Y(3) Y(7)],[Z(3) Z(7)],'LineWidth',1,'Color','r')
        plot3([X(4) X(8)],[Y(4) Y(8)],[Z(4) Z(8)],'LineWidth',1,'Color','r')
%     end
end

