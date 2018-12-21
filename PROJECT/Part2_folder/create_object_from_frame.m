function [ obj_mod ] = create_object_from_frame(object, frame)

f = find(object.frames_tracked==frame);
if length(f)==0
    obj_mod=[];
else
    obj_mod.X=object.X(:,f);
    obj_mod.Y=object.Y(:,f);
    obj_mod.Z=object.Z(:,f);
    obj_mod.histogram=object.histogram(f);
    obj_mod.frames_tracked=frame;
end
end

