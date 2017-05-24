function [img_data]=import_h2_file(import_all,filename,filename_log)
%import_all=1 if you want to import all data, otherwise, it will ask for
%you to specify amount of data


global  odor_seq  image_times;
global odor_list odor_concentration_list odor_colormap;

%%

    p1 = mfilename
    p2 = mfilename('fullpath')
    currentFolder = strrep(p2, p1, '')

path = [currentFolder, 'data\'];
load('odor_inf.mat');

addpath(pwd)
if ~exist('filename','var') && ~exist('filename_log','var')
    [filename,pathname]  = uigetfile({'*'});  

%% load the log file
    disp('Choose the log file of this experiment.');
    [filename_log]  =  uigetfile([pathname, 'log_*']);
    
else
    pathname=strcat(pwd,filesep);
end
fname_log = [pathname filename_log];
if ~isempty(strfind(filename_log,'.txt'))
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
else
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
end
%%

if exist('pathname', 'var')
        try
            if isdir(pathname)
            cd(pathname);
            end
        end
end

%% load the data
   
fname = [pathname filename];

%get metadata 
[piezo,volumes,lasers,t,img_idx,res,...
    acq_start_time]=LoadImgProperties(filename);
piezo=piezo(1:length(img_idx));
volumes=volumes(1:length(img_idx));
lasers=lasers(1:length(img_idx),:);
image_times=zeros(max(volumes),1);
for ii=1:max(volumes)
    try
    image_times(ii)=mean(t(volumes==ii));
    catch
        1;
    end
end

which_lasers=find(any(lasers,1));
zstack_pos=20*(piezo(volumes==1 & lasers(:,which_lasers(1))));
zdiff_size=diff(zstack_pos);

%initialize array
img1=initialize_imgs(volumes,lasers,res,img_idx);
x=waitbar(0,'Loading');
for ii=1:max(volumes) %fill up array with data
    waitbar(ii/max(volumes),x);
    img1=get_volume(fname,ii,lasers,piezo,img_idx,res,volumes,img1);
   
end
close(x)
img_stacks=cell(size(img1,5),1);
for ii=1:length(img_stacks)
    img_stacks{ii}=img1(:,:,:,:,ii);
end

%% get the odor sequence
odor_seq = getodorseq( image_times,  odor_inf, odor_conc_inf);

[odor_start_time, odor_end_time]=calculate_odor_start_end_time(acq_start_time,image_times,odor_seq);

%% save output data

img_data=struct;
img_data.img_stacks=img_stacks;
img_data.t=image_times;
img_data.neuron_type=neuron_type;
img_data.odor_seq=odor_seq;
img_data.odor_conc_inf=odor_conc_inf;
img_data.acq_start_time=acq_start_time;
img_data.odor_start_time=odor_start_time;
img_data.filename=fname;
img_data.filename_log=fname_log;
img_data.img_stack_max=cellfun(@(x)squeeze(max(x,[],3)),img_data.img_stacks,'UniformOutput',false);
img_data.pixelSize=[.27,...
                    .27,...
                    zdiff_size(1)];
if exist('log_data','var')
    img_data.which_side=log_data.which_side;
    img_data.annotations=log_data.annotations;
end

return;