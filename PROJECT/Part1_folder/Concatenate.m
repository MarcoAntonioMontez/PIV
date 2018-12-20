function [ O ] = Concatenate(new, O)
%UNTITLED2 Summary of this function goes here
%   world box and frames_tracked
    old_x=O(new.id).X ;
    old_y=O(new.id).Y ;
    old_z=O(new.id).Z ;
    old_frames=O(new.id).frames_tracked;
    %cam_box
    old_x_cam=O(new.id).X_cam ;
    old_y_cam=O(new.id).Y_cam ;
    old_z_cam=O(new.id).Z_cam ;
    
    
    old_hist=O(new.id).histogram;
    new_hist=new.histogram;
    
    new_x=new.X;
    new_y=new.Y;
    new_z=new.Z;
    new_frames=new.frames_tracked;
    index=new.id;
    
    new_x_cam=new.X_cam ;
    new_y_cam=new.Y_cam ;
    new_z_cam=new.Z_cam ;
    
    O(index).X = [ old_x, new_x ];
    O(index).Y = [ old_y, new_y ];
    O(index).Z = [ old_z, new_z ];
    O(index).frames_tracked = [ old_frames, new_frames];
    
    O(index).X_cam = [ old_x_cam, new_x_cam ];
    O(index).Y_cam = [ old_y_cam, new_y_cam ];
    O(index).Z_cam = [ old_z_cam, new_z_cam ];
    O(index).histogram = [ old_hist, new_hist ];
    
    
%     O(new.id).Y = [ O(new.id).Y  new.Y ];
%     O(new.id).Z = [ O(new.id).Z  new.Z ];
%     O(new.id).frames_tracked = [ O(new.id).frames_tracked  new.frames_tracked ];
%     

end

