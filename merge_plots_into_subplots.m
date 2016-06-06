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
    sig_tot=cell(size(files));
    neuron_list_tot=cell(size(files));
    image_times_tot=cell(size(files));
    odor_seq_tot=cell(size(files));
    for ii=1:length(files)
        load([pathname files{ii}],'normalized_signal','neuron_list','image_times',...
            'odor_seq','istart','iend')
        sig_tot{ii}=normalized_signal;
        neuron_list_tot{ii}=neuron_list(~cellfun('isempty',neuron_list));
        image_times_tot{ii}=image_times;
        odor_seq_tot{ii}=odor_seq;
    end
else
    load([pathname files])
end

figure
for ii=1:length(files)
    subplot(ceil(length(files)/2),2,ii)
    curve_plot_subplots(sig_tot{ii},image_times_tot{ii},odor_seq_tot{ii},neuron_list_tot{ii})
    fname=files{ii};
    runnumidx=regexp(fname,'run')+3;
    title(strcat('run ',fname(runnumidx:runnumidx+2)))
end

