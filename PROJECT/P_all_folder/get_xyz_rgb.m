function xyz_rgb = get_xyz_rgb(xyz, R, T)
xyz_rgb = R * xyz';
xyz_rgb = [xyz_rgb(1,:) + T(1); xyz_rgb(2,:) + T(2); xyz_rgb(3,:) + T(3)];
end