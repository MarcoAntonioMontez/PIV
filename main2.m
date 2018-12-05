% run('vlfeat-0.9.21/toolbox/vl_setup')
% vl_version verbose
close all; clear;
format compact

im1=rgb2gray(imread('fruta2/rgb_image1_0011.png'));
im2=rgb2gray(imread('fruta2/rgb_image2_0011.png'));

im1d = load('fruta2/depth1_0011.mat');
im2d = load('fruta2/depth2_0011.mat');


%Get Features
[f1, d1] = vl_sift(single(im1));
[f2, d2] = vl_sift(single(im2));

% f = [X;Y;S;TH], where X,Y is the (fractional) center of the frame, 
%                 S is the scale and TH is the orientation (in radians).
% d = 128-dimensional vector of class UINT8.

%get all feature points
length_f1=length(f1);
length_f2=length(f2);



%Values to calculate centroids
avf1x=sum(f1(1,:))/length_f1;
avf1y=sum(f1(2,:))/length_f1;
avf2x=sum(f2(1,:))/length_f2;
avf2y=sum(f2(2,:))/length_f2;

acum1=double(0);
for i = 1:length_f1
    x=round(f1(1,i));
    y=round(f1(2,i));
    
    acum1=acum1+double(im1d.depth_array(y,x));
end
avf1z=acum1/length_f1;

acum2=double(0);
for i = 1:length_f2
    x=fix(f2(1,i));
    y=fix(f2(2,i));
    
    acum2=acum2+double(im2d.depth_array(y,x));
end
avf2z=acum2/length_f2;

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


%Ransac
%Choose randomly 4 pairs of points

%getting x,y points from matches --> from f1, f2
%account for matlab switching stuff

Rsave=zeros(3,3,30);
Tsave=zeros(3,1,30);
inlierssave=zeros(1,30);

for k=1:60
    %1st random pair
    xyzpair1 = zeros(3,2);

    while(ismember(0, xyzpair1))
        random1 = round(rand*length(match));
        if random1==0
            random1=1;
        end
        pair1 = match(:, random1);
        f1temp = f1(:,pair1(1));
        f2temp = f2(:,pair1(2));
        xypair1 = [round(f2temp(1:2)), round(f1temp(1:2))];  %dealt with matlab shit
        xyzpair1 = vertcat(xypair1, horzcat(im1d.depth_array( xypair1(2,1), xypair1(1,1)), im2d.depth_array(xypair1(2,2), xypair1(1,2))));
    end

    xyzpair2 = zeros(3,2);

    while(ismember(0, xyzpair2))
        random2 = round(rand*length(match));
        if random2==0
            random2=1;
        end
        pair2 = match(:, random2);
        %2nd random pair
        f1temp = f1(:,pair2(1));
        f2temp = f2(:,pair2(2));
        xypair2 = [round(f2temp(1:2)), round(f1temp(1:2))];  %dealt with matlab shit

        xyzpair2 = vertcat(xypair2, horzcat(im1d.depth_array(xypair2(2,1), xypair2(1,1)), im2d.depth_array(xypair2(2,2), xypair2(1,2))));
    end

    xyzpair3 = zeros(3,2);

    while(ismember(0, xyzpair3))
        random3 = round(rand*length(match));
        if random3==0
            random3=1;
        end
        pair3 = match(:, random3);
        %3rd random pair
        f1temp = f1(:,pair3(1));
        f2temp = f2(:,pair3(2));
        xypair3 = [round(f2temp(1:2)), round(f1temp(1:2))]; %dealt with matlab shit

        xyzpair3 = vertcat(xypair3, horzcat(im1d.depth_array(xypair3(2,1), xypair3(1,1)), im2d.depth_array(xypair3(2,2), xypair3(1,2))));
    end

    xyzpair4 = zeros(3,2);

    while(ismember(0, xyzpair4))
        random4 = round(rand*length(match));
        if random4==0
            random4=1;
        end
        pair4 = match(:, random4);
        %4th random pair
        f1temp = f1(:,pair4(1));
        f2temp = f2(:,pair4(2));
        xypair4 = [round(f2temp(1:2)), round(f1temp(1:2))]; %dealt with matlab shit

        xyzpair4 = vertcat(xypair4, horzcat(im1d.depth_array(xypair4(2,1), xypair4(1,1)), im2d.depth_array(xypair4(2,2), xypair4(1,2))));
    end

    %Estimate transformation
    n=4;
    format long;
    A = [xyzpair1(:,1), xyzpair2(:,1), xyzpair3(:,1), xyzpair4(:,1)];
    B = [xyzpair1(:,2), xyzpair2(:,2), xyzpair3(:,2), xyzpair4(:,2)];

    A_linha=A';
    B_linha=B';


    %solution for translation
    T = [round(avf2x-avf1x); round(avf2y-avf1y); round(avf2z-avf1z)];  %this gives out the Translation

    %plug translation
    B_menos_T = double(B_linha) - double([T T T T]');
    [d,Z,tr] = procrustes(double(B_menos_T), double(A_linha), 'reflection', false);

    %Get xyz matches
    xyzmatchedfeatures1=zeros(3, length(match));
    xyzmatchedfeatures2=zeros(3, length(match));
    for i = 1:length(match)
        xyzmatchedfeatures1(1,i) = ceil(f1(1,match(1,i)));
        xyzmatchedfeatures1(2,i) = ceil(f1(2,match(1,i)));
        xyzmatchedfeatures1(3,i) = im1d.depth_array(xyzmatchedfeatures1(2,i), xyzmatchedfeatures1(1,i));


        xyzmatchedfeatures2(1,i) = round(f2(1,match(2,i)));
        xyzmatchedfeatures2(2,i) = round(f2(2,match(2,i)));
        xyzmatchedfeatures2(3,i) = im2d.depth_array(xyzmatchedfeatures2(2,i), xyzmatchedfeatures2(1,i));
    end

    %Calculate im2 points from im1 points and calculated model 
    inliers=0;
    %B=R*A+T
    R=tr.T;
    B_model = double(R)*double(xyzmatchedfeatures1);
    for i = 1:length(match)
        B_model(:,i)=B_model(:,i)+T(:,1);
    end

    %Calculate distances between matched and calculated points
    %Check number of inliers for that transformation
    D=zeros(1, length(match));
    for i = 1:length(match)
        D(i)=norm(B_model(:,i)-xyzmatchedfeatures2(:,i));
        if (D(i)<500)
            inliers=inliers+1;
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

