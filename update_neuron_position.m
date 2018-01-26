function post_position = update_neuron_position(img,pre_position,radius,threshold)
%track neuronal position
if radius ==0
    post_position = pre_position;
    
else
    [height,width]=size(img);

    ymin=max(round(pre_position(2)-radius),1);
    ymax=min(round(pre_position(2)+radius),height);
    xmin=max(round(pre_position(1)-radius),1);
    xmax=min(round(pre_position(1)+radius),width);
    h = fspecial('gaussian',[3,3],3);  
    c_filtered=imfilter(img(ymin:ymax,xmin:xmax),h, 'replicate');
    %threshold and find the local maxima
    %% changed by G.Si 20170808
    if threshold ~= 0 
        bw = imextendedmax(c_filtered,threshold); 
    else
        img_c_filtered = mat2gray(c_filtered, [min(c_filtered(:)) max(c_filtered(:))]);
        temp = sort(img_c_filtered(:),'descend');
        newThresh = temp(100);
%         bw = imextendedmax(c_filtered,newThresh); 
        bw = im2bw(img_c_filtered, newThresh);
    end
    L=logical(bw);
    s=regionprops(L,'Centroid');
    %putative neuronal positions
    Centroids=cat(1,s.Centroid);
    [~,idx]=min(sum((Centroids-repmat(pre_position-[xmin,ymin],size(Centroids,1),1)).^2,2));
    post_position=Centroids(idx,:)+[xmin,ymin]; %update neuron positions

end

end

