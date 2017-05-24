%files=dir('*run3*.h5');
dataset=[];
close all;
[filename,pathname]  = uigetfile({'*'}); 
fname=fullfile(pathname,filename);
%for jj=1:length(files)
   % fname=files(jj).name;
    [piezo,volumes,lasers,t,img_idx,res,...
        start_time]=LoadImgProperties(fname);
    img1=initialize_imgs(volumes,lasers,res,img_idx);
    tic
    x=waitbar(0,'Loading');
    for ii=1:max(volumes) 
        waitbar(ii/max(volumes),x);
        img1=get_volume(fname,ii,lasers,piezo,img_idx,res,volumes,img1);

    end
    close(x)
    toc
    which_lasers=find(any(lasers,1));
    zstack_pos=20*(piezo(volumes==1 & lasers(:,which_lasers(1))));
    red_img=img1(:,:,:,:,2);
    green_img=img1(:,:,:,:,1);
    r_idx=find(~squeeze(all(all(all(red_img==0,4),2),1)));
  %  calc_offsets;
%end