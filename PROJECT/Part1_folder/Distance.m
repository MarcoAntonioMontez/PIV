function [ distance ] = Distance(A,B,rho)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    acum=0;
    for i=1:8
        x=A.X(i)-B.X(i);
        y=A.Y(i)-B.Y(i);
        z=A.Z(i)-A.Z(i);
       
        acum = acum+x^2+y^2+z^2;      
    end

    distance = rho * acum;
     
end

