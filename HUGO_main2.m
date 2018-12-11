% run('vlfeat-0.9.21/toolbox/vl_setup')
% vl_version verbose
close all; clear;
format compact

im1_=imread('lab1/rgb_image1_11.png');
im2_=imread('lab1/rgb_image2_11.png');

im1d = load('lab1/depth1_11.mat');
im2d = load('lab1/depth2_11.mat');

%Calibration depth/rgp
[im1, im1_xyz, P_1, P_xyz_1] = depth_to_rgb(im1_,im1d.depth_array);
[im2, im2_xyz, P_2, P_xyz_2] = depth_to_rgb(im2_,im2d.depth_array);

im1d.depth_array = double(im1d.depth_array)/1000;
im2d.depth_array = double(im2d.depth_array)/1000;

%im1xyz is "image in 3D"
im1xyz(:,:,1)=reshape(P_xyz_1(1,:),[480,640]); %World x
im1xyz(:,:,2)=reshape(P_xyz_1(2,:),[480,640]); %World y
im1xyz(:,:,3)=reshape(P_xyz_1(3,:),[480,640]); %World z
%imshow(im1xyz) %imshow(rgb2gray(im1xyz))

%im2xyz is "image in 3D"
im2xyz(:,:,1)=reshape(P_xyz_2(1,:),[480,640]); %World x
im2xyz(:,:,2)=reshape(P_xyz_2(2,:),[480,640]); %World y
im2xyz(:,:,3)=reshape(P_xyz_2(3,:),[480,640]); %World z
% imshow(im2xyz) %imshow(rgb2gray(im2xyz))

im1=rgb2gray(im1);
im2=rgb2gray(im2);

%Get Features
[f1, d1] = vl_sift(single(im1));
[f2, d2] = vl_sift(single(im2));
% f = [X;Y;S;TH], where X,Y is the (fractional) center of the frame, 
%                 S is the scale and TH is the orientation (in radians).
% d = 128-dimensional vector of class UINT8.

%Get all feature points;
%Show Features
figure(1);
imshow(im1); hold on; plot(f1(1,:), f1(2,:), '*'); hold off;
figure(2);
imshow(im2); hold on; plot(f2(1,:), f2(2,:), '*'); hold off;

%Match Features
[match, sc] = vl_ubcmatch(d1, d2, 1.8); %increase third parameter to increase threshold
% match contains the indexes in d1,d2 of the paired points
% sc is the squared Euclidean distance between the matches (score), 
%    the lower, the better

%Show matching
figure(3); clf ;
imshow(cat(2, im1,im2));
xa = f1(1,match(1,:)) ;
xb = f2(1,match(2,:)) + size(im1,2) ;
ya = f1(2,match(1,:)) ;
yb = f2(2,match(2,:)) ;

hold on ;
h = line([xa ; xb], [ya ; yb]) ;
set(h,'linewidth', 1, 'color', 'b') ;
f1plot=f1;
f2plot=f2;
vl_plotframe(f1plot(:,match(1,:)));
f2plot(1,:) = f2plot(1,:) + size(im1,2) ;
vl_plotframe(f2plot(:,match(2,:)));
axis image off ;


%Get xyz matches
xyzmatchedfeatures1=zeros(length(match), 3);
xyzmatchedfeatures2=zeros(length(match), 3);

teste1=zeros(length(match), 3);
teste2=zeros(length(match), 3);
for i = 1:length(match) 
    teste1(i,:) = im1xyz( round(f1(2,match(1,i))), round(f1(1,match(1,i))),:);
    teste2(i,:) = im2xyz( round(f2(2,match(2,i))), round(f2(1,match(2,i))),:);
    
    xyzmatchedfeatures1(i, 1) = teste1(i,1);
    xyzmatchedfeatures1(i, 2) = teste1(i,2);
    %imagem =/= matriz (por isso trocado)
    xyzmatchedfeatures1(i, 3) = teste1(i,3);

    xyzmatchedfeatures2(i, 1) = teste2(i,1);
    xyzmatchedfeatures2(i, 2) = teste2(i,2);
    %imagem =/= matriz (por isso trocado)
    xyzmatchedfeatures2(i, 3) = teste2(i,3);
    
    
    %Vamos mandar fora pontos com 0 (kinect poe 0 quando nao consegue ler)
    %Aqui se encontrar um zero ponho toda a linha a zero
    if ismember(0, xyzmatchedfeatures1(i, :)) || ismember(0, xyzmatchedfeatures2(i, :))
        xyzmatchedfeatures2(i,:) = [];
        xyzmatchedfeatures1(i,:) = [];
        
    end   
end
%Mandar fora linhas de zeros
xyzmatchedfeatures2 = xyzmatchedfeatures2(any(xyzmatchedfeatures2,2),:);
xyzmatchedfeatures1 = xyzmatchedfeatures1(any(xyzmatchedfeatures1,2),:);

%Ransac
%Choose randomly 4 pairs of points

Rsave=zeros(3,3,30);
Tsave=zeros(3,1,30);
inlierssave=zeros(1,30);

