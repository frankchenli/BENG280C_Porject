function [x,sinwave,matrix] = create_profile(sinogram,index_in_s_data)
    f = 1/985;
    A = 700;
    offset = 438;
    phase(2) = 0.354*pi;
    phase(3)= 0.12*pi;
    phase(4) = -0.3*pi;
    phase(5) = 1.04*pi;
    phase(6) = -0.675*pi;
    phase(7) =  -0.518*pi;
    phase(8) =  -1.25*pi;
    phase(9) =  -0.31*pi;
    x = 1:size(sinogram,2);
    sinwave(1,:) = A*sin(x*2*pi*f+phase(index_in_s_data))+offset;
    sinwave(2,:) = A*sin(x*2*pi*f+phase(index_in_s_data)+0.083*pi)+offset;
    sinwave(3,:) = A*sin(x*2*pi*f+phase(index_in_s_data)-0.083*pi)+offset;

    
    matrix = ones(2*A+1,size(sinwave,2));
    pos = sinwave-min(sinwave,[],2)+1;



    mat1 = 0;
    mat2 = NaN;

    exp_wid = 42;
   
    for i = 1:length(x)
        matrix(round(pos(1:3,i)),i) = 0;

       
        if length(x)-i<=exp_wid 
            matrix(round(pos(1,i)):round(pos(1,i))+5,i-exp_wid:i) = mat1;
            matrix(round(pos(1,i)):round(pos(1,i))+5,i:length(x)) = mat2;
            matrix(round(pos(2,i)):round(pos(2,i))+5,i:length(x)) = mat1;

        elseif i-1<=exp_wid
            matrix(round(pos(1,i)):round(pos(1,i))+5,1:i) = mat1;
            matrix(round(pos(1,i)):round(pos(1,i))+5,i:i+exp_wid) = mat2;
            matrix(round(pos(3,i)):round(pos(3,i))+5,1:i) = mat2;


        else
            matrix(round(pos(1,i)):round(pos(1,i))+5,i-exp_wid:i) = mat1;
            matrix(round(pos(1,i)):round(pos(1,i))+5,i:i+exp_wid) = mat2;
        end



    end

    matrix([1:262,1140:end],:) = [];


  
end