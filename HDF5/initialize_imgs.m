function [img]=initialize_imgs(volumes,lasers,res,img_idx)
    % x,y,z,t,c
    unique_lasers=find(any(lasers,1));
    num_lasers=length(find(any(lasers,1)));    
    
    for ii=1:size(lasers,2); 
        zdepth(ii)=length(find(lasers(volumes==1,ii)));
    end
    
    img=zeros(res(1),res(2),max(zdepth),length(unique(volumes(volumes>0))),num_lasers,'uint16');
    
    
    