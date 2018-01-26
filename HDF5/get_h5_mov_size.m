function [movSize,num_lasers]= get_h5_mov_size(filename)

[~,volumes,lasers,~,~,res,...
    ~]=LoadImgProperties(filename);
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
    
    movSize= [res(2),res(1),max(zdepth),num_vols];
   