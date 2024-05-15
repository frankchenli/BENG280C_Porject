function extend_sino(input_sino_data,num_views,fig_N_start)


    im_sino=input_sino_data.sino_para;
    
    x_offset_tweak = 3;
    obj_dist = 1420;
    obj_width = 160;
    obj_height = 20;
    intensity_scale=.7/obj_height;

    obj_img = zeros(obj_dist);
    center_x = round(obj_dist/2);
    the_row=im_sino(4,:);
    [max_val,idx] = max(the_row);
    min_val = min(the_row);
    bkg_val=mean(the_row(the_row < (max_val+min_val)/2));
    Cu_int=intensity_scale*(max_val-bkg_val);
    Al_int = intensity_scale*(im_sino(4,idx-39)-bkg_val);
    obj_img(1:obj_height,center_x-obj_width:center_x) = Cu_int;
    obj_img(1:obj_height,center_x+1:center_x+1+obj_width) = Al_int;
    
    obj_img_theta = input_sino_data.sino_thetas;
    obj_sino = radon(obj_img,obj_img_theta);
    dif_y=(size(obj_sino,1)-size(im_sino,1));
    offset=round(dif_y/2);
    
    feature_selection=im_sino(700:800,:);
    filt=obj_sino(offset+700:offset+800,1:round(num_views/2));
    
    c=conv(fliplr(mean(filt)),mean(feature_selection));
    [~,idx]=max(c);
    x_offset = idx-size(filt,2);
    obj_sino=obj_sino+bkg_val;
    
    
    % condense next 3 lines
    obj_sino=[obj_sino obj_sino(:,size(obj_sino,2)-num_views+1:num_views)];
    obj_sino=[obj_sino(:,end-x_offset+x_offset_tweak:end) obj_sino(:,1:end)];
    combined_sino=[obj_sino(:,1:size(im_sino,2))];
    
    sino_subtr=im_sino(3:end-2,:) - combined_sino(offset+3:offset+size(im_sino,1)-2,:);
    combined_sino(offset+3:offset+size(im_sino,1)-2,:)=im_sino(3:end-2,:);

    figure(fig_N_start);
    tiledlayout(3,1,'Padding','tight')
    nexttile(1);imagesc(im_sino,[0 max(im_sino(:))])
    nexttile(2);imagesc(combined_sino,[0 max(im_sino(:))])
    nexttile(3);imagesc(sino_subtr,[0 max(im_sino(:))])
    figure(fig_N_start+1);plot(c)
    
    % 
%     extended_image=iradon(combined_sino,obj_img_theta,"linear","Ram-Lak",1,500);
%     im_subtr=iradon(sino_subtr,obj_img_theta,"linear","Ram-Lak",1,500);
%     reference_img=iradon(im_sino,obj_img_theta,"linear","Ram-Lak",1,500);
    extended_image=iradon(combined_sino,obj_img_theta,"linear","Ram-Lak");
    im_subtr=iradon(sino_subtr,obj_img_theta,"linear","Ram-Lak");
    reference_img=iradon(im_sino,obj_img_theta,"linear","Ram-Lak");

    t_size=[500 500];
    crop_ctr= @(img) imcrop(img,centerCropWindow2d(size(img),t_size));
    extended_image=crop_ctr(extended_image);
    im_subtr=crop_ctr(im_subtr);
    reference_img=crop_ctr(reference_img);

    figure(fig_N_start+2)
    tiledlayout(2,3,'Padding','tight')
    colormap('gray')
    nexttile(1)
    imagesc(extended_image,[0 max(extended_image(:))])
    axis('square');title("with extension")
    nexttile(2)
    imagesc(im_subtr,[0 max(extended_image(:))])
    axis('square');title("with subtraction")
    nexttile(3)
    imagesc(reference_img,[0 max(reference_img(:))])
    axis('square');title("reference")
    nexttile(4)
    imagesc(extended_image-reference_img)
    axis('square');title("diff with extension")
    colorbar
    nexttile(5)
    imagesc(im_subtr-reference_img)
    axis('square');title("diff with subtr")
    colorbar
end

function cropped_im=ctr_crop(img)
    
end