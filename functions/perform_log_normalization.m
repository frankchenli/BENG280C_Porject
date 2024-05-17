function [log_norm_data] = perform_log_normalization(acquired_sino,air_sino,mA_factor)
%PERFORM_LOG_NORMALIZATION Student written function which creates data for
%reconstruction

normal = acquired_sino./air_sino;

log_norm_data = -mA_factor.*log(normal);

end