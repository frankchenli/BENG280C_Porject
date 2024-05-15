function [output] = analyze_cnr(img)

diameter = [3 2.5 2 1.5 1 0.95 0.9 0.85 0.8 0.75 0.7 0.65 0.6 0.55 0.5 0.45 0.4 0.35 0.3];
noise = img(191:222,52:92);
sigma = std(reshape(noise,[],1));
first_circle = [59 264];
delta = 23;
width = round(delta/2);
center = [];
CNR = [];
for i = 59:delta:(59+delta*18)
    center_value = img(i,264);
    interest_region = img(i-width:i+width,264-width:264+width);
    interest_region = interest_region(interest_region>0);
    C = abs(center_value- mean(interest_region))/sigma;
    center = [center center_value];
    CNR = [CNR C];

end
output.mtf = CNR;
output.diameter = diameter;

end
