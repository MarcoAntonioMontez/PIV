function [  ] = show_hist( histograms )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
for n=1:length(histograms)
    figure()
    hold all
    subplot(2,2,1);
    bar(histograms(n).hist_red)

    subplot(2,2,2);
    bar(histograms(n).hist_green)

    subplot(2,2,3);
    bar(histograms(n).hist_blue)

    subplot(2,2,4);
    image(histograms(n).img)
    hold off
end

end

