function [img]=initialize_imgs(volumes,lasers,res,img_idx,volumes2import)
    % x,y,z,t,c
    if ~exist('volumes2import','var')
        num_vols = length(unique(volumes(volumes>0)));
    else
        num_vols = length(volumes2import);
    end
    unique_lasers=find(any(lasers,1));
    num_lasers=length(find(any(lasers,1)));    
    
    for ii=1:size(lasers,2); 
        zdepth(ii)=length(find(lasers(volumes==1,ii)));
    end
    
    img=uint16(zeros(res(1),res(2),max(zdepth),num_vols,num_lasers));
    
    
    