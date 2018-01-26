function [img_data]=import_nd2_files(import_all,filename,filename_log)
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
%if no filename is specified, ask
if ~exist('filename','var')
    [filename,pathname]  = uigetfile({'*.nd2'});  
else
    pathname=strcat(pwd,filesep);
end
if ~exist('filename_log','var')
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
    if ~isfield(log_data, 'mixAPPFlag')
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
    else 

        channel_seq = {'A5', 'A1', 'A2', 'A3', 'A4', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8'};
        for i = 1:length(log_data.period_pulse)
            odor_inf{2*i-1,1} = 'water';  %water
            
            myIndexA = find(strcmp(channel_seq, log_data.mixA{i}));
            myIndexB = find(strcmp(channel_seq, log_data.mixB{i}));
            
            if strcmp(log_data.odor_list{myIndexA}, 'water')
                str1 = sprintf('%.1f %s %s', log_data.ratioA(i), log_data.odor_list{myIndexA});
            else
                str1 = sprintf('%.1f %s %s', log_data.ratioA(i), log_data.conc_list{myIndexA}, log_data.odor_list{myIndexA});
            end
            
            if strcmp(log_data.odor_list{myIndexB}, 'water')
                str2 = sprintf('%.1f %s %s', 1-log_data.ratioA(i), log_data.odor_list{myIndexB});
            else
                str2 = sprintf('%.1f %s %s', 1-log_data.ratioA(i), log_data.conc_list{myIndexB}, log_data.odor_list{myIndexB});
            end
            
            odor_inf(2*i, 1)=cellfun(@(x,y) strtrim(sprintf('%s %s',x,y)), mat2cell(str1, 1) , mat2cell(str2, 1), 'UniformOutput',false);

            odor_inf(2*i-1,2) = num2cell(log_data.period_water(i)'); %water
            odor_inf(2*i,2) = num2cell(log_data.period_pulse(i)');   %odor
        
        end
        odor_inf(2*i+1,2) = num2cell(log_data.period_water(i+1)'); %water
        odor_inf{2*i+1,1} = 'water';  %water
        
        neuron_idx=strfind(filename,'_run');
        neuron_type=filename(1:neuron_idx);

        for i = 1:2*length(log_data.period_pulse)+1
            odor_conc_inf{i,1} = ' ';
        end        
        odor_conc_inf(:,2) = odor_inf(:,1);
        odor_conc_inf(:,3) = odor_inf(:,2);
        
    end
        
end
%%

if exist('pathname', 'var')
        try
            if isdir(pathname)
            cd(pathname);
            end
        end
end

   
fname = [pathname filename];
 
if ~exist('data','var')
     data=bfopen(fname);   
end
 if ~exist('import_all','var') 
    ask=1;
elseif ~import_all
    ask=1;
 else
     ask=0;
 end
[num_series,~]=size(data);
 omeMeta=data{1,4};
if ~exist('z','var')
    zrange=omeMeta.getPixelsSizeZ(0).getValue();
    if ask==1;
        z=input('Please enter start and end z sections you want to analyze (leave blank to include all planes):','s');
    else
        z=[];
    end
    if isempty(z)
        z=[1,zrange];
    else
        z=str2num(z);
    end
    zplane=z(1):z(2);
        
end

if ~exist('frames','var')   
    trange=omeMeta.getPixelsSizeT(0).getValue();
     if ask==1
        frames=input('Please enter start and end frames for analyzing the data (leave blank to inclue all frames):','s');
    else
        frames=[];
    end
    if isempty(frames)
        frames=[1,trange];
    else
        frames=str2num(frames);
    end
end

imagelist=data{1,1};

istart=frames(1);
iend=frames(2);
num_t=iend-istart+1; %number of time series

acq_start_time=datetime({omeMeta.getImageAcquisitionDate(0).getValue()},...
    'InputFormat','uuuu-MM-dd''T''HH:mm:ss');

%%

%figure out the totle number of z sections, to replace the input of this information
image_inf = data{1}{1,2};

% number of channels
% if isempty(strfind(image_inf, 'C=1/'))
%     num_c = 1;
% else
%     c_start = strfind(image_inf, 'C=1/');
%     c_end   = strfind(image_inf, '; T=1/');
%     num_c = str2double(image_inf(c_start+4 : c_end-1));
% end
num_c=omeMeta.getPixelsSizeC(0).getValue();


% select the number of channel
if num_c ~= 1
     if ask==1
        channel = input(sprintf('Please enter the channel for analyzing the data\n(enter nothing to import all channels):'),'s');
    else
        channel=[];
    end
    if isempty(channel)
       channel_num=1:num_c; 
       
    else
       channel_num = str2num(channel);
       
    end
else
    channel_num = 1;
end

mcherry=0;

%number of z section
% z_start = strfind(image_inf, 'Z=1/');
% 
% if isempty(strfind(image_inf, 'C=1/'))
%     z_end   = strfind(image_inf, '; T=1/');
% else
%     z_end   = strfind(image_inf, '; C=1/');
% end
% 
% if isempty(z_start)
%     num_z = 1;
% else
%     num_z = str2double(image_inf(z_start+4 : z_end-1));
% end
num_z=zrange;
m=omeMeta.getPixelsSizeY(0).getValue();
n=omeMeta.getPixelsSizeX(0).getValue();

if ~exist('img_stack_maxintensity','var')
    
%    img_stack_maxintensity=zeros(m,n,num_t); %maximum intensity projection stack along z 
    img_stack_channels=cell(1,length(channel_num));
    img_stack_t=zeros(m,n,length(zplane),length(istart:iend));
    for ii=1:length(channel_num)
        
        for i=istart:iend
            k=i-istart+1;
            img_stack=zeros(m,n,length(zplane));
            
            for j=1:length(zplane)
                if ~mcherry
%                     if zrange==1
%                         img_stack(:,:,j)=imagelist{i, 1};
%                     else
                        img_stack(:,:,j)=imagelist{(i-1)*num_z*num_c + num_c*(zplane(j)-1) + channel_num(ii),1};
%                     end
                else
                    imagelist=data{zplane(j),1};
                    %img_stack(:,:,j)=imagelist{2*i-1,1};
                    img_stack(:,:,j)=imagelist{i,1};
                end
            end
            %img_stack_maxintensity(:,:,k)=max(img_stack,[],3);
            img_stack_t(:,:,:,k)=img_stack;

        end
        img_stack_channels{ii}=img_stack_t;

    end     
end


%% Added by Guangwei 12/06/2013, to get the time information of each frame.
metadata = data{2};

image_times = zeros(num_t,1);

for i=istart:iend

    j = i-istart+1;

    index = i*num_z - 1;
    image_times(j) = metadata.get(['timestamp ' num2str(index)]);
end


    
%% get the odor sequence
odor_seq = getodorseq( image_times,  odor_inf, odor_conc_inf);

[odor_start_time, odor_end_time]=calculate_odor_start_end_time(acq_start_time,image_times,odor_seq);

%% save output data

img_data=struct;
img_data.img_stacks=img_stack_channels;
img_data.t=image_times;
img_data.neuron_type=neuron_type;
img_data.odor_seq=odor_seq;
img_data.odor_conc_inf=odor_conc_inf;
img_data.acq_start_time=acq_start_time;
img_data.odor_start_time=odor_start_time;
img_data.filename=fname;
img_data.filename_log=fname_log;

img_data.img_stack_max=cellfun(@(x)squeeze(max(x,[],3)),img_data.img_stacks,'UniformOutput',false);

img_data.metadata=metadata;
img_data.omemeta=omeMeta;
if size(img_data.img_stacks{1},3)>1
    img_data.pixelSize=[omeMeta.getPixelsPhysicalSizeX(0).getValue(),...
                        omeMeta.getPixelsPhysicalSizeY(0).getValue(),...
                        omeMeta.getPixelsPhysicalSizeZ(0).getValue()];
else
    img_data.pixelSize=[omeMeta.getPixelsPhysicalSizeX(0).getValue(),...
                        omeMeta.getPixelsPhysicalSizeY(0).getValue()];
end
% if exist('log_data','var')
%     img_data.which_side=log_data.which_side;
%     img_data.annotations=log_data.annotations;
% end

return;