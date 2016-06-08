logfilez=dir('log*.txt');
nd2filez=dir('*.nd2');

for ii=11:length(nd2filez)
    img_data=import_nd2_files(1,nd2filez(ii).name,logfilez(ii).name);
    save(strcat(nd2filez(ii).name,'.mat'),'img_data');
    red_img_stack_filt=medfilt3D(img_data.img_stacks{2});
    green_img_stack_filt=medfilt3D(img_data.img_stacks{1});
    [aligned_red_img,aligned_green_img]=...
        img_registration_parallel(red_img_stack_filt,green_img_stack_filt);
    save(strcat(nd2filez(ii).name,'_aligned.mat'),'aligned_red_img','aligned_green_img');
    
    
end