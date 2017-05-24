function [odor_conc_inf]=gen_odor_conc_inf(fname_log)





if ~isempty(strfind(fname_log,'.txt'))
    % number of lines
    fid = fopen(fname_log);
    allText = textscan(fid,'%s','delimiter','\n');
    fclose(fid);

    % strain name
    numberOfLines = length(allText{1});
    neuron_type = allText{1,1}{1,1};

    % the odor information
    num_ = 3;
    odor_inf = cell(numberOfLines-num_, 2);
    fmt='%s\t %d\t';
    for i = 1:numberOfLines-num_
        odor_inf(i, :) = textscan(allText{1,1}{i+num_,1}, ...
            fmt, 'Delimiter','\t');
    end
    sp=cellfun(@(x)strfind(x,' '),odor_inf(:,1));
    not_water=cellfun(@(x)~isempty(x),sp);
    odor_conc_inf=cell(size(odor_inf,1),3);
    odor_conc_inf(not_water,1)=cellfun(@(x,y)x{1}(1:y(1)-1),odor_inf(not_water,1),sp(not_water),...
        'UniformOutput',false);
    odor_conc_inf(not_water,2)=cellfun(@(x,y)x{1}(y(1)+1:end),odor_inf(not_water,1),sp(not_water),...
        'UniformOutput',false);
    odor_conc_inf(~not_water,2)=cellfun(@(x)x{1},odor_inf(~not_water,1),'UniformOutput',false);
    odor_conc_inf(:,3)=odor_inf(:,2);
else
    load(fname_log);
    odors_used=['water';log_data.odor_list];
    conc_used=[' ';log_data.conc_list];
    odor_inf(:,1)=cellfun(@(x,y)strtrim(sprintf('%s %s',x,y)),...
        conc_used(log_data.sequence_channel'),odors_used(log_data.sequence_channel'),...
        'UniformOutput',false);
    odor_inf(:,2)=num2cell(log_data.sequence_period');
    %neuron_idx=strfind(filename,'_run');
    %neuron_type=filename(1:neuron_idx);
    
    odor_conc_inf(:,1)=conc_used(log_data.sequence_channel');
    odor_conc_inf(:,2)=odors_used(log_data.sequence_channel');
    odor_conc_inf(:,3)=odor_inf(:,2);
end
% 
%     odors_used=['water';log_data.odor_list];
%     conc_used=[' ';log_data.conc_list];
%     
%       
%     odor_conc_inf(:,1)=conc_used(log_data.sequence_channel');
%     odor_conc_inf(:,2)=odors_used(log_data.sequence_channel');
%     odor_conc_inf(:,3)=num2cell(log_data.sequence_period');