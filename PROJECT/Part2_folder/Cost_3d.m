function [ acum ] = Cost_3d( obj1, obj2 )
acum = 0;
f1=obj1.frames_tracked;
f2=obj2.frames_tracked;

[frames,ia,ib] = intersect(f1,f2);
for i=frames
    A=create_object_from_frame(obj1,i);
    B=create_object_from_frame(obj2,i);
    acum = acum+CostFunction(A,B);
end
if length(frames)==0
    acum = 1000;
else
    acum=acum/length(frames);
end
end

