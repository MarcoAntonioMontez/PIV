function [rgb_imgs, depth_imgs] = load_images(img_name_seq)

    rgb_imgs=zeros(480,640,3,length(img_name_seq),'uint8'); % create an array of rgb
    depth_imgs=zeros(480,640,length(img_name_seq)); % create an array of depth

    for i=1:length(img_name_seq)
        rgb_imgs(:,:,:,i) = imread(img_name_seq(i).rgb);

        a  = load(img_name_seq(i).depth);
        depth_imgs(:,:,i)=(a.depth_array);
        % /1000 to convert from millimeters to meters
    end
end

