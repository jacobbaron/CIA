function [start_time, end_time]=calculate_odor_start_end_time(varargin)
    if length(varargin)==1
        load(varargin{1},'acq_start_time','image_times','odor_seq');
    else    
        acq_start_time=varargin{1};
        image_times=varargin{2};
        odor_seq=varargin{3};
    end
    
    water_change_idx=find(([diff(odor_seq)~=0;0] & odor_seq==0 )| ([0;diff(odor_seq)~=0] & odor_seq==0 ));
    start_time_rel=image_times(water_change_idx(1));
    end_time_rel=image_times(water_change_idx(end));
    
    start_time=acq_start_time+seconds(start_time_rel);
    end_time=acq_start_time+seconds(end_time_rel);
    
    
end