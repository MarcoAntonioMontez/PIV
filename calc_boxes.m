function [ boxes ] = calc_boxes( depth_matrix,connected_matrix, num_classes )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

boxes=zeros(8,3*num_classes);
connected_depth_image=zeros(480,640);
connected_wc=zeros(480,640,3);

for i = 1:num_classes
    j=3*(i-1);
    x=[];
    y=[];
    z=[];
%     [x,y,z]= find(connected_matrix == i);
    
    %Finds the depth_matrix points that are in object connected==i and puts
    %all other points to depth = 0
    connected_depth_image=depth_matrix.*(connected_matrix==i);
    %Transforms cam coordinates to world coordinates
    connected_wc=depth_to_world(connected_depth_image);
    
    indices = find(connected_wc(:,3)==0);
    connected_wc(indices,:) = [];

    
    x=connected_wc(:,1);
    y=connected_wc(:,2);
    z=connected_wc(:,3);
    
%     %extracts cam_depth form imgsd into connectd image, that had the id of
%     %the connectd object as the z coordinate and now has the z-depth
%     for n_point=1:size(x,1)
%         z(n_point)=depth_matrix(x(n_point),y(n_point));      
%     end
    
    max_x=max(x);
    max_y=max(y);
    max_z=max(z);
    min_x=min(x);
    min_y=min(y);
    min_z=min(z);

    %Ponto 1
    boxes(1,(j+1):(j+3))=[min_x,max_y,min_z];
    boxes(2,(j+1):(j+3))=[max_x,max_y,min_z];
    boxes(3,(j+1):(j+3))=[min_x,min_y,min_z];
    boxes(4,(j+1):(j+3))=[max_x,min_y,min_z];
    
    boxes(5,(j+1):(j+3))=[min_x,max_y,max_z];
    boxes(6,(j+1):(j+3))=[max_x,max_y,max_z];
    boxes(7,(j+1):(j+3))=[min_x,min_y,max_z];
    boxes(8,(j+1):(j+3))=[max_x,min_y,max_z];

end
