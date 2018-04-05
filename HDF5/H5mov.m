classdef H5mov < handle
    properties
        odor_inf
        t
        neuron_type
        odor_seq
        odor_conc_inf
        acq_start_time
        filename
        filename_log
        img_stack_max
        pixelSize
        which_side
        annotations 
        d1
        d2
        d3
        T
        meta = struct;
    end
    methods
        function obj = loadAll(obj,fname)
            logMatFileList = ListMatLogFiles( pwd );
            f_list_log = FindBatchMatLogFile({fname}, logMatFileList);
            fnamelog = f_list_log{1};
            obj = import_h5_file(1,fname,fnamelog,obj);
        end
        function obj = loadSome(obj,tStart,tCount)
            fStart = find(obj.t>tStart,1);
            fEnd = find(obj.t>(tStart+tCount),1);
            fCount = fEnd-fStart;
            if ~isfield(obj.meta,'piezo')
                obj = obj.load_movie_metadata;
            end
            mov5D = zeros(obj.d1,obj.d2,obj.d3,fCount,2,'uint16');
            h = waitbar(0,'Loading...');
            for ii=1:fCount
               [mov5D(:,:,:,ii,1),mov5D(:,:,:,ii,2)] = get_single_volume(...
                   obj.filename,obj.meta.volumes,obj.meta.lasers,obj.meta.piezo,...
                   obj.meta.img_idx,obj.meta.res,obj.d3,fStart+ii-1);
               waitbar(ii/tCount,h);
            end
            close(h);
            H5_Viewer2(mov5D,obj.t(fStart:fStart+fCount-1),obj.meta.lasers);
            
        end
        function obj = playOdorResponse(obj)
            seqStarts = cumsum(cell2mat(obj.odor_conc_inf(:,3)));
            notWater = ~strcmp(obj.odor_conc_inf(:,2),'water');
           odors2choose = obj.odor_conc_inf(notWater,2);
           conc2choose = obj.odor_conc_inf(notWater,1);
           odorStrs = cellfun(@(x,y)[x,' ',y],conc2choose,odors2choose,'UniformOutput',false);
           odorStarts = seqStarts(notWater);
        end
        function obj = load_odor_seq(obj)            
            if contains(obj.filename_log,'.txt')
                % number of lines
                fid = fopen(obj.filename_log);
                allText = textscan(fid,'%s','delimiter','\n');
                fclose(fid);

                % strain name
                numberOfLines = length(allText{1});
                obj.neuron_type = allText{1,1}{1,1};
                
                % the odor information
                num_ = 3;
                obj.odor_inf = cell(numberOfLines-num_, 2);
                fmt='%s\t %d\t';
                for i = 1:numberOfLines-num_
                    obj.odor_inf(i, :) = textscan(allText{1,1}{i+num_,1}, ...
                        fmt, 'Delimiter','\t');
                end
                sp=cellfun(@(x)strfind(x,' '),obj.odor_inf(:,1));
                not_water=cellfun(@(x)~isempty(x),sp);
                obj.odor_conc_inf=cell(size(obj.odor_inf,1),3);
                obj.odor_conc_inf(not_water,1)=cellfun(@(x,y)x{1}(1:y(1)-1),obj.odor_inf(not_water,1),sp(not_water),...
                    'UniformOutput',false);
                obj.odor_conc_inf(not_water,2)=cellfun(@(x,y)x{1}(y(1)+1:end),obj.odor_inf(not_water,1),sp(not_water),...
                    'UniformOutput',false);
                obj.odor_conc_inf(~not_water,2)=cellfun(@(x)x{1},obj.odor_inf(~not_water,1),'UniformOutput',false);
                obj.odor_conc_inf(:,3)=obj.odor_inf(:,2);
            else
                load(obj.filename_log);
                odors_used=['water';log_data.odor_list];
                conc_used=[' ';log_data.conc_list];
                odor_inf = cell(size(log_data.sequence_period'));
                odor_inf(:,1)=cellfun(@(x,y)strtrim(sprintf('%s %s',x,y)),...
                    conc_used(log_data.sequence_channel'),odors_used(log_data.sequence_channel'),...
                    'UniformOutput',false);
                odor_inf(:,2)=num2cell(log_data.sequence_period');
                %neuron_idx=strfind(filename,'_run');
                %neuron_type=filename(1:neuron_idx);
                obj.odor_conc_inf = cell(length(odor_inf),3);
                obj.odor_conc_inf(:,1)=conc_used(log_data.sequence_channel');
                obj.odor_conc_inf(:,2)=odors_used(log_data.sequence_channel');
                obj.odor_conc_inf(:,3)=odor_inf(:,2);
                obj.which_side = log_data.which_side;
                obj.annotations = log_data.annotations;
                check_for_new_odors(obj.odor_conc_inf);
                obj.odor_inf = load('odor_inf.mat');
            end
        end
        function obj = choose(obj)
            [flist,path] = uigetfile('*.h5','MultiSelect','on');
            logMatFileList = ListMatLogFiles( path );
            if ~iscell(flist)
                flist = {flist};
            end
            f_list_log = FindBatchMatLogFile(flist, logMatFileList);
            obj(length(flist)) = H5mov;
            
            for i = 1:length(flist)
                obj(i).filename = flist{i};
                obj(i).filename_log = f_list_log{i};
            end
        end
        function obj = H5mov(varargin)
            if nargin==2
                obj.filename = varargin{1};
                obj.filename_log = varargin{2};
            elseif nargin==1
               obj = H5mov(varargin{1}); 
            end
        end
        function obj = load_movie_metadata(obj)
                        %get metadata 
            [obj.meta.piezo,obj.meta.volumes,obj.meta.lasers,obj.meta.tframe,obj.meta.img_idx,obj.meta.res,...
                obj.acq_start_time]=LoadImgProperties(obj.filename);
            obj.meta.piezo=obj.meta.piezo(1:length(obj.meta.img_idx));
            obj.meta.volumes=obj.meta.volumes(1:length(obj.meta.img_idx));
            obj.meta.lasers=obj.meta.lasers(1:length(obj.meta.img_idx),:);
            obj.t=zeros(max(obj.meta.volumes),1);
            obj.meta.which_lasers=find(any(obj.meta.lasers,1));
            zstack_pos=20*(obj.meta.piezo(obj.meta.volumes==1 & obj.meta.lasers(:,obj.meta.which_lasers(1))));
            if length(zstack_pos)==1
                zdiff_size =1 ;
            else
                zdiff_size=diff(zstack_pos);
            end
            obj.pixelSize=[.27,...
                    .27,...
                    zdiff_size(1)];
            obj.d1 = obj.meta.res(1);
            obj.d2 = obj.meta.res(2);
            obj.d3 = length(zstack_pos);
            obj.T = max(obj.meta.volumes);
            for ii=1:max(obj.meta.volumes)
                obj.t(ii)=mean(obj.meta.tframe(obj.meta.volumes==ii));
            end
        end
    end
end