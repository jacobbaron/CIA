global neuron_list;

if ~exist('fname','var')
   fname=img_data.filename;
end
    


if length(questdlg('Save this data? Make sure you have exported everything! '))==3

%    clear data;
%    clear imagelist;
%    clear img_stack;
    [fn, savepathname]= uiputfile('*.mat', 'choose file to save', strcat(fname,'-', neuron_list{1},'.mat'));
    if length(fn) > 1
        fnamemat = strcat(savepathname,fn);
        save(fnamemat,'-v7.3');
    end
    saveas(gcf,[fname,'-', neuron_list{1} ,'.fig']);
end