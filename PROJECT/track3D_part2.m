function [ objects, cam2toW ] = track3D_part2(img_name_seq1, img_name_seq2, cam_params)
clc;
addpath('P_all_folder','Part2_folder')
run('vlfeat-0.9.21/toolbox/vl_setup')
%vl_version verbose
%Draw plots
plots = 0;

%UBC Match:
match_thresh =1.6;

% RANSAC:
%Set number of iterations
niter = 100;

%Coplanar check. minimum threshold of eigenvalues: the greater the value,
%the harder it is to find a combination that obeys this
rank_thresh=0.01;

%Set error treshold for inliers
error_tresh = 0.2;

%Load RGB images. Inverted because cam 1 should be world.
image1=imread(img_name_seq1(1).rgb);
image2=imread(img_name_seq2(1).rgb);

if(plots)
    figure1 = figure();
    imshow(image1);
    figure2 = figure();
    imshow(image2);
end

%Convert to gray scale for SIFT
image1_gray=rgb2gray(image1);
image2_gray=rgb2gray(image2);

%Load depth for the respective images
image1_depth = load(img_name_seq1(1).depth);
image2_depth = load(img_name_seq2(1).depth);

depth_array1 = reshape(image1_depth.depth_array, [480*640, 1]);
depth_array2 = reshape(image2_depth.depth_array, [480*640, 1]);

