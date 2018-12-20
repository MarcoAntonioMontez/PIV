function [  ] = plot_matches( image1, image2, f1, f2, match, imagenumber )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    figure(imagenumber); clf ;
    imshow(cat(2, image1,image2));
    xa = f1(1,match(1,:)) ;
    xb = f2(1,match(2,:)) + size(image1,2) ;
    ya = f1(2,match(1,:)) ;
    yb = f2(2,match(2,:)) ;

    hold on ;
    h = line([xa ; xb], [ya ; yb]) ;
    set(h,'linewidth', 1, 'color', 'b') ;
    f1plot=f1;
    f2plot=f2;
    vl_plotframe(f1plot(:,match(1,:)));
    f2plot(1,:) = f2plot(1,:) + size(image1,2) ;
    vl_plotframe(f2plot(:,match(2,:)));
    axis image off ;
end

