fname='test_trig_2.h5';
[piezo,volumes,lasers,t,img_idx,res,...
    start_time]=LoadImgProperties(fname);
img1=initialize_imgs(volumes,lasers,res,img_idx);
tic
x=waitbar(0,'Loading');
for ii=1:max(volumes) 
    waitbar(ii/max(volumes),x);
    img1=get_volume(fname,ii,lasers,piezo,img_idx,res,volumes,img);
   
end
close(x)
toc
which_lasers=find(any(lasers,1));
zstack_pos=20*(piezo(volumes==1 & lasers(:,which_lasers(1))));