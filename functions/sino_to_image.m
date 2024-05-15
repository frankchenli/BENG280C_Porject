function [output] = sino_to_image(input,theta,img_sz,ramp);

output=iradon(input,theta,'linear',ramp,1,img_sz);

end

