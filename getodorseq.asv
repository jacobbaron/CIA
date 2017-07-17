function odor_seq = getodorseq( image_times,  odor_inf,odor_conc_inf)
%GETODORSEQ Summary of this function goes here

%load the file of the information of odor, concentration, and colormap.
%global odor_list odor_concentration_list odor_colormap;
load odor_inf.mat


seq_odortype   = zeros(1, length(odor_inf));
seq_timeperiod=[odor_conc_inf{:,3}];

if iscell(odor_inf{1,1})
    odor_inf(:,1)=cellfun(@(x)x{:},odor_inf(:,1),'UniformOutput',false);
end

not_water=cellfun(@(x)~strcmp(lower(x),'water'),odor_conc_inf(:,2));
not_water_id=find(not_water);
new_conc=not_water_id(~ismember(odor_conc_inf(not_water,1),odor_concentration_list));
unique_new_conc=unique(odor_conc_inf(new_conc,1));

new_odor=unique(not_water_id(~ismember(odor_conc_inf(not_water,2),odor_list)));
unique_new_odor=unique(odor_conc_inf(new_odor,2));
die=0;
if ~isempty(unique_new_conc)
    for ii=1:length(unique_new_conc)
        new_conc_str=unique_new_conc{ii};

       add2conclist=questdlg(sprintf('New concentration found: %s, add to database?\n Entering no will exit importing',...
           new_conc_str),'New Concentrations',...
           'Yes, add','No, I will fix','Yes, add');
       switch add2conclist
           case 'Yes, add'
                odor_concentration_list=sort([odor_concentration_list;new_conc_str]);
           case 'No, I will fix'
               die=1;
               break;
       end
    
    end
end
if ~isempty(unique_new_odor) && ~die
    for ii=1:length(unique_new_odor)
        new_odor_str=unique_new_odor{ii};

       add2conclist=questdlg(sprintf('New odor found: %s, add to database?\n Entering no will exit importing',...
           new_odor_str),'New Odors',...
           'Yes, add','No, I will fix','Yes, add');
       switch add2conclist
           case 'Yes, add'
                odor_list=[odor_list;new_odor_str];
           case 'No, I will fix'
               die=1;
               break;
       end
    
    end
end
odor_colormap=gen_odor_colormap(odor_list,odor_concentration_list);
odor_inf_path=which('odor_inf.mat');
save(odor_inf_path,'odor_list','odor_concentration_list','odor_colormap');

seq_odortype_new=zeros(1,length(odor_inf));

odor_conc_ids=zeros(length(find(not_water)),2);
odor_conc_ids(:,1)=cellfun(@(x)find(strcmp(odor_concentration_list,x)),odor_conc_inf(not_water,1));
odor_conc_ids(:,2)=cellfun(@(x)find(strcmp(odor_list,x)),odor_conc_inf(not_water,2));
seq_odortype(not_water)=(odor_conc_ids(:,2)-1)*length(odor_concentration_list)+odor_conc_ids(:,1);

% for i=1:length(odor_inf)
%     inf_str = odor_inf{i,1};
%     ind = strfind(inf_str, ' ');
%     if isempty(ind)
%         %means it is water        
%     elseif strcmp(inf_str(ind(1)+1:end),'water')
%         seq_odortype(i) = 0;
%     else
%         ind=ind(1);
%         %it is odor with concentration and odor name
%         str_conc = inf_str(1 : ind-1);
%         str_odor = inf_str(ind+1 : end);
% 
%         index_conc_temp = strcmp(str_conc, odor_concentration_list);
%         index_conc = find(index_conc_temp);
%         
%         index_odor_temp = strcmp(str_odor, odor_list);
%         index_odor = find(index_odor_temp);
% 
%         seq_odortype(i) = (index_odor-1)*length(odor_concentration_list) + index_conc;
%     end
% end

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