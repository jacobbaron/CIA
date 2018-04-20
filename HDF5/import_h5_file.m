function [img_data]=import_h5_file(import_all,filename,filename_log,img_data)
%import_all=1 if you want to import all data, otherwise, it will ask for
%you to specify amount of data


global  odor_seq  image_times;

%%

    p1 = mfilename;
    p2 = mfilename('fullpath');
    currentFolder = strrep(p2, p1, '');

path = [currentFolder, 'data\'];
load('odor_inf.mat');

addpath(pwd)
%if no filename is specified, ask
 if ~exist('filename','var') && ~exist('filename_log','var')
    [filename,pathname]  = uigetfile({'*.h5'});  

%% load the log file
    % automatically figure out the log file (.mat file)
    logMatFileList = ListMatLogFiles( pathname );
    filename_log = FindSingleMatLogFile(filename, logMatFileList);

    % display the movie file and log file 
    disp('----------------File Information----------------');
    disp(['Image file: ', pathname, filename]);
    disp(['Log file (.mat): ', pathname, filename_log]);

%     disp('Choose the log file of this experiment.');
%     [filename_log]  =  uigetfile([pathname, 'log_*']);
    
 else
     pathname=strcat(pwd,filesep);
 end

fname_log = filename_log;
odor_seq = import_odor_seq_lf(pathname, fname_log);
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
    image_times(ii)=mean(t(volumes==ii));
end

which_lasers=find(any(lasers,1));
zstack_pos=20*(piezo(volumes==1 & lasers(:,which_lasers(1))));
zdiff_size=diff(zstack_pos);

%initialize array
img1=initialize_imgs(volumes,lasers,res,img_idx);
x=waitbar(0,'Loading');
% for ii=1:max(volumes) %fill up array with data
%     waitbar(ii/max(volumes),x);
%     img1=get_volume(fname,ii,lasers,piezo,img_idx,res,volumes,img1);
%    
% end
[img1] = get_all_volumes(fname,lasers,piezo,img_idx,res,volumes,t,img1);
close(x)
img_stacks=cell(size(img1,5),1);
for ii=1:length(img_stacks)
    img_stacks{ii}=img1(:,:,:,:,ii);
end
clear img1
%% get the odor sequence
[odor_start_time, odor_end_time]=calculate_odor_start_end_time(acq_start_time,image_times,odor_seq);

%% save output data


img_data.img_stacks=img_stacks;

img_data.t=image_times;
img_data.neuron_type=neuron_type;
img_data.odor_seq=odor_seq;

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