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
label = ["41005",'41006','41007','41009','air scan1','air scan1','air scan2','air scan3','air scan4','air scan5','air scan6','air scan7','air scan8','air scan9','air scan10'];

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
air_num = 5;



%% Air Scan

targe = data.raw_sino(scan_num).file.central_data;
target = squeeze(targe(:,1,:));
mA = data.raw_sino(scan_num).file.mA;

[r,c] = size(target);

air_sino =squeeze((data.raw_sino(air_num).file.central_data(:,1,1:c)+data.raw_sino(air_num).file.central_data(:,2,1:c))/2);


%% Data Correction

cor_air = [];
cor_scan = [];
for k = 1:size(air_sino,2)

    slice = air_sino(:,k);
    slice_scan = target(:,k);
    cor = smooth(slice,20);
    diff = cor-slice;
    thre = diff>0.1*max(diff);
    dents = find(thre);
    other = find(~thre);
    pk = diff(thre);
    inter = interp1(other,slice_scan(other),dents,'linear');
    result = slice_scan;
    result(dents) = inter;

    cor_scan(:,k) = result;
    cor_air(:,k) = cor;

end



% l = 1:length(slice_scan);
% plot(l,slice);hold on; plot(l(dents),slice(dents),'o')
% 
% plot(slice_scan);
% figure;
% plot(result);
% figure;
% plot(smooth(slice_scan,5));


% slice = air_sino(:,300);
% slice_scan = target(:,1);
% cor = smooth(slice,20);
% diff = cor-slice;
% % plot(cor);hold on; plot(slice);
% % figure;
% % plot(diff);
% 
% thre = diff>0.1*max(diff);
% dents = find(thre);
% pk = diff(thre);
% 
% 
% l = 1:length(slice_scan);
% plot(l,diff);hold on; plot(l(dents),diff(dents),'o')
% 
% plot(l,slice);hold on; plot(l(dents),slice(dents),'o')





%% Air Scan
air_mA = data.raw_sino(air_num).file.mA(1:c);

mA_matrix = repmat(mA'./air_mA',size(target,1),1);


% for air_num = 5:14
%     air_sino(:,:,air_num-4) = squeeze((data.raw_sino(air_num).file.central_data(:,1,1:c)+data.raw_sino(air_num).file.central_data(:,2,1:c))/2);
%     air_mA(:,air_num-4) = data.raw_sino(air_num).file.mA(1:c);
%     mA_matrix(:,:,air_num-4) = repmat(mA./air_mA(:,air_num-4),1,size(target,1)).';
% end
% 
% sino = target;
% for i = 1:10
%     n_sino = perform_log_normalization(sino,air_sino(:,:,i),mA_matrix(:,:,i));
%     [p_sino,sino_thetas] = convert_to_parallel_wrapper(n_sino,num_views);
%     recon= ref_recon_parallel_beam(p_sino,sino_thetas,angle_shift,img_list,img_size,num_views);
%     recon_rot = imrotate(recon,-40);
%     final(:,:,i) = recon_rot;
% end
% 
% for i  = 1:10
%     dicomwrite(final(:,:,i),['final4' num2str(i) '.dcm']);
% end

% 
% close all;
% for i = 1:10
%     figure;
%     % imshow(final(:,:,i),[0.003,0.0045]);
%     % imshow(final(:,:,i),[0.03,0.06])
%     % imshow(final(:,:,i),[0.015,0.03])
%     imshow(final(:,:,i),[0.02,0.03])
% end



%% Normalization
sino = cor_scan;

n_sino = perform_log_normalization(sino,cor_air,mA_matrix);


% n_sino = perform_log_normalization(target,air_sino,mA_matrix);

%% Fan to parallel

[p_sino,sino_thetas] = convert_to_parallel_wrapper(n_sino,num_views);
% [p_sino,sino_thetas] = ref_convert_to_parallel(n_sino);


%% Recon

recon= ref_recon_parallel_beam(p_sino,sino_thetas,angle_shift,img_list,img_size,num_views);
recon_rot = imrotate(recon,-100);
% imshow(recon_rot,[0.01 0.06]);
imshow(recon_rot,[0.005 0.008]);
figure;
imshow(data.image(128).each_image,[-150 150]);
title('ground truth')




dicomwrite(recon_rot,'final.dcm');


%% Algebric Iterative Reconsutrcution 

img_size = 877;
A       = @(x) radon(x, sino_thetas);
% A       = @(x) ref_recon_parallel_beam(x,sino_thetas,angle_shift,img_list,img_size,num_views);
AT      = @(y) iradon(y, sino_thetas, 'none', img_size);

y = p_sino;
x0 = zeros(img_size,img_size);
y = gpuArray(y);
x0 = gpuArray(x0);


lambda  = 1;
iter = 100;
recon_iter = art_recon(A,AT,y,x0,lambda,iter);
recon_iter_rot = imrotate(recon,-100);
dicomwrite(recon_iter_rot,'recon_iter.dcm');











