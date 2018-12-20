function draw_inliers(M_transf1, M_transf2, A_, B_, im1descriptors, im2descriptors, matching, im1, f1, f2, match)
    niu = M_transf1*[A_;ones(1,size(A_,2))];
    u1=round(niu(1,:)./niu(3,:));
    v1=round(niu(2,:)./niu(3,:));
    figure(im1descriptors);
    hold on; plot(u1, v1, 'r*', 'LineWidth', 2, 'MarkerSize', 1);

    niu = M_transf2*[B_;ones(1,size(B_,2))];
    u2=round(niu(1,:)./niu(3,:));
    v2=round(niu(2,:)./niu(3,:));
    figure(im2descriptors);
    hold on; plot(u2, v2, 'r*', 'LineWidth', 2, 'MarkerSize', 1);

    figure(matching);
    hold on ;
    h = line([u1 ; u2 + size(im1,2)], [v1 ; v2]) ;
    set(h,'linewidth', 1, 'color', 'r') ;
    axis image off ;