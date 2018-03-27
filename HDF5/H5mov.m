classdef H5mov
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
    end
    methods
        function obj = loadAll(obj,fname)
            logMatFileList = ListMatLogFiles( pwd );
            f_list_log = FindBatchMatLogFile({fname}, logMatFileList);
            fnamelog = f_list_log{1};
            obj = import_h5_file(1,fname,fnamelog,obj);
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
            flist = uigetfile('*.h5','MultiSelect','on');
            logMatFileList = ListMatLogFiles( pwd );
            f_list_log = FindBatchMatLogFile(flist, logMatFileList);

            if ~iscell(flist)
                flist = {flist};
                
            end
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
            elseif narargin==1
               obj = H5mov(varargin{1}); 
            end
        end
        function obj = load_movie_metadata(obj)
                        %get metadata 
            [piezo,volumes,lasers,tframe,img_idx,res,...
                obj.acq_start_time]=LoadImgProperties(obj.filename);
            piezo=piezo(1:length(img_idx));
            volumes=volumes(1:length(img_idx));
            lasers=lasers(1:length(img_idx),:);
            obj.t=zeros(max(volumes),1);
            which_lasers=find(any(lasers,1));
            zstack_pos=20*(piezo(volumes==1 & lasers(:,which_lasers(1))));
            if length(zstack_pos)==1
                zdiff_size =1 ;
            else
                zdiff_size=diff(zstack_pos);
            end
            obj.pixelSize=[.27,...
                    .27,...
                    zdiff_size(1)];
            obj.d1 = res(1);
            obj.d2 = res(2);
            obj.d3 = length(zstack_pos);
            obj.T = max(volumes);
            for ii=1:max(volumes)
                obj.t(ii)=mean(tframe(volumes==ii));
            end
        end
    end
end