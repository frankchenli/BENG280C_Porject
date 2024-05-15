function [output] = image_to_sino(input,theta,sino_sz,up_fact);

output=radon(input,theta,up_fact*sino_sz(1));

b = (1/up_fact)*ones(1,up_fact);
a = 1;
y = filter(b,a,output,[],1);

output=y(1:up_fact:end,:);

end

