function [imgs, imgsd] = load_images( d, dd )

imgs=zeros(480,640,length(d));
imgsd=zeros(480,640,length(d));

for i=1:length(d),
    imgs(:,:,i)=rgb2gray(imread(d(i).name));
    load(dd(i).name);
    imgsd(:,:,i)=double(depth_array)/1000;
    %colormap(gray);
end

end


