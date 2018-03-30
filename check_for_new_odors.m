function [odor_list,odor_concentration_list,odor_colormap]= check_for_new_odors(odor_conc_inf)
load('odor_inf.mat');
not_water=cellfun(@(x)~strcmpi(x,'water'),odor_conc_inf(:,2));
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
