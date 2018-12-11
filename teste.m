i=1;

figure();
hold all
for k=1:length(objects(i).frames_tracked),
     
     X=objects(i).X(:,k);
     Y=objects(i).Y(:,k);
     Z=objects(i).Z(:,k);
     center=CenterCube([X,Y,Z]);
     
     plot3(center(1),center(2),center(3),'ob')
%      figure();
%     imshow(imgs(:,:,:,objects(i).frames_tracked(k)))
end
    hold off

%        f1 = hist1';
%        f2 = hist2';
%        w1 = 1;
%        w2 = 1;
%        [x fval] = emd(f1, f2, w1, w2, @gdf);
%        fval*100



% figure()
% image(rgbImage)



% for n=1:10
%   images{n} = imread(sprintf('image%03d.png',n));
% end