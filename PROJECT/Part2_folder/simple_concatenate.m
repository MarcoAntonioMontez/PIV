function [ O ] = simple_concatenate(new, O)
%UNTITLED2 Summary of this function goes here
%   world box and frames_tracked
    if isempty(O)
        O.X=new.X;
        O.Y=new.Y;
        O.Z=new.Z;
        O.histogram=new.histogram;
        O.frames_tracked=new.frames_tracked;
    else
        old_x=O.X ;
        old_y=O.Y ;
        old_z=O.Z ;
        old_frames=O.frames_tracked;


        old_hist=O.histogram;
        new_hist=new.histogram;

        new_x=new.X;
        new_y=new.Y;
        new_z=new.Z;
        new_frames=new.frames_tracked;

        O.X = [ old_x, new_x ];
        O.Y = [ old_y, new_y ];
        O.Z = [ old_z, new_z ];
        O.frames_tracked = [ old_frames, new_frames];

        O.histogram = [ old_hist, new_hist ];
    end
end

