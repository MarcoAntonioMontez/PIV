function [ histograms ] = CalcHistogram( connected, nclasses, rgbImage)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    bins=64;

    img=zeros(480,640,3,'uint8');

    for i=1:nclasses
       ObjectPixel=uint8(connected==i); 
       for j=1:3
           img(:,:,j)=ObjectPixel.*rgbImage(:,:,j);
       end

        Red = img(:,:,1);
        Green = img(:,:,2);
        Blue = img(:,:,3);

        Red(Red==0)=[];
        Green(Green==0)=[];
        Blue(Blue==0)=[];
        

        [yRed] = imhist(Red,bins);
        [yGreen] = imhist(Green,bins);
        [yBlue] = imhist(Blue,bins);

       %Save histograms.img for debug purposes
       histograms(i).img=img;
       
       %Divide by lenght(color) to normalize the number the number of hits
       %in each bin
       histograms(i).hist_red=yRed/length(Red);
       histograms(i).hist_green=yGreen/length(Green);
       histograms(i).hist_blue=yBlue/length(Blue);
    end
    
    if nclasses==0    
        histograms=[];    
    end

end

