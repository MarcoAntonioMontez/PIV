function [  ] = PlotImages( object,imgs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for k=1:length(object.frames_tracked)
    currentFrame=object.frames_tracked(k);
    X=object.X_cam(:,k);
    Y=object.Y_cam(:,k);
    Z=object.Z_cam(:,k);
    center=CenterCube([X,Y,Z]);
    
    
    figure()
    hold all
%     image(imgs(:,:,:,currentFrame));
    image=rot90(imgs(:,:,:,currentFrame),2);
    imagesc(fliplr(image));
    set(gca,'YDir','normal')
    plot(center(2),480-center(1),'*','MarkerSize',20);
    str = sprintf('Image nº %d ', currentFrame);
    title(str)
    hold off
    
end

