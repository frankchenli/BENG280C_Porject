function [log_norm_data] = perform_log_normalization(acquired_sino,air_sino,mA_factor)
%PERFORM_LOG_NORMALIZATION Student written function which creates data for
%reconstruction

normal = acquired_sino./air_sino;

log_norm_data = -mA_factor.*log(normal);


    % if ~exist('mA_factor','var')
    %     mA_factor = ones(size(acquired_sino));
    % end
    % log_norm_data = log(acquired_sino+1e-6) - log(air_sino+1e-6) - log(mA_factor+1e-6);
    % log_norm_data = imcomplement(log_norm_data);
    % log_norm_data = log_norm_data - min(min(log_norm_data));

end