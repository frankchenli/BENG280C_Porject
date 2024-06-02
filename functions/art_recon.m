function [x] = art_recon(A,AT,y,x,lambda,iter)

ATA	= AT(A(ones(size(x), 'single')));
 
for i = 1:iter
    r = A(x);
    r([1:183,1061:end],:) = [];
    x = x+lambda*AT(y-r)./ATA;    
end

x = gather(x);

end
