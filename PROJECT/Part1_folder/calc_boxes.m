function [ boxes ] = calc_boxes( depth_matrix,connected_matrix, num_classes )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

boxes=zeros(8,3*num_classes);

for i = 1:num_classes
    j=3*(i-1);
    x=[];
    y=[];
    z=[];
    [x,y,z] = find(connected_matrix == i);
    max_x=max(x);
    max_y=max(y);
    min_x=min(x);
    min_y=min(y);
    
    logical_connected=connected_matrix == i;
    aux_depth = depth_matrix.*logical_connected;   
    max_z=max(aux_depth(:));   
    
    min_z=min(aux_depth(aux_depth(:)>0));
    
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
