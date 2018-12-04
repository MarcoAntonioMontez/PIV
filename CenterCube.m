function [ center ] = CenterCube( cube )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
x = (cube(2,1)+cube(1,1))/2;
y = (cube(1,2)+cube(3,2))/2;
z = (cube(5,3)+cube(1,3))/2;
center = [x;y;z];
end

