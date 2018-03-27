function [odor_conc_inf,odor_inf,t,tOdorStart,tOdorEnd] = load_metadata(fname,fnamelog)
%%
load(fname_log);
    odors_used=['water';log_data.odor_list];
    conc_used=[' ';log_data.conc_list];
    odor_inf(:,1)=cellfun(@(x,y)strtrim(sprintf('%s %s',x,y)),...
        conc_used(log_data.sequence_channel'),odors_used(log_data.sequence_channel'),...
        'UniformOutput',false);
    odor_inf(:,2)=num2cell(log_data.sequence_period');
    neuron_idx=strfind(filename,'_run');
    neuron_type=filename(1:neuron_idx);
    
    odor_conc_inf(:,1)=conc_used(log_data.sequence_channel');
    odor_conc_inf(:,2)=odors_used(log_data.sequence_channel');
    odor_conc_inf(:,3)=odor_inf(:,2);
%%

[piezo,volumes,lasers,t,img_idx,res,...
    acq_start_time]=LoadImgProperties(filename);
%piezo=piezo(1:length(img_idx));
volumes=volumes(1:length(img_idx));
%lasers=lasers(1:length(img_idx),:);
t=zeros(max(volumes),1);
for ii=1:max(volumes)
    t(ii)=mean(t(volumes==ii));
end 



odor_seq = getodorseq( image_times,  odor_inf, odor_conc_inf);

[tOdorStart, tOdorEnd]=calculate_odor_start_end_time(acq_start_time,image_times,odor_seq);

end
