logfilez=dir('log*.txt');
nd2filez=dir('*.nd2');

for ii=1:length(nd2filez)
    if ~(exist(strcat(nd2filez(ii).name,'.mat'),'file')==2);
        img_data=import_nd2_files(1,nd2filez(ii).name,logfilez(ii).name);
    else
        load(strcat(nd2filez(ii).name,'.mat'))
    end
    img_data.red_img_stack_filt=medfilt3D(img_data.img_stacks{2});
    img_data.green_img_stack_filt=medfilt3D(img_data.img_stacks{1});
    
        
    
    [img_data.aligned_red_img,img_data.aligned_green_img]=...
        img_registration_parallel(img_data.red_img_stack_filt,img_data.green_img_stack_filt);    
    save(strcat(nd2filez(ii).name,'.mat'),'img_data');
    
end