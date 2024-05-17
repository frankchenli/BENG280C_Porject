clear all;
close all;


%% Load 

path_raw = './data/raw_sino';
path_dcm = './data/CAC01_41005/CAC01_41005/Ct Heart Calcium Score Without Contrast/CALCIUM SCORE THIN_302';


addpath(path_raw);
addpath(path_dcm);


for i = 1
    file = dir([path_dcm,'/*.dcm']);
    for j = 1:numel(file)
        data(i).image(j).each_image = dicomread(file(j).name);
        data(i).image(j).info = dicominfo(file(j).name);
        data(i).image(j).each_image = (data(i).image(j).each_image*data(i).image(j).info.RescaleSlope)+data(i).image(j).info.RescaleIntercept;
    end
end



raw = dir(path_raw);
label = ["41005",'41006','41007','41008','air scan1','air scan1','air scan2','air scan3','air scan4','air scan5','air scan6','air scan7','air scan8','air scan9','air scan10'];

for i = 3:numel(raw)
    data.raw_sino(i-2).file = load(raw(i).name);
    data.raw_sino(i-2).name = label(i-2);
end


%% segmentation

target = data.image(10).each_image;



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

sino = squeeze(raw.central_data(:,1,:));

[p_sino,sino_thetas] = convert_to_parallel_wrapper(sino,num_views);



%% Normalization
np_sino = p_sino;

 

%% Recon

% [FBP_result] = ref_recon_parallel_beam(np_sino,angle_shift,img_list,img_size,num_views);

a = iradon(p_sino);




