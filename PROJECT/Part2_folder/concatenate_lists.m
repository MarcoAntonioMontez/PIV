function [objects] = concatenate_lists(objects, A, B)
    
fA_min=min(A.frames_tracked);
fB_min=min(B.frames_tracked);

fA_max=max(A.frames_tracked);
fB_max=max(B.frames_tracked);

new_object=[];
for i=min(fA_min,fB_min):max(fA_max,fB_max)
    obj1 = create_object_from_frame(A, i);
    obj2 = create_object_from_frame(B, i);
    if isempty(obj1)
        new_object=simple_concatenate(obj2,new_object);
    else
        new_object=simple_concatenate(obj1,new_object);
    end
end
index=(length(objects)+1);
if isempty(objects)
    objects=new_object;
else
    objects(index)=new_object;
end
end