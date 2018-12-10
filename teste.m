% img_folder ='filinha';
% main_folder = pwd;
% cd(img_folder);
% d=dir('*.jpg');
% cd(main_folder)
% 
% imgs=zeros(480,640,3,'uint8');
% 
% i=1;
% 
% %uint8
%  [img, map]=imread('images00000001.jpg'); 
%  imgs(:,:,:)=imread('images00000001.jpg'); 
%  img=imgs(:,:,:,i);
% figure()
% image(img(1:100,1:100,:))
bins=64;

i=75;
rgbImage=imgs(:,:,:,i);
figure()
image(rgbImage)

images = CalcHistogram( connected2, nclasses, rgbImage);

for n=1:length(images)
    figure()
    hold all
    subplot(2,2,1);
    bar(images(n).hist_red)

    subplot(2,2,2);
    bar(images(n).hist_green)

    subplot(2,2,3);
    bar(images(n).hist_blue)

    subplot(2,2,4);
    image(images(n).img)
    hold off
end
    hist1=images(n).hist_red;
    hist2=images(n-1).hist_red;
    
    

       f1 = hist1';
       f2 = hist2';
       w1 = 1;
       w2 = 1;
       [x fval] = emd(f1, f2, w1, w2, @gdf);
       fval*100



% figure()
% image(rgbImage)



% for n=1:10
%   images{n} = imread(sprintf('image%03d.png',n));
% end