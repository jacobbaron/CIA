global neuron_list;

if ~exist('fname','var')
   fname=img_data.filename;
end
for ii=1:length(neuron_list)
   r{ii} = get_peak_response(img_data.odor_seq,img_data.t,normalized_signal{ii},fn,neuron_list{ii});
end


if length(questdlg('Save this data? Make sure you have exported everything! '))==3

%    clear data;
%    clear imagelist;
%    clear img_stack;
    [fn, savepathname]= uiputfile('*.mat', 'choose file to save', strcat(fname,'-', neuron_list{1},'.mat'));
    if isfield(img_data,'img_stacks')
        img_data = rmfield(img_data,'img_stacks');
    end
    if length(fn) > 1
        fnamemat = strcat(savepathname,fn);
        save(fnamemat,'-v7.3','-nocompression');
    end
    
    saveas(gcf,[fname,'-', neuron_list{1} ,'.fig']);
end