%Get world coordinates for depth images in a 480*640 array
xyz1_d_array = get_xyzasus(depth_array1, size(image1_depth.depth_array), (1:640*480)', cam_params.Kdepth, 1, 0);
xyz2_d_array = get_xyzasus(depth_array2, size(image2_depth.depth_array), (1:640*480)', cam_params.Kdepth, 1, 0);

xyz1_array = get_xyz_rgb(xyz1_d_array, cam_params.R, cam_params.T);
xyz2_array = get_xyz_rgb(xyz2_d_array, cam_params.R, cam_params.T);

xyz1_array = xyz1_array';
xyz2_array = xyz2_array';

%Re-shape array into 3 [480x640] matrices:
% - The 1st gives access to x values in world frame
% - The 2nd gives access to y values in world frame
% - The 3rd gives access to z values in world frame
xyz1 = reshape(xyz1_array, [480, 640, 3]);
xyz2 = reshape(xyz2_array, [480, 640, 3]);

% if(plots)
%     figure_xyz1=figure(4);
%     showPointCloud(xyz1);
%     figure_xyz2=figure(5);
%     showPointCloud(xyz2);
% end

%Get RGB coordinates for world frame
rgbd1 = get_rgbd(xyz1_array, image1, cam_params.R, cam_params.T, cam_params.Krgb);
rgbd2 = get_rgbd(xyz2_array, image2, cam_params.R, cam_params.T, cam_params.Krgb);

%Get image descriptors and positions
[f1, d1] = vl_sift(single(image1_gray));
[f2, d2] = vl_sift(single(image2_gray));

%Match descriptors and score this match from both images with last param.
%being maximum error between matches
[match, sc] = vl_ubcmatch(d1, d2, match_thresh);

%Plot the matches and draw lines between them
if(plots)
    plot_matches( image1, image2, f1, f2, match, 3);
end

% RANSAC:

%Create matrices for RANSAC
xyz1_4points = zeros(4,3);
xyz2_4points = zeros(4,3);

image1_4points = zeros(4, 2);
image2_4points = zeros(4, 2);

n_inliers = zeros(1, niter);

if(plots)
    plot_points1= zeros(niter, 4, 2);
    plot_points2= zeros(niter, 4, 2);
end

%Get xyz of valid matches (i.e z ~=0)
f1_matched = fix(f1(1:2, match(1,:)));
f2_matched = fix(f2(1:2, match(2,:)));

for j = 1:length(f1_matched)
    xyz1_matched(j,:,:) = xyz1(f1_matched(2,j), f1_matched(1,j),:);
    xyz2_matched(j,:,:) = xyz2(f2_matched(2,j), f2_matched(1,j),:);
end

good_inds = find((xyz1_matched(:,3).*xyz2_matched(:,3))~=0);
xyz1_matched = xyz1_matched(good_inds,:);
xyz2_matched = xyz2_matched(good_inds,:);

n_valid_matches = length(xyz1_matched);

%Create matrices for inliers
vector1_inliers = zeros(n_valid_matches, 3, niter);
vector2_inliers = zeros(n_valid_matches, 3, niter);

%Main RANSAC cycle
for i=0:niter-1
    image1_4points(:) = 0;
    image2_4points(:) = 0;
    xyz1_4points(:) = 0;
    xyz2_4points(:) = 0;
    while (rank(xyz1_4points', rank_thresh) < 3 && rank(xyz2_4points', rank_thresh) < 3)
        %Get 4 random matched points for each iteration
        for j=1:4
            image1_4points(j) = 0;
            image2_4points(j) = 0;
            xyz1_4points(j) = 0;
            xyz2_4points(j) = 0;
            
            %Guarantee that these matches are valid, unique and non-colinear
            while ismember(0,  xyz1_4points(j)) || ismember(0,  xyz2_4points(j)) || length(unique(xyz2_4points(1:j)))~=j% || (rank(xyz1_4points(1:j, :), rank_thresh) < j-1 && rank(xyz2_4points(1:j,:), rank_thresh) < j-1)
                
                random_match = match(:, randperm(length(match), 1));
                
                image1_4points(j, :)=f1(1:2 ,random_match(1));
                image2_4points(j, :)=f2(1:2, random_match(2));
                image1_4points(j, :) = fix(image1_4points(j, :));
                image2_4points(j, :) = fix(image2_4points(j, :));
                
                image1_4points(find(image1_4points(j)) == 0) = 1;
                image2_4points(find(image2_4points(j)) == 0) = 1;
                
                %Get matched points coordinates in 3D
                xyz1_4points(j, :) = xyz1(image1_4points(j, 2), image1_4points(j, 1), :);
                xyz2_4points(j, :) = xyz2(image2_4points(j, 2), image2_4points(j, 1), :);
            end
        end
    end
    if(plots)
        %Save 2D points to plot them later
        plot_points1(i+1, :, 1)=image1_4points(:,1);
        plot_points1(i+1, :, 2)=image1_4points(:,2);
        plot_points2(i+1, :, 1)=image2_4points(:,1);
        plot_points2(i+1, :, 2)=image2_4points(:,2);
    end
    
    %Calculate model for Rotation and Translation based on 4 random points
    [R, T] = calcR_T_svd(xyz2_4points', xyz1_4points');
    
    %Use Rotation and Translation to project xyz1 into xyz2 frame
    xyz21_matched=R*xyz2_matched' + repmat(T,1,n_valid_matches);
    
    %Check how many matches are considered inliers with estimated model
    for k = 1:n_valid_matches
        %Use Euclidian norm to calculate estimation error
        err = norm(xyz21_matched(:,k)'-xyz1_matched(k,:));
        
        if (err<error_tresh)
            n_inliers(i+1) = n_inliers(i+1) + 1;
            vector1_inliers(n_inliers(i+1),:,i+1)=xyz1_matched(k,:);
            vector2_inliers(n_inliers(i+1),:,i+1)=xyz2_matched(k,:);
        end
    end
end

[Max, index] = max(n_inliers);

if(plots)
    %Plot the 4 random point pairs used for estimating best projection model
    figure(figure1);
    hold on
    plot(plot_points1(index, :, 1), plot_points1(index, :, 2),'*r');
    hold off
    
    figure(figure2);
    hold on
    plot(plot_points2(index, :, 1), plot_points2(index, :, 2),'*r');
    hold off
    
    %Plot all 4 random point pairs used for estimating projection models
    figure(6)
    imshow(cat(2, image1,image2));
    hold on;
    for i=1:niter
        plot(plot_points1(i, :, 1), plot_points1(i, :, 2),'*r');
        plot(plot_points2(i, :, 1)+size(image1,2), plot_points2(i, :, 2),'*r');
        for j = 1:4
            plot([1 3], [2 4])
            h = line([plot_points1(i, j, 1) ; plot_points2(i, j, 1)+size(image1,2)], [plot_points1(i, j, 2) ; plot_points2(i, j, 2)]) ;
            set(h,'linewidth', 1, 'color', 'r') ;
        end
    end
    
    hold off
end

%Eliminate zeros from best inliers
final_inliers1=vector1_inliers(:,:, index);
final_inliers2=vector2_inliers(:,:, index);
final_inliers1( all(~final_inliers1,2), : ) = [];
final_inliers2( all(~final_inliers2,2), : ) = [];

%Estimate new model based on all inliers
[final_R, final_T] = calcR_T_svd(final_inliers2', final_inliers1');

%Shift world frame of camera 1 to camera 2 world frame
final_xyz21_array=final_R*xyz2_array' + repmat(final_T,1,length(xyz2_array));

if(plots)
    %Plot point cloud merge
    figure(7)
    showPointCloud(final_xyz21_array');
    pc1=pointCloud(xyz1_array,'Color',reshape(rgbd1,[480*640 3]));
    pc21 = pointCloud(final_xyz21_array','Color',reshape(rgbd2,[480*640 3]));
    showPointCloud(pcmerge(pc21,pc1,0.00001));
    drawnow;
end

cam2toW.R=final_R;
cam2toW.T=final_T;

%%
[objects1]=track3D_part1(img_name_seq1, cam_params);
for i=1:length(objects1)
    objects1(i).X=objects1(i).X';
    objects1(i).Y=objects1(i).Y';
    objects1(i).Z=objects1(i).Z';
end
[objects2]=track3D_part1(img_name_seq2, cam_params);
for i=1:length(objects2)
    objects2(i).X=objects2(i).X';
    objects2(i).Y=objects2(i).Y';
    objects2(i).Z=objects2(i).Z';
end

%Creates hungarian matrix with CostFunction
cost_treshold=2;
N=length(objects1);
M=length(objects2);
hungarian_matrix=zeros(N,M);
objects=[];

for i=1:N %for each object
    for n=1:size(objects2(i).X,2) %for each frame it appears
        obj_xyz=final_R*[objects2(i).X(:,n) objects2(i).Y(:,n) objects2(i).Z(:,n)]' + repmat(final_T,1,size([objects2(i).X(:,n) objects2(i).Y(:,n) objects2(i).Z(:,n)],1));
        objects2(i).X(:,n)=(obj_xyz(1,:))';
        objects2(i).Y(:,n)=(obj_xyz(2,:))';
        objects2(i).Z(:,n)=(obj_xyz(3,:))';
    end
end

% figure()
% pc1=pointCloud(xyz1_array,'Color',reshape(rgbd1,[480*640 3]));
% pc21 = pointCloud(final_xyz21_array','Color',reshape(rgbd2,[480*640 3]));
% showPointCloud(pcdenoise(pcmerge(pc21,pc1,0.00001), 'Threshold', 0.5));
% PlotImages(objects2(2),image1,xyz1_array,rgbd1,'g')
% PlotImages(objects1(1),image1,xyz1_array,rgbd1,'r')

for i=1:N
    for j=1:M
        hungarian_matrix(i,j) = Cost_3d(objects1(i), objects2(j));
    end
end

%Does hungarian matching
matching1 = assignmentoptimal(hungarian_matrix);
%IF cost is bigger than cost_treshold than object is a new one
for i=1:N
    if min(hungarian_matrix(i,:)) > cost_treshold
        matching1(i)=0;
    end
end
hungarian_matrix2=hungarian_matrix';
matching2 = assignmentoptimal(hungarian_matrix2);
for i=1:M
    if min(hungarian_matrix2(i,:)) > cost_treshold
        matching2(i)=0;
    end
end

for i=1:length(matching1)
    if matching1(i)== 0
        %If new_object is not recognized
        %(has the lowest hungarian matching and all others objects
        %were matched), append object to objects
        index=(length(objects)+1);
        new_object=[];
        new_object=simple_concatenate(objects1(i),new_object);
        objects(index)=new_object;
    else
        objects = concatenate_lists(objects,objects1(i),objects2(matching1(i)));
    end
end
for i=1:length(matching2)
    if matching2(i)== 0
        %If new_object is not recognized
        %(has the lowest hungarian matching and all others objects
        %were matched), append object to objects
        index=(length(objects)+1);
        new_object=[];
        new_object=simple_concatenate(objects2(i),new_object);
        objects(index)=new_object;
    end
end
for i=1:length(objects)
    objects(i).X=objects(i).X';
    objects(i).Y=objects(i).Y';
    objects(i).Z=objects(i).Z';
end
end