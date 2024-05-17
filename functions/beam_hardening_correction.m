function [corr_array] = beam_hardening_correction(atten_array)
%BEAM_HARDENING_CORRECTION Student written function to correct beam
%hardening observed in water phantom


% start = 252;
% mid = 439;
% finish = 625;

start = 247;
finish = 631;
mid = round((start+finish)/2);



det_pos = 1:(finish-start+1);

radius = round(length(det_pos)/2);

thickness = (sqrt((radius.^2)-(abs(radius-det_pos)).^2))*2;
thick1 = thickness(1:radius);
thick2 = thickness(radius+1:end);

correct = [];
for i = 1:984 %size(atten_array,2)

    m = atten_array(:,100+i).';
    % m = mean(atten_array,2).';
    
    roi = m(start:finish);
    % figure;
    % plot(thickness,roi);
    
    
    roi1 = roi(1:radius);
    roi2 = roi(radius+1:end);
    
    k1 = polyfit(thick1,roi1,1);
    c1 = polyval(k1,thick1);

    k11 = polyfit(thick1,roi1,2);
    c11 = polyval(k1,thick1);
    
    % figure;
    % plot(thick1,roi1);
    % hold on
    % plot(thick1,c1);
    
    k2 = polyfit(thick2,roi2,1);
    c2 = polyval(k2,thick2);
    
    
    %fitcurve = [c1,c2];
    
    fitcurve = [(c1+roi1)/2,(c2+roi2)/2];


    fit_whole = [m(1:start-1), fitcurve, m(finish+1:end)];
    correct(:,i) = fit_whole;

end


corr_array = correct;






end