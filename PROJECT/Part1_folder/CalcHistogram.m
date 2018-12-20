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

%         figure()
%         imagesc(img(:,:,j))
        
        hsv=rgb2hsv(img(:,:,:));

        h=img(:,:,1);
        s=img(:,:,2);
        v=img(:,:,3);

        h(h==0)=[];
        s(s==0)=[];
        v(v==0)=[];


        [hist_h] = imhist(h,bins);
        [hist_s] = imhist(s,bins);
        [hist_v] = imhist(v,bins);


%         Red = img(:,:,1);
%         Green = img(:,:,2);
%         Blue = img(:,:,3);
% 
%         Red(Red==0)=[];
%         Green(Green==0)=[];
%         Blue(Blue==0)=[];
% 
% 
%         [yRed] = imhist(Red,bins);
%         [yGreen] = imhist(Green,bins);
%         [yBlue] = imhist(Blue,bins);

        %Save histograms.img for debug purposes
        histograms(i).img=img;

        %Divide by lenght(color) to normalize the number the number of hits
        %in each bin
        %        histograms(i).hist_red=yRed/length(Red);
        %        histograms(i).hist_green=yGreen/length(Green);
        %        histograms(i).hist_blue=yBlue/length(Blue);
        histograms(i).hist_h=hist_h/length(h);
        histograms(i).hist_s=hist_s/length(s);
        histograms(i).hist_v=hist_v/length(v);
    end
    
%     show_hist(histograms);
    
    if nclasses==0    
        histograms=[];    
    end

end

