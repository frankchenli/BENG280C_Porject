clear all;
close all;


%% Load 

% path(1).air = './data/CAC_AIR01_41005thru41009/CAC_AIR01_41005thru41009/200/study/CAL_SCORE_ASIR-50_0.625_303/*.dcm';
% path(2).air = './data/CAC_AIR01_41005thru41009/CAC_AIR01_41005thru41009/200/study/CALCIUM_SCORE_STD_AX_301/*.dcm';
% path(3).air = './data/CAC_AIR01_41005thru41009/CAC_AIR01_41005thru41009/200/study/CALCIUM_SCORE_THIN_302/*.dcm';

path(1).scan = './data/CAC01_41005/CAC01_41005/Ct Heart Calcium Score Without Contrast/CALCIUM SCORE THIN_302/*.dcm';

raw = load('./data/raw_sino/central_scale_scan_41005.2.1.mat');

for i = 1
    file = dir(path(i).scan);
    for j = 1:numel(file)
        data(i).image(j).each_image = dicomread(file(j).name);
        data(i).image(j).info = dicominfo(file(j).name);
        data(i).image(j).each_image = (data(i).image(j).each_image*data(i).image(j).info.RescaleSlope)+data(i).image(j).info.RescaleIntercept;
    end
end

%% segmentation


% close all
% for i = 1:10
%     figure;
%     imshow(data(1).image(i).each_image,[-150 150]);
% end


%% Parameters
% Set Recon Parameters
angle_shift=0; % Used to define theta as 0 (rotate images during iRadon)
img_list=[0]; %the code will stop if it runs out of data
img_size=512;
num_views=984;

%% Fan to parallel

sino = squeeze(raw(:,1,:));

[p_sino,sino_thetas] = convert_to_parallel_wrapper(sino,num_views);



%% Normalization
np_sino = p_sino;

 

%% Recon


[FBP_result] = ref_recon_parallel_beam(np_sino,angle_shift,img_list,img_size,num_views);






