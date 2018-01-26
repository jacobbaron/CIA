function [imgRGB]=import_first_frame_h5(fname)
    [piezo,volumes,lasers,t,img_idx,res,...
    acq_start_time]=LoadImgProperties(fname);
    
piezo=piezo(1:length(img_idx));
volumes=volumes(1:length(img_idx));
lasers=lasers(1:length(img_idx),:);
image_times=zeros(max(volumes),1);
for ii=1:max(volumes)
    image_times(ii)=mean(t(volumes==ii));
end

which_lasers=find(any(lasers,1));
zstack_pos=20*(piezo(volumes==1 & lasers(:,which_lasers(1))));
zdiff_size=diff(zstack_pos);
img = initialize_imgs(volumes,lasers,res,img_idx,1);
img = get_volume(fname,1,lasers,piezo,img_idx,res,volumes,img);
img = flip(flip(permute(img,[2,1,3,4,5]),1),3);
imgSize = size(img);
imgRGB = zeros(imgSize(1),imgSize(2),3);
imgRGB(:,:,[2,1]) = squeeze(max(img,[],3));
for ii=1:size(imgRGB,3)
    imgColor = imgRGB(:,:,ii);
    if any(imgColor(:)>0)
        imgRGB(:,:,ii)= imgColor/max(imgColor(:));
    end
end
end