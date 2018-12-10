% run('vlfeat-0.9.21/toolbox/vl_setup')
% vl_version verbose
close all; clear;
format compact

im1=rgb2gray(imread('fruta2/rgb_image1_0011.png'));
im2=rgb2gray(imread('fruta2/rgb_image2_0011.png'));

im1d = load('fruta2/depth1_0011.mat');
im2d = load('fruta2/depth2_0011.mat');

%missing script to correct images


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
[match, sc] = vl_ubcmatch(d1, d2, 1.5); %increase third parameter to increase threshold
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
for i = 1:length(match)
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




%Values to calculate centroids
av1x=sum(xyzmatchedfeatures1(:,1))/length(xyzmatchedfeatures1);
av1y=sum(xyzmatchedfeatures1(:,2))/length(xyzmatchedfeatures1);
av1z=sum(xyzmatchedfeatures1(:,3))/length(xyzmatchedfeatures1);
av2x=sum(xyzmatchedfeatures2(:,1))/length(xyzmatchedfeatures2);
av2y=sum(xyzmatchedfeatures2(:,2))/length(xyzmatchedfeatures2);
av2z=sum(xyzmatchedfeatures2(:,3))/length(xyzmatchedfeatures2);




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


    
    %Calc centroids
    Centroid1 = [round(av1x), round(av1y), round(av1z)]';
    Centroid2 = [round(av2x), round(av2y), round(av2z)]';
    
    %Subtract centroids from A,B
    A_menos_centroid = A - horzcat(Centroid1, Centroid1, Centroid1, Centroid1);
    B_menos_centroid = B - horzcat(Centroid2, Centroid2, Centroid2, Centroid2);
    
    [d,Z,tr] = procrustes(A_menos_centroid', B_menos_centroid', 'reflection', false);
    

    %STOP. WAIT A MINUTE
    T=Centroid2-tr.T*Centroid1;
    
    %Calculate im2 points from im1 points and calculated model 
    inliers=0;
    %B=R*A+T
    R=tr.T;
    B_model = R*xyzmatchedfeatures1';
    for i = 1:length(xyzmatchedfeatures1)
        B_model(:,i)=B_model(:,i)+T(:,1);
    end

    %Calculate distances between matched and calculated points
    %Check number of inliers for that transformation
    D=zeros(1, length(xyzmatchedfeatures1));
    l=0;
    for i = 1:length(xyzmatchedfeatures1)
        D(i)=norm(B_model(:,i)'-xyzmatchedfeatures2(i,:));
        if (D(i)<500)
            inliers=inliers+1;
            %WRONG MUST CORRECT
            vector_inliers(i,:)=xyzmatchedfeatures1(i,:);
        end
    end
    
    %Save the transformation with the bigger number of inliers
    Rsave(:,:,k)=R;
    Tsave(:,:,k)=T;
    inlierssave(k)=inliers;
end

[Max, index] = max(inlierssave);
Rfinal=Rsave(:,:,index);
Tfinal=Tsave(:,:,index);
