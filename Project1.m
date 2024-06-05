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

air_mA = data.raw_sino(air_num).file.mA(1:c);

mA_matrix = repmat(mA'./air_mA',size(target,1),1);



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
% plot(l,slice_scan);hold on; plot(l(dents),slice_scan(dents),'o')




%% Normalization
sino = cor_scan;

n_sino = perform_log_normalization(sino,cor_air,mA_matrix);



%% Fan to parallel

[p_sino,sino_thetas] = convert_to_parallel_wrapper(n_sino,num_views);
% [p_sino,sino_thetas] = ref_convert_to_parallel(n_sino);

% a = p_sino;
% a(470,:) = 1;


%% Recon

recon= ref_recon_parallel_beam(p_sino,sino_thetas,angle_shift,img_list,img_size,num_views);
recon_rot = imrotate(recon*10^4,-100);


% imshow(recon_rot,[0.01 0.06]);
% imshow(recon_rot,[50 80]);
% figure;
% imshow(data.image(128).each_image,[-150 150]); 
% title('ground truth')



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
% dicomwrite(recon_iter_rot,'recon_iter.dcm');



%% Scaling Part1


heart = recon_rot(481:707,464:714);
roi1 = heart;
t_bone = roi1>85;
t_fat = roi1>50 & roi1<60;
t_air = roi1<45;


fmk = roi1;
fmk(t_fat) = 1;
fmk(~t_fat) = 0;
fat = roi1.*fmk;
v = sum(sum(fat))/sum(sum(fmk));
ratio = -100/v;
fat = fat*ratio;

bmk = roi1;
bmk(t_bone) = 1;
bmk(~t_bone) = 0;
bone = roi1.*bmk;
v = sum(sum(bone))/sum(sum(bmk));
ratio = 1000/v;
bone = bone*ratio;


amk = roi1;
amk(t_air) = 1;
amk(~t_air) = 0;
air = roi1.*amk;
v = sum(sum(air))/sum(sum(amk));
ratio = -3024/v;
air = air*ratio;
air(air>0) = -air(air>0);

smk = roi1;
smk(~t_fat & ~t_bone & ~t_air) = 1;
smk(t_fat | t_bone | t_air) = 0;
tissue = roi1.*smk;
v = sum(sum(tissue))/sum(sum(smk));
ratio = 40/v;
tissue = tissue*ratio;

result = tissue+air+bone+fat;

%% Part2


roi2 = recon_rot;
roi2(481:707,464:714) = 0; 
roi2 = roi2(440:820,400:780);

t_bone = roi2>76;
t_fat = roi2>55 & roi2<60;
t_air = (0 < roi2) & (roi2 < 40);



bmk = roi2;
bmk(t_bone) = 1;
bmk(~t_bone) = 0;
bone = roi2.*bmk;
v = sum(sum(bone))/sum(sum(bmk));
ratio = 1000/v;
bone = bone*ratio;

fmk = roi2;
fmk(t_fat) = 1;
fmk(~t_fat) = 0;
fat = roi2.*fmk;
v = sum(sum(fat))/sum(sum(fmk));
ratio = -100/v;
fat = fat*ratio;


amk = abs(roi2);
amk(t_air) = 1;
amk(~t_air) = 0;
air = roi2.*amk;
v = sum(sum(air))/sum(sum(amk));
ratio = -3024/v;
air = air*ratio;
air(air>0) = -air(air>0);

smk = roi2;
smk(~t_fat & ~t_bone & ~t_air) = 1;
smk(t_fat | t_bone | t_air) = 0;
tissue = roi2.*smk;
v = sum(sum(tissue))/sum(sum(smk));
ratio = 10/v;
tissue = tissue*ratio;

result2 = tissue+air+bone+fat;
result2(42:268,65:315) = result;
imshow(result2,[-150 200]);






