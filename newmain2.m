close all; clear;

%Load images
im1_=imread('lab1/rgb_image1_11.png');
im2_=imread('lab1/rgb_image2_11.png');

im1d = load('lab1/depth1_11.mat');
im2d = load('lab1/depth2_11.mat');

%Calibration depth/rgp
[im1, im1_xyz, P_1, P_xyz_1] = depth_to_rgb(im1_,im1d.depth_array);
[im2, im2_xyz, P_2, P_xyz_2] = depth_to_rgb(im2_,im2d.depth_array);

%Obter point cloud data
im1xyz=reshape(P_xyz_1,[480,640,3]);
im2xyz=reshape(P_xyz_2,[480,640,3]);

%Passar para gray scale
im1=rgb2gray(im1);
im2=rgb2gray(im2);

%Get Features (SIFT)
% f = [X;Y;S;TH], where X,Y is the (fractional) center of the frame, 
%                 S is the scale and TH is the orientation (in radians).
% d = 128-dimensional vector of class UINT8.
[f1, d1] = vl_sift(single(im1));
[f2, d2] = vl_sift(single(im2));

%Show Features
figure(1);
imshow(im1); hold on; plot(f1(1,:), f1(2,:), '*'); hold off;
figure(2);
imshow(im2); hold on; plot(f2(1,:), f2(2,:), '*'); hold off;

%Match Features
%increase third parameter to increase threshold
% match contains the indexes in d1,d2 of the paired points
% sc is the squared Euclidean distance between the matches (score), 
%    the lower, the better
[match, sc] = vl_ubcmatch(d1, d2, 1.8);

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

%Get xyz matches: guardar x, y, z dos matches em xyz
xyzmatchedfeatures1=zeros(length(match), 3);
xyzmatchedfeatures2=zeros(length(match), 3);

%----------------------------------------------------------------------
teste1=zeros(length(match), 3);
teste2=zeros(length(match), 3);
for i = 1:length(match)
   % variavel_teste(i) = im1xyz(round(f1(,match(1,i))), round(f1(,match(2,i))));   
    teste1(i, :, :, :) = im1xyz( round(f1(2,match(1,i))), round(f1(1,match(1,i))));
    teste2(i, :, :, :) = im2xyz( round(f1(2,match(2,i))), round(f1(1,match(2,i))));
    %HERE
    
    xyzmatchedfeatures1(i, 1) = round(f1(1,match(1,i)));
    xyzmatchedfeatures1(i, 2) = round(f1(2,match(1,i)));
    %imagem =/= matriz (por isso trocado)
    xyzmatchedfeatures1(i, 3) = im1d.depth_array(xyzmatchedfeatures1(i,2), xyzmatchedfeatures1(i,1));

    xyzmatchedfeatures2(i, 1) = round(f2(1,match(2,i)));
    xyzmatchedfeatures2(i, 2) = round(f2(2,match(2,i)));
    %imagem =/= matriz (por isso trocado)
    xyzmatchedfeatures2(i, 3) = im2d.depth_array(xyzmatchedfeatures2(i,2), xyzmatchedfeatures2(i,1));
    
    
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
    Centroid1 = round(av1');
    Centroid2 = round(av2');
    
    %Subtract centroids from A,B
    A_menos_centroid = A - horzcat(Centroid1, Centroid1, Centroid1, Centroid1);
    B_menos_centroid = B - horzcat(Centroid2, Centroid2, Centroid2, Centroid2);
    
    [d,Z,tr] = procrustes(B_menos_centroid', A_menos_centroid', 'reflection', false);

    T=Centroid2-tr.T*Centroid1;
    
    %Calculate im2 points from im1 points and calculated model 
    inliers=0;
    
    %B=R*A+T
    R=tr.T;
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
        if (D(i)<0.50)
            inliers=inliers+1;
            %WRONG MUST CORRECT
            %vector_inliers(i,:)=xyzmatchedfeatures1(i,:);
        end
    end
    
    %Save the transformation with the bigger number of inliers
    Rsave(:,:,k)=R;
    Tsave(:,:,k)=T;
    inlierssave(k)=inliers;
end

[Max, index] = max(inlierssave);
Rfinal=Rsave(:,:,index)
Tfinal=Tsave(:,:,index)