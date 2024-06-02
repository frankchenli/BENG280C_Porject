function result = ahe(img,win_size)
    ma = max(max(img));
    [r,c] = size(img);
    distance = round((win_size-1)/2);
    result = zeros(r+2*distance, c+2*distance);
    one_layer = padarray(img,[distance distance],0,'both');
    
    for x = distance+1:r+distance
        for y = distance+1:c+distance
            rank = 0;
            xl = x-distance;
            xh = x+distance;
            yl = y-distance;
            yh = y+distance;
            window = one_layer(xl:xh,yl:yh);

            for i = xl:xh
                for j = yl:yh
                    if one_layer(x,y)>one_layer(i,j)
                        rank = rank+1;
                    end
                end
            end
            result(x,y) = rank*ma/(r*c);
        end
    end
                    
end