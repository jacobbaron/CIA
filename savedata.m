global neuron_list;

% if ~exist('fname','var')
   fname=img_data.filename;
   fname = fname(1:end-4);
% end
    


if length(questdlg('Save this data? Make sure you have exported everything! '))==3

%    clear data;
%    clear imagelist;
%    clear img_stack;
    [fn, savepathname]= uiputfile('*.mat', 'choose file to save', strcat(fname,'-', neuron_list{1},'.mat'));
    if length(fn) > 1
        fnamemat = strcat(savepathname,fn);
        img_data = rmfield(img_data,'img_stacks'); % remove the field of img_stacks from img_data, because it is too big
        save(fnamemat, '-v7.3','signal', 'savepathname', 'normalized_signal', 'neuron_list', ...
            'img_data', 'dual_position_data');
%         save(fnamemat,'-v7.3');

    end
    saveas(gcf,[fname,'-', neuron_list{1} ,'.fig']);
end