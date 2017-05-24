function [odor, conc, inds]=compute_odor_conc(odorID,odor_inf)
   odor_list=odor_inf.odor_list;
   odor_concentration_list=odor_inf.odor_concentration_list;
   odor_colormap=odor_inf.odor_colormap;
   if odorID==0
        odor = 'Water';
        conc = ' ';
        inds=[NaN,NaN];
   else
       if odorID==length(odor_concentration_list)*length(odor_list)
           ind_odor=length(odor_list);
           ind_conc=length(odor_concentration_list);
       else
           
        ind_odor = floor(odorID/length(odor_concentration_list))+1;
        ind_conc = rem(odorID, length(odor_concentration_list));
        if ind_conc ==0 % added Sep 24, fix bug when rem==0
            ind_conc = length(odor_concentration_list);
        end
       end
        odor = odor_list{ind_odor};

        conc= odor_concentration_list{ind_conc};
        inds=[ind_odor,ind_conc];
   end
end