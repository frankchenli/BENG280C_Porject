function [the_sino,the_theta] = convert_to_parallel_wrapper(input_sino,num_views)
    % The reference convert to parallel function needs more columns than
    % what is available in the lab 4 data. This function extends the sinogram 
    % so that the reference convert to parallel function works.
    % It also truncates a small part of the front and end of the input sinogram.
    
    n_cols=size(input_sino,2);
    offset=round((n_cols-num_views)/2);
    [the_sino,the_theta] = ref_convert_to_parallel([input_sino(:,offset:offset+num_views) input_sino(:,offset:end-offset)]);
end