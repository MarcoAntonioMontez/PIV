function [  ] = PlotImages( object,imgs,xyz_array,rgbd,c)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for k=1:length(object.frames_tracked)
%     for l=1:length(objects)

        X=object.X(:,k);
        Y=object.Y(:,k);
        Z=object.Z(:,k);
        
        hold on;
        a1=[X Y Z];
        a2=uint8([repmat([255,0,0],8,1)]);
        pc1=pointCloud(a1,'Color',a2);
        showPointCloud(pc1,'MarkerSize',10);
        
        plot3([X(1) X(2)],[Y(1) Y(2)],[Z(1) Z(2)],'LineWidth',1,'Color',c)
        plot3([X(1) X(3)],[Y(1) Y(3)],[Z(1) Z(3)],'LineWidth',1,'Color',c)
        plot3([X(2) X(4)],[Y(2) Y(4)],[Z(2) Z(4)],'LineWidth',1,'Color',c)
        plot3([X(3) X(4)],[Y(3) Y(4)],[Z(3) Z(4)],'LineWidth',1,'Color',c)
        
        plot3([X(5) X(6)],[Y(5) Y(6)],[Z(5) Z(6)],'LineWidth',1,'Color',c)
        plot3([X(5) X(7)],[Y(5) Y(7)],[Z(5) Z(7)],'LineWidth',1,'Color',c)
        plot3([X(6) X(8)],[Y(6) Y(8)],[Z(6) Z(8)],'LineWidth',1,'Color',c)
        plot3([X(7) X(8)],[Y(7) Y(8)],[Z(7) Z(8)],'LineWidth',1,'Color',c)
        
        plot3([X(1) X(5)],[Y(1) Y(5)],[Z(1) Z(5)],'LineWidth',1,'Color',c)
        plot3([X(2) X(6)],[Y(2) Y(6)],[Z(2) Z(6)],'LineWidth',1,'Color',c)
        plot3([X(3) X(7)],[Y(3) Y(7)],[Z(3) Z(7)],'LineWidth',1,'Color',c)
        plot3([X(4) X(8)],[Y(4) Y(8)],[Z(4) Z(8)],'LineWidth',1,'Color',c)
%     end
end

