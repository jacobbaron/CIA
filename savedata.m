global neuron_list;

if length(questdlg('Save this data? Make sure you have exported everything! '))==3

%    clear data;
%    clear imagelist;
%    clear img_stack;
    [fn, savepathname]= uiputfile('*.mat', 'choose file to save', strcat(fname, '_',num2str(istart),'-',num2str(iend),'-', neuron_list{1},'.mat'));
    if length(fn) > 1
        fnamemat = strcat(savepathname,fn);
        save(fnamemat,'-regexp', '^(?!(data|imagelist|img_stack|omeMeta)$).');
    end
    saveas(gcf,[pathname, filename, '_',num2str(istart),'-',num2str(iend),'-', neuron_list{1} ,'.fig']);
end