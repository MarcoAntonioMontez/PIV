function [imgs, imgsd] = load_images( d, dd )

imgs=zeros(480,640,length(d)); %create an array of rgb
imgsd=zeros(480,640,length(d)); %create an array of depth

for i=1:length(d),
    imgs(:,:,i)=rgb2gray(imread(d(i).name)); %convert to gray a column 
                                             %image you read from the file
    load(dd(i).name);
    imgsd(:,:,i)=double(depth_array)/1000;
    %colormap(gray);
end

end

