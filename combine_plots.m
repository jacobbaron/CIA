%use this if you want to combine the plots from a single run where two
%neurons were on different z planes. 

close all;
clear;
%global  odor_seq  image_times;
%global odor_list odor_concentration_list odor_colormap;

%%
p1 = mfilename;
p2 = mfilename('fullpath');
currentFolder = strrep(p2, p1, '');

path = [currentFolder, 'data\'];
load([path, 'odor_inf'], 'odor_list', 'odor_concentration_list', 'odor_colormap');

addpath(pwd)
%% 
%helpdlg('Please select .mat files to plot normalized signal. Make sure all files are from same experiment','Warning')
[files,pathname]  = uigetfile({'*.mat'},'MultiSelect','on');  
if (iscell(files))
    sig_tot=cell(0);
    neuron_list_tot=cell(0);
    for ii=1:length(files)
        load([pathname files{ii}],'normalized_signal','neuron_list','image_times',...
            'odor_seq','istart','iend')
        sig_tot=[sig_tot normalized_signal];
        neuron_list_tot=[neuron_list_tot neuron_list(~cellfun('isempty',neuron_list))];
        image_times_old=image_times;
        if (image_times_old ~= image_times)
            h = errordlg('Image times don''t match! Try again.');
            return;
        end
    end
else
    load([pathname files])
    sig_tot=signal;
    neuron_list_tot=neuron_list;
end
normalized_signal=sig_tot;
neuron_list=neuron_list_tot;
clear sig_tot neuron_list_tot image_times_old ii
curve_plot(normalized_signal,image_times,odor_seq,neuron_list)

if length(questdlg('Save this data?'))==3

%    clear data;
%    clear imagelist;
%    clear img_stack;
    %[fn, savepathname]= uiputfile('*.mat', 'choose file to save', strcat(fname, '_',num2str(istart),'-',num2str(iend),'-', neuron_list{1},'.mat'));
    %fnamemat = strcat(savepathname,fn);
    split_filename=strsplit(files{1},'.nd2');
    savepathname=strcat(pathname, split_filename{1}, '_',num2str(istart),'-',...
        num2str(iend),'-',strjoin(neuron_list,'_'));
    save(strcat(savepathname,'.mat'));
    saveas(gcf,strcat(savepathname,'.fig'));
end
