function outp = parallel_ray_iter(inp,theta,img_sz,sino_sz,ramp,up_fact,transpose_indicator)

% This reconstructs a sinogram
if (strcmp(transpose_indicator,'transp'))
    outp = reshape(inp,sino_sz(1),sino_sz(2));
    outp = sino_to_image(outp,theta,img_sz,ramp);
    outp = outp(:);

% This goes from image to sinogram
elseif (strcmp(transpose_indicator, 'notransp'))
    outp = reshape(inp,img_sz,img_sz);
    outp = image_to_sino(outp,theta,sino_sz,up_fact);
    outp = outp(:);
else
    error('Transpose flag not appropriately defined');
end

return

