function my_montage(image_data,label_inp,fig_title,figN)
    % Create a labeled montage
    % image_data: a cell array of image data
    % label_inp: an array of string cells, ie double quote strings
    % fig_title: label for window title bar
    % figN: figure number to use

    num_images=numel(image_data);
    assert(num_images>0,"No images sent in data structure.")
    assert(num_images==numel(label_inp),"Label amount doesn't match the image count.")
    % Set figure layout
    rows=round(sqrt(num_images));
    cols=rows;
    while(rows*cols<num_images)
        cols=cols+1;
    end
    fig=figure(figN); fig.Name=(fig_title);
    tiledlayout(rows,cols,'Padding','tight')
    colormap('gray')
    [~, idx] = sort(label_inp);
    for i=idx
        nexttile
        imagesc(image_data{i})
        yticks([]);xticks([]);
%         axis('square')
        title(label_inp(i));colorbar
    end
end