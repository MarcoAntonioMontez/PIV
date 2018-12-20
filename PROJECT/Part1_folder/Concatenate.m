function [ O ] = Concatenate(new, O)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    old_x=O(new.id).X ;
    old_y=O(new.id).Y ;
    old_z=O(new.id).Z ;
    old_frames=O(new.id).frames_tracked;
    new_x=new.X;
    new_y=new.Y;
    new_z=new.Z;
    new_frames=new.frames_tracked;
    index=new.id;
    
    O(index).X = [ old_x, new_x ];
    O(index).Y = [ old_y, new_y ];
    O(index).Z = [ old_z, new_z ];
    O(index).frames_tracked = [ old_frames, new_frames];
    
    
%     O(new.id).Y = [ O(new.id).Y  new.Y ];
%     O(new.id).Z = [ O(new.id).Z  new.Z ];
%     O(new.id).frames_tracked = [ O(new.id).frames_tracked  new.frames_tracked ];
%     

end

