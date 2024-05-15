function [output] = analyze_psf(img)
%ANALYZE_PSF Student written function which creates metrics for sharpness/blurring
% For metrics, please assign the following:
% output.psf 1D estimate of the PSF
% output.[metric] generate your own metrics and name them appropriately

PSF = fspecial('gaussian',7,10);
output.twoD = deconvlucy(img,PSF);
[M I] = max(max(output.twoD));
output.psf = output.twoD(I(1),:);
% output.psf = output.twoD(256,:);

end