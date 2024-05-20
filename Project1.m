clear all;
close all;


%% Load 

path_raw = './data/raw_sino';
path_dcm = './data/CAC01_41005/CAC01_41005/Ct Heart Calcium Score Without Contrast/CALCIUM SCORE THIN_302';
path_ref = './ref-functions';
path_func = './functions';

addpath(path_raw);
addpath(path_dcm);
addpath(path_ref);
addpath(path_func);

for i = 1
    file = dir([path_dcm,'/*.dcm']);
    for j = 1:numel(file)
        data.image(j).each_image = dicomread(file(j).name);
        data.image(j).info = dicominfo(file(j).name);
        data.image(j).each_image = (data(i).image(j).each_image*data(i).image(j).info.RescaleSlope)+data(i).image(j).info.RescaleIntercept;
    end
end

raw = dir(path_raw);
label = ["41005",'41006','41007','41008','air scan1','air scan1','air scan2','air scan3','air scan4','air scan5','air scan6','air scan7','air scan8','air scan9','air scan10'];

for i = 3:numel(raw)
    data.raw_sino(i-2).file = load(raw(i).name);
    data.raw_sino(i-2).name = label(i-2);
end



%% Parameters
% Set Recon Parameters
angle_shift=0; % Used to define theta as 0 (rotate images during iRadon)
img_list=[0]; %the code will stop if it runs out of data
img_size=1024;
num_views=984;

scan_num = 1;
air_num = 9;



%% segmentation



targe = data.raw_sino(scan_num).file.central_data;
target = squeeze(targe(:,1,:));
mA = data.raw_sino(scan_num).file.mA;

[r,c] = size(target);


air_sino = squeeze(data.raw_sino(air_num).file.central_data(:,1,1:c));
air_mA = data.raw_sino(air_num).file.mA(1:c);

mA_matrix = repmat(mA./air_mA,1,size(target,1)).';

% mA_matrix = repmat(mA,1,size(target,1)).';

% for i = 1:14
%     figure;
%     imshow(squeeze(data.raw_sino(i).file.central_data(:,1,:)),[])
% end

% for i = 1:14
%     figure;
%     plot(data.raw_sino(i).file.mA);
% end



% close all
% for i = 1:10
%     figure;
%     imshow(data(1).image(i).each_image,[-150 150]);
% end




%% Normalization
sino = target;
% mA_matrix = ones(size(sino));

n_sino = perform_log_normalization(sino,air_sino,mA_matrix);



%% Fan to parallel

[p_sino,sino_thetas] = convert_to_parallel_wrapper(n_sino,num_views);
% [p_sino,sino_thetas] = ref_convert_to_parallel(n_sino);


%% Recon

recon= ref_recon_parallel_beam(p_sino,sino_thetas,angle_shift,img_list,img_size,num_views);
recon_rot = imrotate(recon,-100);
imshow(recon_rot,[0.01 0.06]);
figure;
imshow(data.image(128).each_image,[-150 150])




