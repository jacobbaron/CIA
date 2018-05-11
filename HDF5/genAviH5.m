function [mov]=genAviH5(fNameIn)
%fNameIn = 'Orco_tdt_EA_run101.h5';
[pth,fStr] = fileparts(fNameIn);
fNameOut = [fStr,'.avi'];
filename = fNameIn;
[piezo,volumes,lasers,t,img_idx,res,...
    acq_start_time]=LoadImgProperties(filename);
piezo=piezo(1:length(img_idx));
volumes=volumes(1:length(img_idx));
lasers=lasers(1:length(img_idx),:);
image_times=zeros(max(volumes),1);
for ii=1:max(volumes)
    image_times(ii)=mean(t(volumes==ii));
end

which_lasers=find(any(lasers,1));
zstack_pos=20*(piezo(volumes==1 & lasers(:,which_lasers(1))));
if length(zstack_pos)==1
    zdiff_size =1 ;
else
    zdiff_size=diff(zstack_pos);
end
pixelSize=[.27,...
                    .27,...
                    zdiff_size(1)];
d1 = res(2);
d2 = res(1);
d3 = length(unique(piezo));
T = length(image_times);
x2z = pixelSize(3)/pixelSize(2);
d3It = round(d3*x2z);
maxImgRGB = zeros(d1+d3It,d2+d3It,3,length(image_times));
%%
h = waitbar(0,'Loading...');
for ii=1:T
    [greenImg,redImg]=get_single_volume(fNameIn,volumes,lasers,piezo,img_idx,res,d3,ii);
    maxImgRGB(:,:,:,ii) = make_max_img_RGB(redImg,greenImg,pixelSize,0);
    waitbar(ii/max(volumes))
end
close(h);
%%

redMean = mean(reshape(maxImgRGB(:,:,1,:),1,[]));
redStd = std(reshape(maxImgRGB(:,:,1,:),1,[]));
redMax = redMean+8*redStd;
redMin = min(reshape(maxImgRGB(:,:,1,:),1,[]));
greenMean = mean(reshape(maxImgRGB(:,:,2,:),1,[]));
greenStd = std(reshape(maxImgRGB(:,:,2,:),1,[]));
greenMax = greenMean+8*greenStd;
greenMin = min(reshape(maxImgRGB(:,:,2,:),1,[]));

maxImgRGB(:,:,1,:) = (maxImgRGB(:,:,1,:)-redMin)/(redMax-redMin);
maxImgRGB(:,:,2,:) = (maxImgRGB(:,:,2,:)-greenMin)/(greenMax-greenMin);


%%
for ii=1:T
maxImgRGB(:,:,:,ii) = insertText(maxImgRGB(:,:,:,ii),...
           [0,0],sprintf('frame %d, t = %0.2f sec',ii,image_times(ii)),'TextColor','white');
    
end
%%

 mov = immovie(maxImgRGB);
 save([fStr,'_mov.mat'],'mov');
 V = VideoWriter(fNameOut,'Uncompressed AVI');
 V.FrameRate = 10;
 
open(V)
writeVideo(V,mov)
close(V)