for k=1:60
    %1st random pair
    xyzpair1 = zeros(2,3);

    while(ismember(0, xyzpair1))
        random1 = round(rand*length(xyzmatchedfeatures2));
        if random1==0
            random1=1;
        end
        xyzpair1 = vertcat(xyzmatchedfeatures1(random1,:), xyzmatchedfeatures2(random1,:));
    end

    xyzpair2 = zeros(2,3);

    while(ismember(0, xyzpair2))
        random2 = round(rand*length(xyzmatchedfeatures2));
        if random2==0
            random2=1;
        end
        xyzpair2 = vertcat(xyzmatchedfeatures1(random2,:), xyzmatchedfeatures2(random2,:));
    end

    xyzpair3 = zeros(2,3);

    while(ismember(0, xyzpair3))
        random3 = round(rand*length(xyzmatchedfeatures2));
        if random3==0
            random3=1;
        end
        xyzpair3 = vertcat(xyzmatchedfeatures1(random3,:), xyzmatchedfeatures2(random3,:));
    end

    xyzpair4 = zeros(2,3);

    while(ismember(0, xyzpair4))
        random4 = round(rand*length(xyzmatchedfeatures2));
        if random4==0
            random4=1;
        end
       xyzpair4 = vertcat(xyzmatchedfeatures1(random4,:), xyzmatchedfeatures2(random4,:));
    end

    %Estimate transformation
    A = [xyzpair1(1,:)', xyzpair2(1,:)', xyzpair3(1,:)', xyzpair4(1,:)'];
    B = [xyzpair1(2,:)', xyzpair2(2,:)', xyzpair3(2,:)', xyzpair4(2,:)'];
    
    %Values to calculate centroids
    av1=mean(A');
    av2=mean(B');
   
    
    %Calc centroids
    Centroid1 = av1';
    Centroid2 = av2';
    
    %Subtract centroids from A,B
    A_menos_centroid = A - horzcat(Centroid1, Centroid1, Centroid1, Centroid1);
    B_menos_centroid = B - horzcat(Centroid2, Centroid2, Centroid2, Centroid2);
    
%     [d,Z,tr] = procrustes(B_menos_centroid', A_menos_centroid', 'reflection', false);
%     T=Centroid2-tr.T*Centroid1;
    
    M1 = A_menos_centroid*B_menos_centroid';
    [U,S,V] = svd(M1);
    Mdiagonal = ones(size(U',1),1);
    Mdiagonal(size(U',1),1) = det(V*U');
    R = V * (diag(Mdiagonal)) * U';
    T=Centroid2-R*Centroid1;

    %Calculate im2 points from im1 points and calculated model 
    inliers=0;
    
    %B=R*A+T
%     R=tr.T;
    B_model = R*xyzmatchedfeatures1';
    for i = 1:length(xyzmatchedfeatures1)
        B_model(:,i)=B_model(:,i)+T(:);
    end

    %Calculate distances between matched and calculated points
    %Check number of inliers for that transformation
    D=zeros(1, length(xyzmatchedfeatures1));
    l=0;
    for i = 1:length(xyzmatchedfeatures1)
        D(i)=norm(B_model(:,i)'-xyzmatchedfeatures2(i,:));
        if (D(i)<0.05)
            inliers=inliers+1;
            %WRONG MUST CORRECT
            vector1_inliers(i,:,k)=xyzmatchedfeatures1(i,:);
            vector2_inliers(i,:,k)=xyzmatchedfeatures2(i,:);
        end
    end
    
    %Save the transformation with the bigger number of inliers
    Rsave(:,:,k)=R;
    Tsave(:,:,k)=T;
    inlierssave(k)=inliers;
end

[Max, index] = max(inlierssave)
Rfinal=Rsave(:,:,index);
Tfinal=Tsave(:,:,index);

aux1 = vector1_inliers(:,:,index);
aux2 = vector2_inliers(:,:,index);
A_ = aux1(any(aux1,2),:)';
B_ = aux2(any(aux2,2),:)';
av1_=mean(A_');
av2_=mean(B_');

%Calc centroids
Centroid1_ = av1_';
Centroid2_ = av2_';

%Subtract centroids from A,B
A_menos_centroid_ = A_ - repmat(Centroid1_,1,Max);
B_menos_centroid_ = B_ - repmat(Centroid2_,1,Max);

M1 = A_menos_centroid_*B_menos_centroid_';
[U,S,V] = svd(M1);
Mdiagonal = ones(size(U',1),1);
Mdiagonal(size(U',1),1) = det(V*U');
R_ = V * (diag(Mdiagonal)) * U';
T_=Centroid2_-R_*Centroid1_;

P_xyz_1_em_2 = R_*P_xyz_1 + repmat(T_,1,480*640);

x = [];
y = [];
z = [];
r = [];
g = [];
b = [];
xyz_images_t = [P_xyz_1_em_2, P_xyz_2];
cl = [im1_xyz', im2_xyz'];

x=[x;xyz_images_t(1,:)];
y=[y;xyz_images_t(2,:)];
z=[z;xyz_images_t(3,:)];
r=[r;cl(1,:)];
g=[g;cl(2,:)];
b=[b;cl(3,:)];
% r=double(r);
% g=double(g);
% b=double(b);

pxyz = [x;y;z];
prgb = [r;g;b]';

pc=pointCloud(pxyz','Color',uint8(prgb));
figure(4);showPointCloud(pc);