function [corrected] = filling(sinogram,profile)

empty = sinogram.*profile;
capture_wid = 50;


for i = 1:size(empty,1)
    for j = 1:size(empty,2)
        if empty(i,j) == 0
            if j<=capture_wid+1
                empty(i,j) = empty(i,j+40+capture_wid);
            else 
                empty(i,j) = empty(i,j-capture_wid);
            end
        end

        if isnan(empty(i,j)) == 1
            if size(empty,2)-j<=capture_wid
                empty(i,j) = empty(i,j-40-capture_wid);
            else 
                empty(i,j) = empty(i,j+capture_wid);
            end
        end

        end
end

corrected = empty;


end