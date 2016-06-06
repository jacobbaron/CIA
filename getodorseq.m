function odor_seq = getodorseq( image_times,  odor_inf)
%GETODORSEQ Summary of this function goes here

%load the file of the information of odor, concentration, and colormap.
global odor_list odor_concentration_list odor_colormap;

seq_timeperiod = zeros(1, length(odor_inf));
seq_odortype   = zeros(1, length(odor_inf));

for i=1:length(odor_inf)
    seq_timeperiod(i) = odor_inf{i,2};
end

for i=1:length(odor_inf)
    inf_str = odor_inf{i,1}{1};
    ind = strfind(inf_str, ' ');

    if isempty(ind)
        %means it is water
        seq_odortype(i) = 0;
    else
        %it is odor with concentration and odor name
        str_conc = inf_str(1 : ind-1);
        str_odor = inf_str(ind+1 : end);

        index_conc_temp = strcmp(str_conc, odor_concentration_list);
        index_conc = find(index_conc_temp);
        
        index_odor_temp = strcmp(str_odor, odor_list);
        index_odor = find(index_odor_temp);

        seq_odortype(i) = (index_odor-1)*length(odor_concentration_list) + index_conc;
    end
end

delay_time = 0;

seq_timeperiod_temp = [0 seq_timeperiod];

odor_seq = zeros(length(image_times), 1);

for i = 2:1: length(seq_timeperiod_temp)
    left = sum(seq_timeperiod_temp(1:i-1))+ delay_time;
    right= sum(seq_timeperiod_temp(1:i))+ delay_time;

    for j =1:1:length(image_times)
        if image_times(j)>left  && image_times(j)<right
            odor_seq(j) = seq_odortype(i-1);
        end
    end
end

odor_seq(length(image_times)) = odor_seq(length(image_times)-1);
end