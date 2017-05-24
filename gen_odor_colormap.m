function [odor_colormap]=gen_odor_colormap(odor_list,odor_concentration_list)

odor_num = length(odor_list);
con_num = length(odor_concentration_list);

color_num = odor_num*con_num;
if color_num<128
    color_num = 128;
elseif color_num<256
    color_num = 256;
elseif color_num<512
    color_num = 512;
end

odor_colormap = colorcube(color_num); 
odor_colormap = odor_colormap(1:odor_num*con_num,:); 