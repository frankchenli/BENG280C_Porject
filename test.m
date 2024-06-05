clear all;
close all;

path_raw = './data/raw_sino';
path_ref = './ref-functions';
path_func = './functions';

addpath(path_raw);
addpath(path_ref);
addpath(path_func);

raw = dir(path_raw);
label = ["41005",'41006','41007','41009','air scan1','air scan1','air scan2','air scan3','air scan4','air scan5','air scan6','air scan7','air scan8','air scan9','air scan10'];

for i = 3:numel(raw)
    data.raw_sino(i-2).file = load(raw(i).name);
    data.raw_sino(i-2).name = label(i-2);
end

angle_shift=0; % Used to define theta as 0 (rotate images during iRadon)
img_list=[0]; %the code will stop if it runs out of data
img_size=1024;
num_views=984;

scan_num = 1;
air_num = 5;

targe = data.raw_sino(scan_num).file.central_data;
target = squeeze(targe(:,1,:));
mA = data.raw_sino(scan_num).file.mA;

[r,c] = size(target);

air_sino =squeeze((data.raw_sino(air_num).file.central_data(:,1,1:c)+data.raw_sino(air_num).file.central_data(:,2,1:c))/2);


%% Air Scan
air_mA = data.raw_sino(air_num).file.mA(1:c);

mA_matrix = repmat(mA'./air_mA',size(target,1),1);



%% Extend
n_cols=size(target,2);
offset=round((n_cols-num_views)/2);

ext  = [target(:,offset:offset+num_views) target(:,offset:end-offset)];


[p_sino,sino_thetas] = ref_convert_to_parallel(ext);


cor_air = [];
cor_scan = [];
for k = 1:size(air_sino,2)

    slice = air_sino(:,k);
    slice_scan = p_sino(:,k);
    cor = smooth(slice,20);
    diff = cor-slice;
    thre = diff>0.07*max(diff);
    dents = find(thre);
    other = find(~thre);
    pk = diff(thre);
    inter = interp1(other,slice_scan(other),dents,'linear');
    result = slice_scan;
    result(dents) = inter;

    cor_scan(:,k) = result;
    cor_air(:,k) = cor;

end




























