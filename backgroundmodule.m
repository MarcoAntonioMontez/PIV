cd um;
d=dir('*.jpg');
dd=dir('*.mat');

%load images rgb2gray and depth into workspace
[imgs, imgsd]=load_images(d, dd);

cd ..;

%calculate background
bgdepth=median(imgsd,3);
bggray=median(imgs,3);
figure;
imagesc(bgdepth);
figure;
colormap(gray);
imagesc(bggray);
%
