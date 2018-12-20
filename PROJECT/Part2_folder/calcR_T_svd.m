%calcR_T_svd

function [R, T] = calcR_T_svd(A, B)
    %Calc centroids
    Centroid1=mean(A,2);
    Centroid2=mean(B,2);

    %Subtract centroids from A,B
    A_menos_centroid = A - repmat(Centroid1,1,size(A, 2));
    B_menos_centroid = B - repmat(Centroid2,1,size(B, 2));

    %Compute SVD
    M = B_menos_centroid*A_menos_centroid';
    [U,~,V] = svd(M);
    Mdiagonal = ones(size(U',1),1);
    Mdiagonal(size(U',1),1) = det(U*V');
    R = U * (diag(Mdiagonal)) * V';
    T=Centroid2-R*Centroid1;
end