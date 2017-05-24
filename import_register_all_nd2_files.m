logfilez=dir('log*.txt');
nd2filez=dir('*.nd2');

for ii=1:length(nd2filez)
    clearvars -except logfilez nd2filez ii
    if ~(exist(strcat(nd2filez(ii).name,'.mat'),'file')==2);
        img_data=import_nd2_files(1,nd2filez(ii).name,logfilez(ii).name);
        
        fields=fieldnames(img_data);
        for jj=1:length(fields)
            eval(sprintf('%s=img_data.%s;',fields{jj},fields{jj}));
        end
        save(strcat(nd2filez(ii).name,'.mat'),'img_stacks','t','neuron_type',...
            'odor_seq','acq_start_time','filename','filename_log','metadata','-v7.3');
    else
        load(strcat(nd2filez(ii).name,'.mat'))
    end
    red_img_stack_filt=medfilt3D(img_stacks{2});
    green_img_stack_filt=medfilt3D(img_stacks{1});
    
    [aligned_red_img,aligned_green_img]=...
        img_registration_parallel_2D(red_img_bkd_filt,green_img_stack_filt);    
    save(strcat(nd2filez(ii).name,'.mat'),'aligned_red_img','aligned_green_img','-append');
    
end