function [ distances_vec ] = Distance_to_prev_objects( new_position, prev_positions_vector )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    L=length(prev_positions_vector);
    distances_vec = zeros(L,1);

    for i=1:size(prev_positions_vector,1)
        distances_vec(i) = Distance(new_position,prev_positions_vector(i,:)); 
    end

end

