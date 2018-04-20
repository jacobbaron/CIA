classdef H5mov < handle
    properties
        t
        neuron_type
        odor_seq        
        acq_start_time
        filename
        filename_log
        path
        img_stack_max
        pixelSize
        which_side
        annotations
        label
        d1
        d2
        d3
        T
        meta = struct;
    end
    properties (SetAccess = private, Hidden = true)
        odor_conc_inf
        odor_inf
    end
    methods
%         function obj = loadAll(obj,fname)
%             logMatFileList = ListMatLogFiles( pwd );
%             f_list_log = FindBatchMatLogFile({fname}, logMatFileList);
%             fnamelog = f_list_log{1};
%             %obj = import_h5_file(1,fname,fnamelog,obj);
%         end
        function obj = loadSome(obj,tStart,tCount,str)
            if isempty(obj.filename)
                obj = choose(obj);obj.load_movie_metadata;obj.load_odor_seq;
            end
            if ~exist('str','var')
                str = obj.filename;
            end
            fStart = find(obj.t>tStart,1);
            fEnd = find(obj.t>(tStart+tCount),1);
            fCount = fEnd-fStart;
            if ~isfield(obj.meta,'piezo')
                obj.load_movie_metadata;
            end
            mov5D = zeros(obj.d1,obj.d2,obj.d3,fCount,2,'uint16');
            h = waitbar(0,'Loading...');
            for ii=1:fCount
               [mov5D(:,:,:,ii,1),mov5D(:,:,:,ii,2)] = get_single_volume(...
                   fullfile(obj.path,obj.filename),obj.meta.volumes,obj.meta.lasers,obj.meta.piezo,...
                   obj.meta.img_idx,obj.meta.res,obj.d3,fStart+ii-1);
               waitbar(ii/fCount,h);
            end
            close(h);
            H5_Viewer2(mov5D,obj.t(fStart:fStart+fCount-1),obj.meta.lasers,...
                str);
            
        end
        function obj = playOdorResponse(obj)
            if isempty(obj.filename)
                obj = choose(obj);obj.load_movie_metadata;obj.load_odor_seq;
            end
%             seqStarts = cumsum([0;cell2mat(obj.odor_conc_inf(1:end-1,3))]);
%             notWater = ~strcmp(obj.odor_conc_inf(:,2),'water');
%            odors2choose = obj.odor_conc_inf(notWater,2);
%            conc2choose = obj.odor_conc_inf(notWater,1);
%            odorStrs = cellfun(@(x,y)[x,' ',y],conc2choose,odors2choose,'UniformOutput',false);
%            odorStarts = seqStarts(notWater);
           [odorStrs,odorStarts] = obj.odor_seq.list_sequence;
           [odorIdx,preTime,postTime] = select_odor_starts(odorStrs);
           
           obj.loadSome(odorStarts(odorIdx)-preTime,postTime+preTime,sprintf('%s, %s',obj.filename,odorStrs{odorIdx}));
        end
        function load_odor_seq(obj)            
            
            if contains(obj.filename_log,'h5l')
                obj.odor_seq = odor_seq_multimix;                
            else
                obj.odor_seq = odor_seq_trad;                
            end
            obj.odor_seq = load_odor_seq(obj.odor_seq,obj.path,obj.filename_log);
        end
        function obj = choose(varargin)
            [flist,pth] = uigetfile('*.h5','MultiSelect','on');
            logMatFileList = ListMatLogFiles( pth);
            if ~iscell(flist)
                flist = {flist};
            end
            f_list_log = FindBatchMatLogFile(flist, logMatFileList);
            obj(length(flist)) = H5mov;
            
            for i = 1:length(flist)
                obj(i).filename = flist{i};
                obj(i).filename_log = f_list_log{i};
                obj(i).path = pth;
            end
        end
        function obj = H5mov(varargin)
            if nargin==2
                obj.filename = varargin{1};
                obj.filename_log = varargin{2};
                obj.path = fileparts(which(obj.filename));
            elseif nargin==1
               obj = H5mov(varargin{1}); 
            end
        end
        function load_movie_metadata(obj)
                        %get metadata 
            [obj.meta.piezo,obj.meta.volumes,obj.meta.lasers,obj.meta.tframe,obj.meta.img_idx,obj.meta.res,...
                obj.acq_start_time]=LoadImgProperties(fullfile(obj.path,obj.filename));
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
    methods (Static)
        function obj = loadobj(s)
            if ~isa(s.odor_seq,'odor_sequence')
                s.odor_seq = odor_seq_trad(s.odor_conc_inf,s.odor_inf);
%                 s.odor_seq.odor_conc_inf = ;
%                 s.odor_seq.odor_inf = ;
%                 notWater = ~cellfun(@(x)strcmpi(x,'water'),s.odor_conc_inf(:,2));
%                 s.odor_seq.odors = categorical(s.odor_conc_inf(notWater,2));
%                 s.odor_seq.concs = categorical(s.odor_conc_inf(notWater,1));
            end
            obj = s;
            1;
        end
    end
end
