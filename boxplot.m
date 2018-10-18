function [minValue_x, maxValue_x, minValue_y, maxValue_y, minValue_z, maxValue_z] = boxplot( class_x, class_y, class_depth)
%BOXPLOT Summary of this function goes here
%   Detailed explanation goes here

    %Calcular gaussiana do x
    pdx=fitdist(class_x,'Normal');
    x_values = 1:1:480;
    x = pdf(pdx,x_values);
    cdf_x = cdf(pdx,x_values);
    
    minValue_x=icdf(pdx,0.02);
    maxValue_x=icdf(pdx,0.98);
    
    pdy=fitdist(class_y,'Normal');
    y_values = 1:1:640;
    y = pdf(pdy,y_values);
    minValue_y=icdf(pdy,0.02);
    maxValue_y=icdf(pdy,0.98);
    
    pdz=fitdist(class_depth','Normal');
    z_values = min(class_depth):0.1:max(class_depth);
    z = pdf(pdz,z_values);
    minValue_z=icdf(pdz,0.02);
    maxValue_z=icdf(pdz,0.98);
    %Escolher as melhores amostras 5% a 95% par X/Y/Z
    
    % figure()
    % hold all
    % hist(squeeze(class_x),0:255) %squeeze to 0:255, which is the number of
    %                              %bars/possible value of pixels
    % plot(x*10000)
    % plot(cdf_x*100)
    % x_line=get(gca,'ylim');
    % plot([int16(minValue_x) int16(minValue_x)],x_line)
    % hold off
    %
    % figure()
    % hold all
    % hist(squeeze(class_y),0:255) %that's why we squeeze, 0:255 is number of bars/possible value of pixels
    % plot(y*10000)
    % hold off
    %
    % figure()
    % hold all
    % hist(squeeze(class_depth),z_values) %that's why we squeeze, 0:255 is number of bars/possible value of pixels
    % plot(z_values,z*1000)
    % hold off

end

