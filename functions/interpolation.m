function [cor_air_sino] = interpolation(air_sino,target)
    cor_air_sino = [];
    iter = 4;
    for k = 1:size(air_sino,2)
        slice = air_sino(:,k);
        slice_scan = target(:,k);
        for j = 1:iter
            [pk,loc] = findpeaks(-slice);
            thre = pk>-max(slice);
            dents = loc(thre);
            pk = pk(thre); 
            l = 1:length(slice_scan);
            plot(l,slice_scan);hold on; plot(l(dents),slice_scan(dents),'o')
            ispeak = false(size(slice));
            ispeak(dents) = true;
            non = find(~ispeak);
            inter = interp1(non,slice(non),dents);
            result = slice;
            result(dents) = inter;
            slice = result;
        end
        cor_air_sino(:,k) = result;
    end
end